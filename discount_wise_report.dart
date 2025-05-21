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
  runApp(const DiscountwiseReport());
}

class DiscountwiseReport extends StatelessWidget {
  const DiscountwiseReport({Key? key}) : super(key: key);

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
              'Discount Report',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: const DiscountDataPage(),
        ),
      ),
    );
  }
}

class DiscountDataPage extends StatefulWidget {
  const DiscountDataPage({Key? key}) : super(key: key);

  @override
  _DiscountDataPageState createState() => _DiscountDataPageState();
}

class _DiscountDataPageState extends State<DiscountDataPage> {
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

    final response = await http.get(Uri.parse('${apiUrl}report/discountwise?startDate=$start&endDate=$end&DB=$CLIENTCODE'));

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

  double calculateTotalDiscount() {
    double total = 0;
    for (var item in data) {
      if (item['discountAmount'] != null) {
        total += double.tryParse(item['discountAmount'].toString()) ?? 0.0;
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
  }
  double calculateTotal(String key) {
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
              pw.Text('Discountwise Report', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 10),
                headers: ['S/No', 'Bill No', 'Bill Date', 'Amount', 'Discount', 'Net Amount', 'Discount Percent', 'Discount On Amt', 'Remark'],
                data: data.asMap().entries.map((entry) {
                  int index = entry.key + 1; // Starting index from 1
                  var item = entry.value;
                  return [
                    index.toString(),
                    item['billNo'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['amount'] ?? 'N/A',
                    item['discount'] ?? 'N/A',
                    item['netAmount'] ?? 'N/A',
                    item['discountPercent'] ?? 'N/A',
                    item['discountOnAmt'] ?? 'N/A',
                    item['remark'] ?? 'N/A',
                  ];
                }).toList()
                  ..add([
                    'Total',
                    '',
                    '',
                    calculateTotal('amount').toStringAsFixed(2),
                    calculateTotal('discount').toStringAsFixed(2),
                    calculateTotal('netAmount').toStringAsFixed(2),
                    '',
                    calculateTotal('discountOnAmt').toStringAsFixed(2),
                    '',
                  ]),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/discountwise_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['S/No', 'Bill No', 'Bill Date', 'Amount', 'Discount', 'Net Amount', 'Discount Percent', 'Discount On Amt', 'Remark']);

    data.asMap().entries.forEach((entry) {
      int index = entry.key + 1; // Starting index from 1
      var item = entry.value;
      sheetObject.appendRow([
        index.toString(),
        item['billNo'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['amount'] ?? 'N/A',
        item['discount'] ?? 'N/A',
        item['netAmount'] ?? 'N/A',
        item['discountPercent'] ?? 'N/A',
        item['discountOnAmt'] ?? 'N/A',
        item['remark'] ?? 'N/A',
      ]);
    });

    // Add the Total Row
    sheetObject.appendRow([
      'Total',
      '',
      '',
      calculateTotal('amount').toStringAsFixed(2),
      calculateTotal('discount').toStringAsFixed(2),
      calculateTotal('netAmount').toStringAsFixed(2),
      '',
      calculateTotal('discountOnAmt').toStringAsFixed(2),
      '',
    ]);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/discountwise_report.xlsx';
    final file = File(path);
    await file.writeAsBytes(await excel.encode()!);

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
                        labelText: 'Start Date',

                        hintText: 'Select Start Date',
                        prefixIcon: IconButton(            // Calendar icon on the left
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true), // Start date picker
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
                        labelText: 'End Date',
                        hintText: 'Select End Date',
                        prefixIcon: IconButton(           // Calendar icon on the left
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, false), // End date picker
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
              ? const Center(child: CircularProgressIndicator())
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
                  DataColumn(label: Text('S/No', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Bill No', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Bill Date', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Sub Total', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Discount', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Net Amount', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Discount Percent', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Discount On Amt', style: TextStyle(color: Colors.black, fontSize: 16))),
                  DataColumn(label: Text('Remark', style: TextStyle(color: Colors.black, fontSize: 16))),
                ],
                rows: data.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(index.toString(), style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['billNo'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['billDate'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['amount'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['discount'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['netAmount'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['discountPercent'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['discountOnAmt'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                    DataCell(Text(item['remark'] ?? 'N/A', style: const TextStyle(fontSize: 14))),
                  ]);
                }).toList()
                  ..add(DataRow(cells: [
                    const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    const DataCell(Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    const DataCell(Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    DataCell(Text(calculateTotal('amount').toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    DataCell(Text(calculateTotal('discount').toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    DataCell(Text(calculateTotal('netAmount').toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    const DataCell(Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    DataCell(Text(calculateTotal('discountOnAmt').toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    const DataCell(Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  ])),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final filePath = await exportToPdf(context);
                  _showDialog(context, 'PDF File Saved', 'File saved at: $filePath');
                  await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'discountwise_report.pdf');
                },
                child: const Text('Export to PDF'),
              ),
              ElevatedButton(
                onPressed: () => _createExcelAndSave(context),
                child: const Text('Export to Excel'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
