import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'FireConstants.dart'; // Ensure to add this import for PDF sharing

void main() {
  runApp(const Itemwise());
}

class Itemwise extends StatelessWidget {
  const Itemwise({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          Navigator.of(context).pop();
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
              'Itemwise',  // The text you want to display
              style: TextStyle(
                color: Colors.white,  // Text color
                fontSize: 20,  // Font size
                fontWeight: FontWeight.bold,  // Font weight
              ),
            ),
            centerTitle: true,  // Centers the title in the AppBar
          ),
          body: const ItemwiseDataPage(),
          floatingActionButton: const ExportButtons(),
        ),
      ),
    );
  }
}

class ExportButtons extends StatelessWidget {
  const ExportButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              final filePath = await _ItemwiseDataPageState().exportReport(context, ReportType.pdf);
              _showDialog(context, 'File Saved', 'File saved at: $filePath');
              await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'itemwise_report.pdf');
            },
            label: const Text('Export to PDF', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            backgroundColor: Colors.red,
          ),
          FloatingActionButton.extended(
            onPressed: () async {
              final filePath = await _ItemwiseDataPageState().exportReport(context, ReportType.excel);
              _showDialog(context, 'File Saved', 'File saved at: $filePath');

              XFile xFile = XFile(filePath);
              await Share.shareXFiles([xFile], text: 'Here is the itemwise report');
            },
            label: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.grid_on, color: Colors.white),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context).pop();
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
          actions: const [],
        );
      },
    );
  }
}

enum ReportType { pdf, excel }

class ItemwiseDataPage extends StatefulWidget {
  const ItemwiseDataPage({Key? key}) : super(key: key);

  @override
  _ItemwiseDataPageState createState() => _ItemwiseDataPageState();
}

class _ItemwiseDataPageState extends State<ItemwiseDataPage> {
  static List<dynamic> data = [];
  bool isLoading = false;
  String errorMessage = '';

  DateTime startDate = DateTime.now();  // Default start date is today
  DateTime endDate = DateTime.now();    // Default end date is today

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data based on selected date range (startDate, endDate)
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    // Format dates to 'dd-MM-yyyy' format
    String startDateFormatted = '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
    String endDateFormatted = '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/itemwise?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

    if (response.statusCode == 200) {
      try {
        final responseBody = response.body;

        if (responseBody.isEmpty) {
          setState(() {
            isLoading = false;
            errorMessage = 'Error: Empty response from server.';
          });
          return;
        }

        final jsonData = json.decode(responseBody);
        setState(() {
          data = jsonData;
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

  // Function to open date picker
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

      fetchData(); // Fetch data after selecting the date range
    }
  }

  // Format date to 'dd-MM-yyyy' for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Export report (either PDF or Excel)
  Future<String> exportReport(BuildContext context, ReportType reportType) async {
    if (reportType == ReportType.pdf) {
      return await exportToPdf(context);
    } else if (reportType == ReportType.excel) {
      return await exportToExcel(context);
    } else {
      throw Exception('Unsupported report type');
    }
  }

  // Export data to PDF
  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Item Wise Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Product Code', 'Total Qnt Sold', 'Total Sale Amount'],
                data: data.map((item) {
                  return [
                    item['productCode'] ?? 'N/A',
                    item['totalQntSold'] ?? 'N/A',
                    item['totalSaleAmount'] ?? 'N/A'
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/itemwise_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // Export data to Excel
  Future<String> exportToExcel(BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add headers
    sheetObject.appendRow(['Product Code', 'Total Qnt Sold', 'Total Sale Amount']);

    // Ensure data is unique before appending
    var uniqueData = <Map<String, dynamic>>[];
    for (var item in data) {
      if (!uniqueData.any((element) => element['productCode'] == item['productCode'])) {
        uniqueData.add(item); // Add only unique product codes
      }
    }

    // Append data to Excel file
    for (var item in uniqueData) {
      sheetObject.appendRow([
        item['productCode'] ?? 'N/A',
        item['totalQntSold'] ?? 'N/A',
        item['totalSaleAmount'] ?? 'N/A'
      ]);
    }

    // Save to file
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/itemwise_data.xlsx';
    final file = File(path);
    file.writeAsBytesSync(await excel.encode()!);

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centering the row content
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
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _formatDate(startDate), // Date will be on the right side
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

                  // Set the maximum width threshold (optional, tweak as needed)
                  double maxWidth = 300;
                  double adjustedWidth = containerWidth > maxWidth ? maxWidth : containerWidth;

                  return SizedBox(
                    width: adjustedWidth, // Apply the adjusted width
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _formatDate(endDate), // Date will be on the right side
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
        // Center the loading spinner if data is being fetched
        isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading spinner in the center
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage)) // Show error message in the center
            : Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product Code')),
                DataColumn(label: Text('Total Qnt Sold')),
                DataColumn(label: Text('Total Sale Amount'))
              ],
              rows: data.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['productCode'] ?? 'N/A')),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text(item['totalQntSold'] ?? 'N/A'),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text(item['totalSaleAmount'] ?? 'N/A'),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }


}
