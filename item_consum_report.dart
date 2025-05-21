import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'FireConstants.dart';

void main() {
  runApp(const ItemConsumptionReport());
}

class ItemConsumptionReport extends StatelessWidget {
  const ItemConsumptionReport({Key? key}) : super(key: key);

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
              'Item Consumption Report',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: const ItemConsumptionDataPage(),
        ),
      ),
    );
  }
}

class ItemConsumptionDataPage extends StatefulWidget {
  const ItemConsumptionDataPage({Key? key}) : super(key: key);

  @override
  _ItemConsumptionDataPageState createState() =>
      _ItemConsumptionDataPageState();
}

class _ItemConsumptionDataPageState extends State<ItemConsumptionDataPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? startDate;
  DateTime? endDate;

  double totalSaleQty = 0;
  double tkSaleQty = 0;
  double dnSaleQty = 0;
  double totalComplimentaryQty = 0;
  double totalQty = 0;
  double totalAmount = 0;
  double totalDiscountAmount = 0;
  double totalAmountAfterDiscount = 0;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(posdate);
    endDate = DateTime.parse(posdate);
    fetchData();
  }

  Future<void> fetchData() async {
    if (startDate == null || endDate == null) {
      _showDialog(context, 'Input Error', 'Please select both start and end dates.');
      return;
    }

    String startDateFormatted = '${startDate!.day.toString().padLeft(2, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.year}';
    String endDateFormatted = '${endDate!.day.toString().padLeft(2, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.year}';

    final response = await http.get(Uri.parse('${apiUrl}report/itemconsum?DB=$CLIENTCODE&startDate=$startDateFormatted&endDate=$endDateFormatted'));

    if (response.statusCode == 200) {
      try {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;

          // Reset totals
          totalSaleQty = 0;
          tkSaleQty = 0;
          dnSaleQty = 0;
          totalComplimentaryQty = 0;
          totalQty = 0;
          totalAmount = 0;
          totalDiscountAmount = 0;
          totalAmountAfterDiscount = 0;
          double totalModifierPrice = 0;
          double totalModifierDiscountAmount = 0;
          // Calculate totals
          for (var item in data) {
            totalSaleQty += double.tryParse(item['saleQty'] ?? '0') ?? 0;
            tkSaleQty += double.tryParse(item['takeAwaySaleQty'] ?? '0') ?? 0;
            dnSaleQty += double.tryParse(item['dineInSaleQty'] ?? '0') ?? 0;
            totalComplimentaryQty += double.tryParse(item['complimentaryQty'] ?? '0') ?? 0;
            totalAmount += double.tryParse(item['totalAmount'] ?? '0.00') ?? 0;
            totalDiscountAmount += double.tryParse(item['itemdiscountAmount'] ?? '0.00') ?? 0;
            totalAmountAfterDiscount += double.tryParse(item['amountAfterDiscount'] ?? '0.00') ?? 0;
            var modifiers = parseModifiers(item['modifiersDetails']);
            for (var modifier in modifiers) {
              totalModifierPrice += double.tryParse(modifier['modifierTotalPrice'].toString()) ?? 0;
              totalModifierDiscountAmount += double.tryParse(modifier['modifierAmountAfterDiscount'].toString()) ?? 0;
            }
          }

          // Add the total modifier price to the total amount
          totalAmount += totalModifierPrice;
          totalAmountAfterDiscount += totalModifierDiscountAmount;
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
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
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

      // Automatically fetch data after both dates are selected
      if (startDate != null && endDate != null) {
        fetchData();  // Fetch data when both start and end dates are selected
      }
    }
  }



  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Function to show dialogs with title and content
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to parse the modifiers data
  List<Map<String, dynamic>> parseModifiers(dynamic modifiersDetails) {
    if (modifiersDetails == null) {
      return [];
    }

    if (modifiersDetails is String) {
      String validJsonString = modifiersDetails
          .replaceAllMapped(RegExp(r'(\w+)=([\w\.]+)'), (match) {
        return '"${match.group(1)}":"${match.group(2)}"';
      });

      try {
        List<dynamic> parsed = json.decode(validJsonString);
        return List<Map<String, dynamic>>.from(parsed);
      } catch (e) {
        return [];
      }
    }

    if (modifiersDetails is List) {
      return List<Map<String, dynamic>>.from(modifiersDetails);
    }

    return [];
  }

  // Export to PDF
  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            data: [
              <String>['S/No', 'Product Name', 'Category Name', 'Take Away Sale Qty', 'Dine-In Sale Qty', 'Sale Qty', 'Complimentary Qty', 'Total Amount', 'Discount Percent', 'Discount Amount', 'Amount After Discount'],
              ...data.map((item) {
                return [
                  item['productName'] ?? 'N/A',
                  item['categoryName'] ?? 'N/A',
                  item['takeAwaySaleQty'] ?? '0',
                  item['dineInSaleQty'] ?? '0',
                  item['saleQty'] ?? '0',
                  item['complimentaryQty'] ?? '0',
                  item['totalAmount'] ?? '0.00',
                  item['discountPercent'] ?? '0.00',
                  item['itemdiscountAmount'] ?? '0.00',
                  item['amountAfterDiscount'] ?? '0.00',
                ];
              }).toList(),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/item_consumption_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the file
    OpenFile.open(file.path);
  }

  // Export to Excel
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Adding headers to the sheet
    sheetObject.appendRow([
      'S/No',
      'Product Name',
      'Category Name',
      'Take Away Sale Qty',
      'Dine-In Sale Qty',
      'Sale Qty',
      'Complimentary Qty',
      'Total Amount',
      'Discount Percent',
      'Discount Amount',
      'Amount After Discount'
    ]);

    int serialNo = 1;  // Start serial number from 1

    // Iterate through each item in the data
    for (var item in data) {
      var modifiers = parseModifiers(item['modifiersDetails']);

      // Add the main product row (item)
      sheetObject.appendRow([
        serialNo.toString(),
        item['productName'] ?? 'N/A',
        item['categoryName'] ?? 'N/A',
        item['takeAwaySaleQty'] ?? '0',
        item['dineInSaleQty'] ?? '0',
        item['saleQty'] ?? '0',
        item['complimentaryQty'] ?? '0',
        item['totalAmount'] ?? '0.00',
        item['discountPercent'] ?? '0.00',
        item['itemdiscountAmount'] ?? '0.00',
        item['amountAfterDiscount'] ?? '0.00',
      ]);
      serialNo++;  // Increment serial number after each item row

      // Add modifier rows under the main item, indent them in the Excel sheet
      for (var modifier in modifiers) {
        sheetObject.appendRow([
          '',  // Empty for serial number to indent
          '--> ${modifier['modifiers'] ?? 'N/A'}',  // Modifier name
          '',  // Empty for category name
          '',  // Empty for Take Away Sale Qty
          '',  // Empty for Dine-In Sale Qty
          modifier['modifiersqty'].toString(),  // Modifier quantity
          '',  // Empty for Complimentary Qty
          modifier['modifierTotalPrice'].toString(),  // Modifier price
          '',  // Empty for Discount Percent
          '',  // Empty for Discount Amount
          modifier['modifierAmountAfterDiscount'].toString(),  // Modifier discount amount
        ]);
      }
    }

    // Add the grand total row at the bottom of the sheet
    sheetObject.appendRow([
      'Grand Total',
      '', // Empty for Product Name
      '', // Empty for Category Name
      tkSaleQty.toStringAsFixed(2),
      dnSaleQty.toStringAsFixed(2),
      totalSaleQty.toStringAsFixed(2),
      '', // Empty for Complimentary Qty
      totalAmount.toStringAsFixed(2),
      '', // Empty for Discount Percent
      totalDiscountAmount.toStringAsFixed(2),
      totalAmountAfterDiscount.toStringAsFixed(2),
    ]);

    // Save the file to the device
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/item_consumption_report.xlsx";
    final file = File(path);
    file.writeAsBytesSync(excel.encode()!);

    // Optionally open the file using the OpenFile plugin (if available)
    OpenFile.open(file.path);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _exportToPDF,
              child: const Text('Export to PDF'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _exportToExcel,
              child: const Text('Export to Excel'),
            ),
          ],
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
                  DataColumn(label: Text('S/No')),
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Category Name')),
                  DataColumn(label: Text('Take Away Sale Qty')),
                  DataColumn(label: Text('Dine-In Sale Qty')),
                  DataColumn(label: Text('Sale Qty')),
                  DataColumn(label: Text('Complimentary Qty')),
                  DataColumn(label: Text('Total Amount')),
                  DataColumn(label: Text('Discount Percent')),
                  DataColumn(label: Text('Discount Amount')),
                  DataColumn(label: Text('Amount After Discount')),
                ],
                rows: data.asMap().entries.map((entry) {
                  int index = entry.key + 1; // Serial number starts from 1
                  var item = entry.value;
                  var modifiers = parseModifiers(item['modifiersDetails']);

                  List<DataRow> rows = [
                    DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(item['productName'] ?? 'N/A')),
                      DataCell(Text(item['categoryName'] ?? 'N/A')),
                      DataCell(Text(item['takeAwaySaleQty'] ?? '0')),
                      DataCell(Text(item['dineInSaleQty'] ?? '0')),
                      DataCell(Text(item['saleQty'] ?? '0')),
                      DataCell(Text(item['complimentaryQty'] ?? '0')),
                      DataCell(Text(item['totalAmount'] ?? '0.00')),
                      DataCell(Text(item['discountPercent'] ?? '0.00')),
                      DataCell(Text(item['itemdiscountAmount'] ?? '0.00')),
                      DataCell(Text(item['amountAfterDiscount'] ?? '0.00')),
                    ]),
                  ];

                  // Add modifier rows under the main product, placing them in the correct column
                  for (var modifier in modifiers) {
                    rows.add(DataRow(cells: [
                      DataCell(Text('')),
                      DataCell(Text('--> ${modifier['modifiers'] ?? 'N/A'}')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text(modifier['modifiersqty'].toString())),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text(modifier['modifierTotalPrice'].toString())),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text(modifier['modifierAmountAfterDiscount'].toString())),
                    ]));
                  }

                  return rows;
                }).expand((row) => row).toList()
                  ..add(
                    DataRow(cells: [
                      DataCell(Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('')), // Empty for Product Name
                      DataCell(Text('')), // Empty for Category Name
                      DataCell(Text(tkSaleQty.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(dnSaleQty.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(totalSaleQty.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('')),
                      DataCell(Text(totalAmount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('')),
                      DataCell(Text(totalDiscountAmount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(totalAmountAfterDiscount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                    ]),
                  ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
