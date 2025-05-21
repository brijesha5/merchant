import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import 'FireConstants.dart'; // Ensure your constants are included here

void main() {
  runApp(const MoveKOTReport());
}

class MoveKOTReport extends StatelessWidget {
  const MoveKOTReport({Key? key}) : super(key: key);

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
              'Move KOT',  // The text you want to display
              style: TextStyle(
                color: Colors.white,  // Text color
                fontSize: 20,  // Font size
                fontWeight: FontWeight.bold,  // Font weight
              ),
            ),
            centerTitle: true,  // Centers the title in the AppBar
          ),
          body: const MoveKOTDataPage(),
        ),
      ),
    );
  }
}

class MoveKOTDataPage extends StatefulWidget {
  const MoveKOTDataPage({Key? key}) : super(key: key);

  @override
  _MoveKOTDataPageState createState() => _MoveKOTDataPageState();
}

class _MoveKOTDataPageState extends State<MoveKOTDataPage> {
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
    // Set the default start and end date to the current date
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

    final response = await http.get(Uri.parse('${apiUrl}report/movekot?startDate=$startDateFormatted&endDate=$endDateFormatted&DB=$CLIENTCODE'));

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
        // Automatically fetch the data when the date is changed
        fetchData();
      });
    }
  }

  // Format the date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Export data to PDF
  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Move KOT Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['KOT ID', 'Quantity', 'Reason', 'User', 'Cancel Date', 'Rate', 'Waiter Name', 'Product'],
                data: data.map((item) {
                  return [
                    item['kotId'] ?? 'N/A',
                    item['qty'] ?? '0',
                    item['reason'] ?? 'N/A',
                    item['user'] ?? 'N/A',
                    item['cancelDate'] ?? 'N/A',
                    item['rate'] ?? '0.00',
                    item['waiterName'] ?? 'N/A',
                    item['product'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/move_kot_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // Generate Excel file
  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add header row
    sheetObject.appendRow(['KOT ID', 'Quantity', 'Reason', 'User', 'Cancel Date', 'Rate', 'Waiter Name', 'Product']);

    // Add data rows
    data.forEach((item) {
      sheetObject.appendRow([
        item['kotId'] ?? 'N/A',
        item['qty'] ?? '0',
        item['reason'] ?? 'N/A',
        item['user'] ?? 'N/A',
        item['cancelDate'] ?? 'N/A',
        item['rate'] ?? '0.00',
        item['waiterName'] ?? 'N/A',
        item['product'] ?? 'N/A',
      ]);
    });

    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/move_kot_data.xlsx';
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    return file;
  }

  // Export data to Excel
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
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('KOT ID')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Cancel Date')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Waiter Name')),
                  DataColumn(label: Text('Product')),
                ],
                rows: data.map<DataRow>((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['kotId'] ?? 'N/A')),
                    DataCell(Text(item['qty'] ?? '0')),
                    DataCell(Text(item['reason'] ?? 'N/A')),
                    DataCell(Text(item['user'] ?? 'N/A')),
                    DataCell(Text(item['cancelDate'] ?? 'N/A')),
                    DataCell(Text(item['rate'] ?? '0.00')),
                    DataCell(Text(item['waiterName'] ?? 'N/A')),
                    DataCell(Text(item['product'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                final pdfPath = await exportToPdf(context);
                await OpenFile.open(pdfPath);
                _showDialog(context, 'Report Successfully Exported', 'PDF saved at: $pdfPath');
              },
              child: const Text('Export to PDF'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _createExcelAndSave(context);
              },
              child: const Text('Export to Excel'),
            ),
          ],
        ),
      ],
    );
  }
}
