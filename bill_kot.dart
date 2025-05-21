import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import 'FireConstants.dart';

void main() {
  runApp(const BillKOTReport());
}

class BillKOTReport extends StatelessWidget {
  const BillKOTReport({Key? key}) : super(key: key);

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
              'Bill KOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: const BillKOTDataPage(),
        ),
      ),
    );
  }
}

class BillKOTDataPage extends StatefulWidget {
  const BillKOTDataPage({Key? key}) : super(key: key);

  @override
  _BillKOTDataPageState createState() => _BillKOTDataPageState();
}

class _BillKOTDataPageState extends State<BillKOTDataPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    String startDateFormatted = '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
    String endDateFormatted = '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/billkot?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

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
    final DateTime initialDate = isStartDate ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        fetchData();
      });
    }
  }
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Bill KOT Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['KOT ID', 'Operation', 'Date', 'Time', 'Bill No', 'Product', 'Quantity', 'Table Number', 'Waiter', 'Remarks', 'User Name'],
                data: data.map((item) {
                  return [
                    item['kotId'] ?? 'N/A',
                    item['operation'] ?? 'N/A',
                    item['date'] ?? 'N/A',
                    item['time'] ?? 'N/A',
                    item['billNo'] ?? 'N/A',
                    item['product'] ?? 'N/A',
                    item['qty'] ?? '0',
                    item['tableNumber'] ?? 'N/A',
                    item['waiter'] ?? 'N/A',
                    item['remarks'] ?? 'N/A',
                    item['userName'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/bill_kot_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['KOT ID', 'Operation', 'Date', 'Time', 'Bill No', 'Product', 'Quantity', 'Table Number', 'Waiter', 'Remarks', 'User Name']);
    data.forEach((item) {
      sheetObject.appendRow([
        item['kotId'] ?? 'N/A',
        item['operation'] ?? 'N/A',
        item['date'] ?? 'N/A',
        item['time'] ?? 'N/A',
        item['billNo'] ?? 'N/A',
        item['product'] ?? 'N/A',
        item['qty'] ?? '0',
        item['tableNumber'] ?? 'N/A',
        item['waiter'] ?? 'N/A',
        item['remarks'] ?? 'N/A',
        item['userName'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/bill_kot_data.xlsx';
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    return file;
  }

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
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: _formatDate(startDate),
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
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: _formatDate(endDate),
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
                  DataColumn(label: Text('KOT ID')),
                  DataColumn(label: Text('Operation')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Bill No')),
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Table Number')),
                  DataColumn(label: Text('Waiter')),
                  DataColumn(label: Text('Remarks')),
                  DataColumn(label: Text('User Name')),
                ],
                rows: data.map<DataRow>((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['kotId'] ?? 'N/A')),
                    DataCell(Text(item['operation'] ?? 'N/A')),
                    DataCell(Text(item['date'] ?? 'N/A')),
                    DataCell(Text(item['time'] ?? 'N/A')),
                    DataCell(Text(item['billNo'] ?? 'N/A')),
                    DataCell(Text(item['product'] ?? 'N/A')),
                    DataCell(Text(item['qty'] ?? '0')),
                    DataCell(Text(item['tableNumber'] ?? 'N/A')),
                    DataCell(Text(item['waiter'] ?? 'N/A')),
                    DataCell(Text(item['remarks'] ?? 'N/A')),
                    DataCell(Text(item['userName'] ?? 'N/A')),
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
                await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'bill_kot_report.pdf');
              },
              label: const Text('Export to PDF', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              backgroundColor: Colors.red,
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                final excelFile = await generateExcel(data);
                await OpenFile.open(excelFile.path);
                _showDialog(context, 'Report Successfully Exported', 'File saved at: ${excelFile.path}');
              },
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
