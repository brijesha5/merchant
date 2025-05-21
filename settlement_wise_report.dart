import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'FireConstants.dart'; // Ensure this file contains your API URL and CLIENTCODE

void main() {
  runApp(const SettlementwiseReport());
}

class SettlementwiseReport extends StatelessWidget {
  const SettlementwiseReport({Key? key}) : super(key: key);

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
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Settlement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: const SettlementwiseDataPage(),
        ),
      ),
    );
  }
}

class SettlementwiseDataPage extends StatefulWidget {
  const SettlementwiseDataPage({Key? key}) : super(key: key);

  @override
  _SettlementwiseDataPageState createState() => _SettlementwiseDataPageState();
}

class _SettlementwiseDataPageState extends State<SettlementwiseDataPage> {
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

    // Assuming posdate is fetched from a global or settings variable
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    String dateandtimepos = dateFormat.format(DateTime.parse(posdate)); // posdate is your default date
    startDate = DateTime.parse(posdate);
    endDate = DateTime.parse(posdate);
    startDateController.text = dateandtimepos;
    endDateController.text = dateandtimepos;

    // Fetch data using 'posdate' as the default date
    fetchData();
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

    final response = await http.get(Uri.parse('${apiUrl}report/settlementwise?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

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

  double calculateTotalAmount() {
    double total = 0;
    for (var item in data) {
      if (item['amount'] != null) {
        total += double.tryParse(item['amount'].toString()) ?? 0.0;
      }
    }
    return total;
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

        // Automatically fetch data once both dates are selected
        if (startDate != null && endDate != null) {
          isLoading = true; // Show loading indicator while fetching data
          fetchData();
        }
      });
    }
  } double _calculateTotal(String key) {
    return data.fold(0.0, (sum, item) {
      return sum + double.tryParse(item[key]?.toString() ?? '0.0')!;
    });
  }


  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Settlementwise Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['No', 'Bill Date', 'Settlement Mode Name', 'Gross Amount', 'Number Of Bills', 'Percent To Gross'],
                data: [
                  ...data.map((item) {
                    int index = data.indexOf(item) + 1;
                    return [
                      index.toString(),
                      item['billDate'] ?? 'N/A',
                      item['settlementModeName'] ?? 'N/A',
                      item['grossAmount']?.toString() ?? 'N/A',
                      item['numberOfBills']?.toString() ?? 'N/A',
                      item['percentToGross']?.toString() ?? 'N/A',
                    ];
                  }).toList(),
                  [
                    'Total',
                    '',
                    '',
                    _calculateTotal('grossAmount').toStringAsFixed(2),
                    _calculateTotal('numberOfBills').toStringAsFixed(0),
                    _calculateTotal('percentToGross').toStringAsFixed(2),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/settlementwise_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['No', 'Bill Date', 'Settlement Mode Name', 'Gross Amount', 'Number Of Bills', 'Percent To Gross']);

    data.forEach((item) {
      int index = data.indexOf(item) + 1;
      sheetObject.appendRow([
        index.toString(),
        item['billDate'] ?? 'N/A',
        item['settlementModeName'] ?? 'N/A',
        item['grossAmount']?.toString() ?? 'N/A',
        item['numberOfBills']?.toString() ?? 'N/A',
        item['percentToGross']?.toString() ?? 'N/A',
      ]);
    });

    sheetObject.appendRow([
      'Total',
      '',
      '',
      _calculateTotal('grossAmount').toStringAsFixed(2),
      _calculateTotal('numberOfBills').toStringAsFixed(0),
      _calculateTotal('percentToGross').toStringAsFixed(2),
    ]);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/settlementwise_data.xlsx';
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
              const SizedBox(width: 8.0),
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
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: fetchData,
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,  // Horizontal scroll for data
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                return Colors.black26;
              }),
              columns: const [
                DataColumn(label: Text('No', style: TextStyle(color: Colors.black))),
                DataColumn(label: Text('Bill Date', style: TextStyle(color: Colors.black))),
                DataColumn(label: Text('Settlement Mode Name', style: TextStyle(color: Colors.black))),
                DataColumn(label: Text('Gross Amount', style: TextStyle(color: Colors.black))),
                DataColumn(label: Text('Number Of Bills', style: TextStyle(color: Colors.black))),
                DataColumn(label: Text('% To Gross', style: TextStyle(color: Colors.black))),
              ],
              rows: [
                ...data.map((item) {
                  int index = data.indexOf(item) + 1;
                  return DataRow(cells: [
                    DataCell(Text(index.toString())),
                    DataCell(Text(item['billDate'] ?? 'N/A')),
                    DataCell(Text(item['settlementModeName'] ?? 'N/A')),
                    DataCell(Text(item['grossAmount']?.toString() ?? 'N/A')),
                    DataCell(Text(item['numberOfBills']?.toString() ?? 'N/A')),
                    DataCell(Text(item['percentToGross']?.toString() ?? 'N/A')),
                  ]);
                }).toList(),
                DataRow(cells: [
                  const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(Text(_calculateTotal('grossAmount').toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_calculateTotal('numberOfBills').toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_calculateTotal('percentToGross').toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                String pdfPath = await exportToPdf(context);
                _showDialog(context, 'PDF Exported', 'PDF file is exported to: $pdfPath');
              },
              child: const Text('Export PDF'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _createExcelAndSave(context),
              child: const Text('Export Excel'),
            ),
          ],
        ),
      ],
    );
  }
}
