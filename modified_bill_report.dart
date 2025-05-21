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
  runApp(const ModifiedBill());
}

class ModifiedBill extends StatelessWidget {
  const ModifiedBill({Key? key}) : super(key: key);

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
              'Modified Bill',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: const ModifiedBillDataPage(),
        ),
      ),
    );
  }
}

class ModifiedBillDataPage extends StatefulWidget {
  const ModifiedBillDataPage({Key? key}) : super(key: key);

  @override
  _ModifiedBillDataPageState createState() => _ModifiedBillDataPageState();
}

class _ModifiedBillDataPageState extends State<ModifiedBillDataPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final dateFormat = 'dd-MM-yyyy';

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    startDateController.text = '${startDate.day}-${startDate.month}-${startDate.year}';
    endDateController.text = '${endDate.day}-${endDate.month}-${endDate.year}';

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
    String start = '${startDate.day}-${startDate.month}-${startDate.year}';
    String end = '${endDate.day}-${endDate.month}-${endDate.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/modifiedbill?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

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
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          startDateController.text = '${picked.day}-${picked.month}-${picked.year}';
        } else {
          endDate = picked;
          endDateController.text = '${picked.day}-${picked.month}-${picked.year}';
        }
      });

      fetchData();
    }
  }

  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Modified Bill Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Bill No', 'Bill Date', 'Entry Time', 'Modify Time', 'Original Amount', 'New Amount', 'Discount', 'User Created', 'User Edited', 'Remark'],
                data: data.map((item) {
                  return [
                    item['billNo'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['entryTime'] ?? 'N/A',
                    item['modifyTime'] ?? 'N/A',
                    item['originalAmount'] ?? 'N/A',
                    item['newAmount'] ?? 'N/A',
                    item['discount'] ?? 'N/A',
                    item['userCreated'] ?? 'N/A',
                    item['userEdited'] ?? 'N/A',
                    item['remark'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/modified_bill_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Bill No', 'Bill Date', 'Entry Time', 'Modify Time', 'Original Amount', 'New Amount', 'Discount', 'User Created', 'User Edited', 'Remark']);

    data.forEach((item) {
      sheetObject.appendRow([
        item['billNo'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['entryTime'] ?? 'N/A',
        item['modifyTime'] ?? 'N/A',
        item['originalAmount'] ?? 'N/A',
        item['newAmount'] ?? 'N/A',
        item['discount'] ?? 'N/A',
        item['userCreated'] ?? 'N/A',
        item['userEdited'] ?? 'N/A',
        item['remark'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/modified_bill_data.xlsx';
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

                  // Set the maximum width threshold (optional, tweak as needed)
                  double maxWidth = 300;
                  double adjustedWidth = containerWidth > maxWidth ? maxWidth : containerWidth;

                  return SizedBox(
                    width: adjustedWidth, // Apply the adjusted width
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
                  );
                },
              ),
              const SizedBox(width: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  double containerWidth = constraints.maxWidth;

                  // Set the maximum width threshold (optional, tweak as needed)
                  double maxWidth = 300;
                  double adjustedWidth = containerWidth > maxWidth ? maxWidth : containerWidth;

                  return SizedBox(
                    width: adjustedWidth, // Apply the adjusted width
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
                headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return Colors.black26;
                }),
                columns: const [
                  DataColumn(label: Text('Bill No')),
                  DataColumn(label: Text('Bill Date')),
                  DataColumn(label: Text('Entry Time')),
                  DataColumn(label: Text('Modify Time')),
                  DataColumn(label: Text('Original Amount')),
                  DataColumn(label: Text('New Amount')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('User Created')),
                  DataColumn(label: Text('User Edited')),
                  DataColumn(label: Text('Remark')),
                ],
                rows: data.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['billNo'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['billDate'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['entryTime'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['modifyTime'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['originalAmount']?.toString() ?? 'N/A', textAlign: TextAlign.right)),
                    DataCell(Text(item['newAmount']?.toString() ?? 'N/A', textAlign: TextAlign.right)),
                    DataCell(Text(item['discount']?.toString() ?? 'N/A', textAlign: TextAlign.right)),
                    DataCell(Text(item['userCreated'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['userEdited'] ?? 'N/A', textAlign: TextAlign.center)),
                    DataCell(Text(item['remark'] ?? 'N/A', textAlign: TextAlign.center)),
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
                await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'modified_bill_report.pdf');
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
