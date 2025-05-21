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
  runApp(const CancelBillReport());
}

class CancelBillReport extends StatelessWidget {
  const CancelBillReport({Key? key}) : super(key: key);

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
              'Cancel Bill Report',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: const CancelBillDataPage(),
        ),
      ),
    );
  }
}

class CancelBillDataPage extends StatefulWidget {
  const CancelBillDataPage({Key? key}) : super(key: key);

  @override
  _CancelBillDataPageState createState() => _CancelBillDataPageState();
}

class _CancelBillDataPageState extends State<CancelBillDataPage> {
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


    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    String dateandtimepos = dateFormat.format(DateTime.parse(posdate));
    startDate = DateTime.parse(posdate);
    endDate = DateTime.parse(posdate);
    startDateController.text = dateandtimepos;
    endDateController.text = dateandtimepos;

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

    final response = await http.get(Uri.parse('${apiUrl}report/cancelbill?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

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
      if (item['grandTotal'] != null) {
        total += double.tryParse(item['grandTotal'].toString()) ?? 0.0;
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

        if (startDate != null && endDate != null) {
          isLoading = true;
          fetchData();
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
              pw.Text('Cancel Bill Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                 'Bill No', 'Bill Date', 'Cancel Date', 'Created Time', 'Cancel Time',
                  'Amount', 'Created User', 'Cancel User', 'Bill Type'
                ],
                data: data.map((item) {
                  return [

                    item['bill_No'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['cancelDate'] ?? 'N/A',
                    item['createdTime'] ?? 'N/A',
                    item['cancelTime'] ?? 'N/A',
                    item['grandTotal'] ?? 'N/A',
                    item['createdUser'] ?? 'N/A',
                    item['cancelUser'] ?? 'N/A',
                    item['billType'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/cancel_bill_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      'Bill No', 'Bill Date', 'Cancel Date', 'Created Time',
      'Cancel Time', 'Amount', 'Created User',
      'Cancel User', 'Bill Type'
    ]);

    data.forEach((item) {
      sheetObject.appendRow([
        item['bill_No'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['cancelDate'] ?? 'N/A',
        item['createdTime'] ?? 'N/A',
        item['cancelTime'] ?? 'N/A',
        item['grandTotal'] ?? 'N/A',
        item['createdUser'] ?? 'N/A',
        item['cancelUser'] ?? 'N/A',
        item['billType'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/cancel_bill_data.xlsx';
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
    LayoutBuilder(
    builder: (context, constraints) {
    double containerWidth = constraints.maxWidth;
    double maxWidth = 300;
    double adjustedWidth = containerWidth > maxWidth ? maxWidth : containerWidth;

    return SizedBox(
    width: adjustedWidth,
    child: TextField(
    controller: startDateController,
    readOnly: true,
    decoration: InputDecoration(
    labelText: startDate != null ? DateFormat('dd-MM-yyyy').format(startDate!) : 'Start Date',
    hintText: 'Select Start Date',
    suffixIcon: IconButton(
    icon: const Icon(Icons.calendar_today),
    onPressed: () => _selectDate(context, true),
    ),
    ),
    ),
    );
    },
    ),
    const SizedBox(width: 16),
    LayoutBuilder(
    builder: (context, constraints) {
    double containerWidth = constraints.maxWidth;

    double maxWidth = 300;
    double adjustedWidth = containerWidth > maxWidth ? maxWidth : containerWidth;

    return SizedBox(
    width: adjustedWidth,
    child: TextField(
    controller: endDateController,
    readOnly: true,
    decoration: InputDecoration(
    labelText: endDate != null ? DateFormat('dd-MM-yyyy').format(endDate!) : 'End Date',
    hintText: 'Select End Date',
    suffixIcon: IconButton(
    icon: const Icon(Icons.calendar_today),
    onPressed: () => _selectDate(context, false),
    ),
    ),
    ),
    );
    },
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
                columnSpacing: 30.0,
                headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return Colors.black26;
                }),
                columns: const [
                  DataColumn(label: Text('Bill No', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Bill Date', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Cancel Date', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Created Time', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Cancel Time', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Amount', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Created User', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Cancel User', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Bill Type', style: TextStyle(color: Colors.black))),
                ],
                rows: [
                  ...data.map((item) {
                    return DataRow(cells: [
                      DataCell(Container(width: 80, child: Text(item['bill_No'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['billDate'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['cancelDate'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['createdTime'] ?? 'N/A'),)),
                      DataCell(Container(
                        width: 80, child: Text(item['cancelTime'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['grandTotal'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['createdUser'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['cancelUser'] ?? 'N/A'),)),
                      DataCell(Container(width: 80, child: Text(item['billType'] ?? 'N/A'),)),
                    ]);
                  }).toList(),
                  DataRow(cells: [
                    DataCell(Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold),)),

                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text(
                      '${calculateTotalAmount().toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                  ]),
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
                _showDialog(context, 'PDF File Saved', 'File saved at: $filePath');
                await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'cancel_bill_report.pdf');
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

