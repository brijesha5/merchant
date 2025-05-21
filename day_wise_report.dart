import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

import 'FireConstants.dart'; // For formatting the date

void main() {
  runApp(const ReportsScreenNew());
}

class ReportsScreenNew extends StatefulWidget {
  const ReportsScreenNew({super.key});

  @override
  _ReportsScreenNewState createState() => _ReportsScreenNewState();
}

class _ReportsScreenNewState extends State<ReportsScreenNew> {
  // Declare TextEditingControllers for start and end date
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();

    String startDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String endDate = DateFormat('dd-MM-yyyy').format(DateTime.now());



  @override
  void initState() {
    super.initState();

    DateTime posDateTime = DateTime.parse(posdate);
    String formattedDate = DateFormat('dd-MM-yyyy').format(posDateTime);

    setState(() {
      startDate = formattedDate;
      endDate = formattedDate;
    });

    startDateController.text = formattedDate;
    endDateController.text = formattedDate;
  }

  void displayMessage(String msg, BuildContext context, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context).pop();
          OpenFile.open(filePath);
        });

        final backgroundColor = Colors.white.withOpacity(0.7);
        return AlertDialog(
          backgroundColor: backgroundColor,
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
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: const [],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        if (isStartDate) {
          startDate = DateFormat('dd-MM-yyyy').format(selected);
          startDateController.text = startDate;
        } else {
          endDate = DateFormat('dd-MM-yyyy').format(selected);
          endDateController.text = endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD5282B),
          title: const Text('Day Wise Report', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            alignment: Alignment.topLeft,
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => ReportsScreenNew()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range, color: Colors.white),
              onPressed: () => _selectDate(context, true),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '$startDate - $endDate',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.date_range, color: Colors.white),
              onPressed: () => _selectDate(context, false),
            ),
          ],
        ),
        body: BillTableScreen(startDate: startDate, endDate: endDate),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton.extended(
              onPressed: () async {
                final bills = await fetchBills(startDate, endDate);
                final excelFile = await generateExcel(bills);
                displayMessage('Report Successfully Exported To \n ${excelFile.path}', context, excelFile.path);
              },
              label: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.grid_on, color: Colors.white),
              backgroundColor: Colors.green,
              heroTag: null,
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: () async {
                final bills = await fetchBills(startDate, endDate);
                final pdfPath = await generatePdf(bills);
                displayMessage('Report Successfully Exported To \n $pdfPath', context, pdfPath);
              },
              label: const Text('Export to PDF', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              backgroundColor: Colors.red,
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }
}


class BillTableScreen extends StatefulWidget {
  final String startDate;
  final String endDate;

  const BillTableScreen({super.key, required this.startDate, required this.endDate});

  @override
  _BillTableScreenState createState() => _BillTableScreenState();
}

class _BillTableScreenState extends State<BillTableScreen> {
  late Future<List<Billl>> futureBills;

  @override
  void initState() {
    super.initState();
    futureBills = fetchBills(widget.startDate, widget.endDate);
  }

  @override
  void didUpdateWidget(covariant BillTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate || widget.endDate != oldWidget.endDate) {
      futureBills = fetchBills(widget.startDate, widget.endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Billl>>(
      future: futureBills,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BillTable(jsonData: snapshot.data!),
              ),
            ),
          );
        }
      },
    );
  }
}

Future<List<Billl>> fetchBills(String startDate, String endDate) async {
  final response = await http.get(Uri.parse('${apiUrl}report/daywise?startDate=$startDate&endDate=$endDate&DB=$CLIENTCODE'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Billl.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load bills');
  }
}

class Billl {
  final String billDate;
  final String billTotal;
  final String billTax;
  final String noOfBills;

  Billl({required this.billDate, required this.billTotal, required this.billTax, required this.noOfBills});

  factory Billl.fromJson(Map<String, dynamic> json) {
    return Billl(
      billDate: json['billDate'],
      billTotal: json['billTotal'],
      billTax: json['billTax'],
      noOfBills: json['noOfBills'],
    );
  }
}

class BillTable extends StatelessWidget {
  final List<Billl> jsonData;
  const BillTable({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Bill Date')),
        DataColumn(label: Text('Bill Total')),
        DataColumn(label: Text('Bill Tax')),
        DataColumn(label: Text('No. of Bills')),
      ],
      rows: jsonData.map((bill) {
        return DataRow(
          cells: [
            DataCell(Text(bill.billDate, textAlign: TextAlign.center)),
            DataCell(Text(bill.billTotal, textAlign: TextAlign.right)),
            DataCell(Text(bill.billTax, textAlign: TextAlign.right)),
            DataCell(Text(bill.noOfBills, textAlign: TextAlign.center)),
          ],
        );
      }).toList(),
    );
  }
}
Future<String> generatePdf(List<Billl> bills) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          headers: ['Bill Date', 'Bill Total', 'Bill Tax', 'No. of Bills'],
          data: bills.map((bill) {
            return [bill.billDate, bill.billTotal, bill.billTax, bill.noOfBills];
          }).toList(),
        );
      },
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/daywise_report.pdf';
  final file = File(path);
  await file.writeAsBytes(await pdf.save());

  return path;
}

Future<File> generateExcel(List<Billl> bills) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];

  sheetObject.appendRow(['Bill Date', 'Bill Total', 'Bill Tax', 'No. of Bills']);

  bills.forEach((bill) {
    sheetObject.appendRow([
      bill.billDate,
      bill.billTotal,
      bill.billTax,
      bill.noOfBills,
    ]);
  });

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/daywise_report.xlsx';
  final file = File(path);
  file.writeAsBytesSync(excel.encode()!);

  return file;
}
