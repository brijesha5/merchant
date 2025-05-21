import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import 'FireConstants.dart'; // Make sure to have your constants here

void main() {
  runApp(const TimeAuditReport());
}

class TimeAuditReport extends StatelessWidget {
  const TimeAuditReport({Key? key}) : super(key: key);

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
              'Time Audit',  // The text you want to display
              style: TextStyle(
                color: Colors.white,  // Text color
                fontSize: 20,  // Font size
                fontWeight: FontWeight.bold,  // Font weight
              ),
            ),
            centerTitle: true,  // Centers the title in the AppBar
          ),
          body: const TimeAuditDataPage(),
        ),
      ),
    );
  }
}

class TimeAuditDataPage extends StatefulWidget {
  const TimeAuditDataPage({Key? key}) : super(key: key);

  @override
  _TimeAuditDataPageState createState() => _TimeAuditDataPageState();
}

class _TimeAuditDataPageState extends State<TimeAuditDataPage> {
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
    // Set default date to today's date
    DateTime today = DateTime.now();
    startDate = today;
    endDate = today;
    startDateController.text = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
    endDateController.text = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

    fetchData();
  }

  // Show a dialog box for feedback
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: const [],
        );
      },
    );
  }

  // Fetch data based on the selected date range
  Future<void> fetchData() async {
    if (startDate == null || endDate == null) {
      _showDialog(context, 'Input Error', 'Please select both start and end dates.');
      return;
    }

    String startDateFormatted = '${startDate!.day.toString().padLeft(2, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.year}';
    String endDateFormatted = '${endDate!.day.toString().padLeft(2, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/timeaudit?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

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

  // Select the date using the date picker
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
        // Automatically fetch data after date change
        fetchData();
      });
    }
  }

  // Export to PDF
  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Time Audit Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Bill No', 'Table No', 'KOT Time', 'Bill Date', 'Bill Time', 'Settle Date', 'Settle Time', 'User Created', 'User Edited', 'Remarks', 'Time Difference', 'Total Amount', 'Settlement Mode'],
                data: data.map((item) {
                  return [
                    item['billNo'] ?? 'N/A',
                    item['tableNo'] ?? 'N/A',
                    item['kotTime'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['billTime'] ?? 'N/A',
                    item['settleDate'] ?? 'N/A',
                    item['settleTime'] ?? 'N/A',
                    item['userCreated'] ?? 'N/A',
                    item['userEdited'] ?? 'N/A',
                    item['remarks'] ?? 'N/A',
                    item['timeDifference'] ?? '0',
                    item['billAmount'] ?? '0.00',
                    item['settlementMode'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/time_audit_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // Generate Excel file
  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add header row
    sheetObject.appendRow(['Bill No', 'Table No', 'KOT Time', 'Bill Date', 'Bill Time', 'Settle Date', 'Settle Time', 'User Created', 'User Edited', 'Remarks', 'Time Difference', 'Total Amount', 'Settlement Mode']);

    // Add data rows
    data.forEach((item) {
      sheetObject.appendRow([
        item['billNo'] ?? 'N/A',
        item['tableNo'] ?? 'N/A',
        item['kotTime'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['billTime'] ?? 'N/A',
        item['settleDate'] ?? 'N/A',
        item['settleTime'] ?? 'N/A',
        item['userCreated'] ?? 'N/A',
        item['userEdited'] ?? 'N/A',
        item['remarks'] ?? 'N/A',
        item['timeDifference'] ?? '0',
        item['billAmount'] ?? '0.00',
        item['settlementMode'] ?? 'N/A',
      ]);
    });

    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/time_audit_data.xlsx';
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    return file;
  }

  // Export to Excel
  Future<void> _createExcelAndSave(BuildContext context) async {
    final excelFile = await generateExcel(data);
    await OpenFile.open(excelFile.path);
    _showDialog(context, 'Report Successfully Exported', 'File saved at: ${excelFile.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
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
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Bill No')),
                  DataColumn(label: Text('Table No')),
                  DataColumn(label: Text('KOT Time')),
                  DataColumn(label: Text('Bill Date')),
                  DataColumn(label: Text('Bill Time')),
                  DataColumn(label: Text('Settle Date')),
                  DataColumn(label: Text('Settle Time')),
                  DataColumn(label: Text('User Created')),
                  DataColumn(label: Text('User Edited')),
                  DataColumn(label: Text('Remarks')),
                  DataColumn(label: Text('Time Difference')),
                  DataColumn(label: Text('Total Amount')),
                  DataColumn(label: Text('Settlement Mode')),
                ],
                rows: data.map<DataRow>((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['billNo'] ?? 'N/A')),
                    DataCell(Text(item['tableNo'] ?? 'N/A')),
                    DataCell(Text(item['kotTime'] ?? 'N/A')),
                    DataCell(Text(item['billDate'] ?? 'N/A')),
                    DataCell(Text(item['billTime'] ?? 'N/A')),
                    DataCell(Text(item['settleDate'] ?? 'N/A')),
                    DataCell(Text(item['settleTime'] ?? 'N/A')),
                    DataCell(Text(item['userCreated'] ?? 'N/A')),
                    DataCell(Text(item['userEdited'] ?? 'N/A')),
                    DataCell(Text(item['remarks'] ?? 'N/A')),
                    DataCell(Text(item['timeDifference'] ?? '0')),
                    DataCell(Text(item['billAmount'] ?? '0.00')),
                    DataCell(Text(item['settlementMode'] ?? 'N/A')),
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
                await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'time_audit_report.pdf');
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
