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
  runApp(const TaxwiseReport());
}

class TaxwiseReport extends StatelessWidget {
  const TaxwiseReport({Key? key}) : super(key: key);

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
            automaticallyImplyLeading: false,  // Disable the default back button behavior
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Tax',  // The text you want to display
              style: TextStyle(
                color: Colors.white,  // Text color
                fontSize: 20,  // Font size
                fontWeight: FontWeight.bold,  // Font weight
              ),
            ),
            centerTitle: true,  // Centers the title in the AppBar
          ),
          body: const TaxwiseDataPage(),
        ),
      ),
    );
  }
}

class TaxwiseDataPage extends StatefulWidget {
  const TaxwiseDataPage({Key? key}) : super(key: key);

  @override
  _TaxwiseDataPageState createState() => _TaxwiseDataPageState();
}

class _TaxwiseDataPageState extends State<TaxwiseDataPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the current date for both start and end dates
    final currentDate = DateTime.now();
    startDate = currentDate;
    endDate = currentDate;
    startDateController.text = '${currentDate.day}-${currentDate.month}-${currentDate.year}';
    endDateController.text = '${currentDate.day}-${currentDate.month}-${currentDate.year}';
    fetchData();  // Automatically fetch data for the current date range.
  }

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

    final response = await http.get(Uri.parse('${apiUrl}report/taxwise?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

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
      fetchData();  // Fetch new data after date selection.
    }
  }

  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Taxwise Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Bill No', 'Bill Date', 'Tax Name', 'Tax Percent', 'Taxable Amount', 'Tax Amount'],
                data: data.map((item) {
                  return [
                    item['billNo'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['taxName'] ?? 'N/A',
                    item['taxPercent'] ?? 'N/A',
                    item['taxableAmount'] ?? 'N/A',
                    item['taxAmount'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/taxwise_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Bill No', 'Bill Date', 'Tax Name', 'Tax Percent', 'Taxable Amount', 'Tax Amount']);

    data.forEach((item) {
      sheetObject.appendRow([
        item['billNo'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['taxName'] ?? 'N/A',
        item['taxPercent'] ?? 'N/A',
        item['taxableAmount'] ?? 'N/A',
        item['taxAmount'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/taxwise_data.xlsx';
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
                  DataColumn(label: Text('Bill No', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Bill Date', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Tax Name', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Tax Percent', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Taxable Amount', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Tax Amount', style: TextStyle(color: Colors.black))),
                ],
                rows: data.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['billNo'] ?? 'N/A')),
                    DataCell(Text(item['billDate'] ?? 'N/A')),
                    DataCell(Text(item['taxName'] ?? 'N/A')),
                    DataCell(Text(item['taxPercent'] ?? 'N/A')),
                    DataCell(Text(item['taxableAmount'] ?? 'N/A')),
                    DataCell(Text(item['taxAmount'] ?? 'N/A')),
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
                await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'taxwise_report.pdf');
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
