  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:path_provider/path_provider.dart';
  import 'package:pdf/widgets.dart' as pw;
  import 'package:excel/excel.dart';
  import 'package:open_file/open_file.dart';
  import 'package:printing/printing.dart';
  import 'FireConstants.dart'; // Ensure this file contains your API URL and CLIENTCODE

  void main() {
    runApp(const GrossSaleReport());
  }

  class GrossSaleReport extends StatelessWidget {
    const GrossSaleReport({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFD5282B),
              title: const Text(
                'Gross Sale Report',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const GrossSaleDataPage(),
          ),
        ),
      );
    }
  }

  class GrossSaleDataPage extends StatefulWidget {
    const GrossSaleDataPage({Key? key}) : super(key: key);

    @override
    _GrossSaleDataPageState createState() => _GrossSaleDataPageState();
  }

  class _GrossSaleDataPageState extends State<GrossSaleDataPage> {
    List<dynamic> data = [];
    bool isLoading = true;
    String errorMessage = '';
    DateTime? startDate;
    DateTime? endDate;

    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    void _showDialog(BuildContext context, String title, String content) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 5), () {
            Navigator.of(context).pop();
          });

          return AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.7),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.check_circle,
                  size: 48.0,
                  color: Colors.green,
                ),
                const SizedBox(height: 16.0),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> fetchData() async {
      if (startDate == null || endDate == null) {
        setState(() {
          errorMessage = 'Please select both start and end dates.';
          isLoading = false;
        });
        return;
      }

      String start = '${startDate!.day}-${startDate!.month}-${startDate!.year}';
      String end = '${endDate!.day}-${endDate!.month}-${endDate!.year}';

      final response = await http.get(Uri.parse('${apiUrl}report/grosssale?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

      if (response.statusCode == 200) {
        try {
          setState(() {
            data = json.decode(response.body);
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
            errorMessage = 'Error parsing data: $e';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    }

    Future<void> _selectDate(BuildContext context, bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          if (isStartDate) {
            startDate = picked;
            startDateController.text = '${picked.day}-${picked.month}-${picked.year}';
          } else {
            endDate = picked;
            endDateController.text = '${picked.day}-${picked.month}-${picked.year}';
          }
        });
      }
    }

    Future<String> exportToPdf(BuildContext context) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Gross Sale Report', style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'Settlement', 'Food Type', 'Sale Amount', 'CGST', 'Service Charge', 'SGST', 'VAT', 'Total'
                  ],
                  data: data.map((item) {
                    return [
                      item['settlement'] ?? 'N/A',
                      item['foodType'] ?? 'N/A',
                      item['saleAmt'] ?? 0.0,
                      item['cgst'] ?? 0.0,
                      item['serviceCharge'] ?? 0.0,
                      item['sgst'] ?? 0.0,
                      item['vat'] ?? 0.0,
                      item['total'] ?? 0.0,
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/gross_sale_report.pdf");
      await file.writeAsBytes(await pdf.save());

      return file.path;
    }

    Future<File> generateExcel(List<dynamic> data) async {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      sheetObject.appendRow([
        'Settlement', 'Food Type', 'Sale Amount', 'CGST', 'Service Charge', 'SGST', 'VAT', 'Total'
      ]);

      data.forEach((item) {
        sheetObject.appendRow([
          item['settlement'] ?? 'N/A',
          item['foodType'] ?? 'N/A',
          item['saleAmt'] ?? 0.0,
          item['cgst'] ?? 0.0,
          item['serviceCharge'] ?? 0.0,
          item['sgst'] ?? 0.0,
          item['vat'] ?? 0.0,
          item['total'] ?? 0.0,
        ]);
      });

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/gross_sale_data.xlsx';
      final file = File(path);
      file.writeAsBytesSync(excel.encode()!);

      return file;
    }

    Future<void> _createExcelAndSave(BuildContext context) async {
      final excelFile = await generateExcel(data);
      await OpenFile.open(excelFile.path);
      _showDialog(context, 'Export Successful', 'Report successfully exported to: ${excelFile.path}');
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText: 'Select Start Date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: 'Select End Date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: fetchData,
            child: const Text('Fetch Data'),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    return Colors.black26;
                  }),
                  columns: const [
                    DataColumn(label: Text('Settlement', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('Food Type', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('Sale Amount', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('CGST', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('Service Charge', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('SGST', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('VAT', style: TextStyle(color: Colors.black))),
                    DataColumn(label: Text('Total', style: TextStyle(color: Colors.black))),
                  ],
                  rows: data.map<DataRow>((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['settlement'] ?? 'N/A')),
                      DataCell(Text(item['foodType'] ?? 'N/A')),
                      DataCell(Text(item['saleAmt']?.toString() ?? '0.0')),
                      DataCell(Text(item['cgst']?.toString() ?? '0.0')),
                      DataCell(Text(item['serviceCharge']?.toString() ?? '0.0')),
                      DataCell(Text(item['sgst']?.toString() ?? '0.0')),
                      DataCell(Text(item['vat']?.toString() ?? '0.0')),
                      DataCell(Text(item['total']?.toString() ?? '0.0')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.extended(
                onPressed: () async {
                  final filePath = await exportToPdf(context);
                  _showDialog(context, 'PDF File Saved', 'File saved at: $filePath');
                  await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'gross_sale_report.pdf');
                },
                label: const Text('Export to PDF', style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                backgroundColor: Colors.red,
              ),
              FloatingActionButton.extended(
                onPressed: () => _createExcelAndSave(context),
                label: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.grid_on, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            ],
          ),
        ],
      );
    }
  }
