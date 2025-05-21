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
  runApp(const CancelKot());
}

class CancelKot extends StatelessWidget {
  const CancelKot({Key? key}) : super(key: key);

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
              'Cancel KOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: const CancelKotDataPage(),
        ),
      ),
    );
  }
}

class CancelKotDataPage extends StatefulWidget {
  const CancelKotDataPage({Key? key}) : super(key: key);

  @override
  _CancelKotDataPageState createState() => _CancelKotDataPageState();
}

class _CancelKotDataPageState extends State<CancelKotDataPage> {
  List<dynamic> data = [];
  bool isLoading = false;
  String errorMessage = '';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    DateTime posDateTime = DateTime.parse(posdate);
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    String formattedDate = dateFormat.format(posDateTime);

    setState(() {
      startDate = posDateTime;
      endDate = posDateTime;
    });
    startDateController.text = formattedDate;
    endDateController.text = formattedDate;

    fetchData();

  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    String startDateFormatted = '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
    String endDateFormatted = '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/cancelkot?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

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

  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Cancel KOT Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Ser No', 'KOT ID', 'Status', 'Cancel Time', 'Cancel Date',
                  'Table Number'
                ],
                data: data.map((item) {
                  return [
                    'N/A',
                    item['kot_ID'] ?? 'N/A',
                    item['status'] ?? 'N/A',
                    item['order_Time'] ?? 'N/A',
                    item['order_Date'] ?? 'N/A',
                    item['table_Number'] ?? 'N/A',
                    item['item_Names'] ?? 'N/A',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/cancel_kot_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
  Future<File> generateExcel(List<dynamic> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      'Ser No', 'KOT ID', 'Status', 'Cancel Time', 'Cancel Date',
      'Table Number','Item_Name'
    ]);

    data.forEach((item) {
      sheetObject.appendRow([
        'N/A',
        item['kot_ID'] ?? 'N/A',
        item['status'] ?? 'N/A',
        item['order_Time'] ?? 'N/A',
        item['order_Date'] ?? 'N/A',
        item['table_Number'] ?? 'N/A',
        item['item_Names'] ?? 'N/A',
      ]);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/cancel_kot_report.xlsx';
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

                  return Material(
                    child: SizedBox(
                      width: adjustedWidth,
                      child: TextField(
                        controller: startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: _formatDate(startDate),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, true),
                          ),
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

                  return Material(
                    child: SizedBox(
                      width: adjustedWidth,
                      child: TextField(
                        controller: endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: _formatDate(endDate),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, false),
                          ),
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
                  DataColumn(label: Text('KOT ID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Cancel Time')),
                  DataColumn(label: Text('Cancel Date')),
                  DataColumn(label: Text('Table Number')),
                  DataColumn(label: Text('Item Name')),
                ],
                rows: [
                  ...data.asMap().entries.map<DataRow>((entry) {
                    int index = entry.key + 1;
                    var item = entry.value;

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(item['kot_ID'] ?? 'N/A')),
                      DataCell(Text(item['status'] ?? 'N/A')),
                      DataCell(Text(item['order_Time'] ?? 'N/A')),
                      DataCell(Text(item['order_Date'] ?? 'N/A')),
                      DataCell(Text(item['table_Number'] ?? 'N/A')),
                      DataCell(Text(item['item_Names'] ?? 'N/A')),
                    ]);
                  }).toList(),
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