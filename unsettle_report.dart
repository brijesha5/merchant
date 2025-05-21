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
  runApp(const UnsettledReport());
}

class UnsettledReport extends StatelessWidget {
  const UnsettledReport({Key? key}) : super(key: key);

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
              'Unsettle',  // The text you want to display
              style: TextStyle(
                color: Colors.white,  // Text color
                fontSize: 20,  // Font size
                fontWeight: FontWeight.bold,  // Font weight
              ),
            ),
            centerTitle: true,  // Centers the title in the AppBar
          ),
          body: const UnsettledDataPage(),
        ),
      ),
    );
  }
}

class UnsettledDataPage extends StatefulWidget {
  const UnsettledDataPage({Key? key}) : super(key: key);

  @override
  _UnsettledDataPageState createState() => _UnsettledDataPageState();
}

class _UnsettledDataPageState extends State<UnsettledDataPage> {
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
    // Set current date as default for both start and end
    DateTime today = DateTime.now();
    startDate = today;
    endDate = today;

    startDateController.text = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
    endDateController.text = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

    // Automatically fetch data for the current date range
    fetchData();
  }

  // Calculate total quantity and total amount
  int calculateTotalQty() {
    return data.fold(0, (sum, item) {
      return sum + (int.tryParse(item['qty']?.toString() ?? '0') ?? 0);
    });
  }

  double calculateTotalAmount() {
    return data.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['amount']?.toString() ?? '0.0') ?? 0.0);
    });
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

  // Fetch data based on selected start and end date
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

    final response = await http.get(Uri.parse('${apiUrl}report/unsettle?DB=$CLIENTCODE&startDate=$start&endDate=$end'));

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

  // Select date and automatically fetch data
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
        // Fetch data automatically after selecting date
        fetchData();
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
              pw.Text('Unsettled Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Bill No', 'Bill Date', 'Product', 'Quantity', 'Amount', 'Report Type', 'Cancel Date', 'Cancel Time', 'User Edited', 'Reason'],
                data: data.map((item) {
                  return [
                    item['billNo'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['product'] ?? 'N/A',
                    item['qty'] ?? '0',
                    item['amount'] ?? '0.00',
                    item['reportType'] ?? 'N/A',
                    item['cancelDate'] ?? 'N/A',
                    item['cancelTime'] ?? 'N/A',
                    item['userEdited'] ?? 'N/A',
                    item['reason'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/unsettled_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Bill No', 'Bill Date', 'Product', 'Quantity', 'Amount', 'Report Type', 'Cancel Date', 'Cancel Time', 'User Edited', 'Reason']);

    data.forEach((item) {
      sheetObject.appendRow([
        item['billNo'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['product'] ?? 'N/A',
        item['qty'] ?? '0',
        item['amount'] ?? '0.00',
        item['reportType'] ?? 'N/A',
        item['cancelDate'] ?? 'N/A',
        item['cancelTime'] ?? 'N/A',
        item['userEdited'] ?? 'N/A',
        item['reason'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/unsettled_data.xlsx';
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
          child: const Text('Fetch Report'),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Bill No')),
                      DataColumn(label: Text('Bill Date')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Report Type')),
                      DataColumn(label: Text('Cancel Date')),
                      DataColumn(label: Text('Cancel Time')),
                      DataColumn(label: Text('User Edited')),
                      DataColumn(label: Text('Reason')),
                    ],
                    rows: data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['billNo'] ?? 'N/A')),
                        DataCell(Text(item['billDate'] ?? 'N/A')),
                        DataCell(Text(item['product'] ?? 'N/A')),
                        DataCell(Text(item['qty'] ?? '0')),
                        DataCell(Text(item['amount'] ?? '0.00')),
                        DataCell(Text(item['reportType'] ?? 'N/A')),
                        DataCell(Text(item['cancelDate'] ?? 'N/A')),
                        DataCell(Text(item['cancelTime'] ?? 'N/A')),
                        DataCell(Text(item['userEdited'] ?? 'N/A')),
                        DataCell(Text(item['reason'] ?? 'N/A')),
                      ]);
                    }).toList(),
                  ),
                  // Display the total row below the Quantity and Amount columns
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('Total Qty')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Text(calculateTotalQty().toString())),  // Display total qty
                        DataCell(Text(calculateTotalAmount().toStringAsFixed(2))),  // Display total amount
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                        DataCell(Container()),  // Empty cell for visual alignment
                      ])
                    ],
                  ),
                ],
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
                _showDialog(context, 'PDF File Saved', 'Your report has been saved as PDF at: $filePath');
              },
              label: const Text('Export to PDF'),
              icon: const Icon(Icons.picture_as_pdf),
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                await _createExcelAndSave(context);
              },
              label: const Text('Export to Excel'),
              icon: const Icon(Icons.file_copy),
            ),
          ],
        ),
      ],
    );
  }
}
