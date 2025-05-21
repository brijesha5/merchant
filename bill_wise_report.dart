import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'FireConstants.dart';

void main() {
  runApp(const Billwise());
}

class Billwise extends StatelessWidget {
  const Billwise({Key? key}) : super(key: key);

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
              'Bill Wise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: const BillwiseDataPage(),
        ),
      ),
    );
  }
}

class BillwiseDataPage extends StatefulWidget {
  const BillwiseDataPage({Key? key}) : super(key: key);

  @override
  _BillwiseDataPageState createState() => _BillwiseDataPageState();
}

class _BillwiseDataPageState extends State<BillwiseDataPage> {
  List<dynamic> data = [];
  bool isLoading = false;
  String errorMessage = '';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    String startDateFormatted = '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
    String endDateFormatted = '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/billwise?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

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
      });

      fetchData();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  double _calculateTotal(String column) {
    double total = 0;
    for (var item in data) {
      double value = double.tryParse(item[column]?.toString() ?? '0') ?? 0;
      total += value;

      // Debugging log to check values and running total
      print('Column: $column, Item: $item, Value: $value, Running Total: $total');
    }
    return total;
  }

  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Billwise Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Ser No', 'Bill No', 'Bill Date', 'Subtotal', 'Discount Amount',
                  'Net Amount', 'Tax Amount', 'Grand Total', 'Settlement Mode',
                  'Customer Name', 'Remark', 'Delivery Charges', 'Discount Percent', 'Packaging Charge'
                ],
                data: data.map((item) {
                  return [
                    'N/A',
                    item['billNo'] ?? 'N/A',
                    item['billDate'] ?? 'N/A',
                    item['subtotal'] ?? '0.00',
                    item['billDiscount'] ?? '0.00',
                    item['netTotal'] ?? '0.00',
                    item['billTax'] ?? '0.00',
                    item['grandAmount'] ?? '0.00',
                    item['settlementModeName'] ?? 'N/A',
                    item['customerName'] ?? 'N/A',
                    item['remark'] ?? 'N/A',
                    item['deliveryCharges'] ?? '0.00',
                    item['discountPercent'] ?? '0.00',
                    item['packagingCharge'] ?? '0.00'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Total', '', '', '', '', '', '', '', '', '', '', '', '', ''],
                data: [
                  [
                    '',
                    '',
                    '',
                    formatter.format(_calculateTotal('subtotal')),
                    formatter.format(_calculateTotal('billDiscount')),
                    formatter.format(_calculateTotal('netTotal')),
                    formatter.format(_calculateTotal('billTax')),
                    formatter.format(_calculateTotal('grandAmount')),
                    '',
                    '',
                    '',
                    '',
                    '',
                  ]
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/billwise_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      'Ser No', 'Bill No', 'Bill Date', 'Subtotal', 'Discount Amount',
      'Net Amount', 'Tax Amount', 'Grand Total', 'Settlement Mode',
      'Customer Name', 'Remark', 'Delivery Charges', 'Discount Percent', 'Packaging Charge'
    ]);

    data.forEach((item) {
      sheetObject.appendRow([
        'N/A',
        item['billNo'] ?? 'N/A',
        item['billDate'] ?? 'N/A',
        item['subtotal'] ?? '0.00',
        item['billDiscount'] ?? '0.00',
        item['netTotal'] ?? '0.00',
        item['billTax'] ?? '0.00',
        item['grandAmount'] ?? '0.00',
        item['settlementModeName'] ?? 'N/A',
        item['customerName'] ?? 'N/A',
        item['remark'] ?? 'N/A',
        item['deliveryCharges'] ?? '0.00',
        item['discountPercent'] ?? '0.00',
        item['packagingCharge'] ?? '0.00'
      ]);
    });

    sheetObject.appendRow([
      'Total',
      '',
      '',
      formatter.format(_calculateTotal('subtotal')),
      formatter.format(_calculateTotal('billDiscount')),
      formatter.format(_calculateTotal('netTotal')),
      formatter.format(_calculateTotal('billTax')),
      formatter.format(_calculateTotal('grandAmount')),
      '',
      '',
      '',
      '',
      '',
    ]);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/billwise_report.xlsx';
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    return file;
  }

  Future<void> _createExcelAndSave(BuildContext context) async {
    final excelFile = await generateExcel(data);
    await OpenFile.open(excelFile.path);
    _showDialog(context, 'Report Successfully Exported', 'File saved at: ${excelFile.path}');
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
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _formatDate(startDate),
                        prefixIcon: IconButton(
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
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _formatDate(endDate),
                        prefixIcon: IconButton(
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Ser No')),
                      DataColumn(label: Text('Bill No')),
                      DataColumn(label: Text('Bill Date')),
                      DataColumn(label: Text('Subtotal')),
                      DataColumn(label: Text('Discount Amount')),
                      DataColumn(label: Text('Net Amount')),
                      DataColumn(label: Text('Tax Amount')),
                      DataColumn(label: Text('Grand Total')),
                      DataColumn(label: Text('Settlement Mode')),
                      DataColumn(label: Text('Customer Name')),
                      DataColumn(label: Text('Remark')),
                      DataColumn(label: Text('Delivery Charges')),
                      DataColumn(label: Text('Discount Percent')),
                      DataColumn(label: Text('Packaging Charge')),
                    ],
                    rows: [
                      ...data.asMap().entries.map<DataRow>((entry) {
                        int index = entry.key + 1;
                        var item = entry.value;

                        return DataRow(cells: [
                          DataCell(Text(index.toString())),
                          DataCell(Text(item['billNo'] ?? 'N/A')),
                          DataCell(Text(item['billDate'] ?? 'N/A')),
                          DataCell(Text(item['subtotal'] ?? '0.00')),
                          DataCell(Text(item['billDiscount'] ?? '0.00')),
                          DataCell(Text(item['netTotal'] ?? '0.00')),
                          DataCell(Text(item['billTax'] ?? '0.00')),
                          DataCell(Text(item['grandAmount'] ?? '0.00')),
                          DataCell(Text(item['settlementModeName'] ?? 'N/A')),
                          DataCell(Text(item['customerName'] ?? 'N/A')),
                          DataCell(Text(item['remark'] ?? 'N/A')),
                          DataCell(Text(item['deliveryCharges'] ?? '0.00')),
                          DataCell(Text(item['discountPercent'] ?? '0.00')),
                          DataCell(Text(item['packagingCharge'] ?? '0.00')),
                        ]);
                      }).toList(),
                      DataRow(cells: [
                        DataCell(Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        )),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text(
                          formatter.format(_calculateTotal('subtotal')), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                        DataCell(Text(formatter.format(_calculateTotal('billDiscount')), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                        DataCell(Text(formatter.format(_calculateTotal('netTotal')), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                        DataCell(Text(formatter.format(_calculateTotal('billTax')), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                        DataCell(Text(formatter.format(_calculateTotal('grandAmount')), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _createExcelAndSave(context),
                    child: const Text('Export to Excel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final pdfPath = await exportToPdf(context);
                      _showDialog(context, 'Report Exported', 'PDF saved at: $pdfPath');
                    },
                    child: const Text('Export to PDF'),
                  ),
                ],
              ),
            ),
          ],

    );
  }

}
