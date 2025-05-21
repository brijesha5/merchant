import 'dart:convert';

import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:intl/intl.dart';
import 'Costcenter_model.dart';
import 'FireConstants.dart';
import 'NativeBridge.dart';
import 'list_of_product_screen.dart';

import 'package:http/http.dart' as http;

import 'main_menu.dart';
import 'main_menu_desk.dart'; // Import the http package

class Placeorderscreen extends StatefulWidget {
  const Placeorderscreen({super.key});

  @override
  _PlaceorderscreenState createState() => _PlaceorderscreenState();
}

class _PlaceorderscreenState extends State<Placeorderscreen> {
  String deviceName = 'Unknown';

  String ccname = '';

  @override
  void initState() {
    super.initState();

    _getDeviceName();
  }

  Future<void> _getDeviceName() async {}

  Future<void> printTicket(List<int> ticket, String targetip) async {
    final printer = PrinterNetworkManager(targetip);
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);

      print(printing.msg);
      printer.disconnect();
    }
  }

  Future<List<int>> testKOT(String kotno, List<SelectedProduct> items,
      List<SelectedProductModifier> modifiers, String tableno) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    // Split the last 3 digits
    String prefix = kotno.substring(0, kotno.length - 3);
    String suffix = kotno.substring(kotno.length - 3);

    String cccode = items[0].costCenterCode.toString();
    List<String> printers = await getPrinterIPsByCode(cccode);

    String heading = 'KOT';
    if (ccname.startsWith("Bar")) {
      heading = "BOT";
    } else if (ccname.startsWith("Kitchen")) {
      heading = "KOT";
    }

    bytes += generator.text(heading,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));

    bytes += generator.text('',
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text(brandName,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));

    bytes += generator.text('',
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text(ccname,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('',
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text('DINE',
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
        text: heading + ' No:',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: prefix + suffix,
        width: 4,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 5,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Table No:',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: tableno,
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'KOT By :',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Waiter :',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: selectedwaitername,
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Device :',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: deviceName,
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Date and Time :',
        width: 4,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text:
            DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()).toString(),
        width: 8,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
    ]);

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'Item Name',
        width: 9,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '' + ' ',
        width: 1,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ),
      ),
    ]);
    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

/*    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size3,
          width: PosTextSize.size3,),
      ),
      PosColumn(
        text: 'Item Name',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size3,
          width: PosTextSize.size3,),
      ),
      PosColumn(
        text: ''+' ',
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
    for (SelectedProduct item in items) {
      final itemModifiers = modifiers
          .where((modifier) => modifier.product_code == item.code)
          .toList();

      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 2,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            align: PosAlign.left,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: item.name,
          width: 9,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            align: PosAlign.left,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: '' + ' ',
          width: 1,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            align: PosAlign.right,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      ]);

      //   bytes += generator.feed(1);

      bytes += generator.text('',
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ));

      for (SelectedProductModifier modi in itemModifiers) {
        bytes += generator.row([
          PosColumn(
            text: modi.price_per_unit > 0 ? '>>' : '>',
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
          ),
          PosColumn(
            text: modi.quantity.toString() + ' x ' + modi.name,
            width: 9,
            styles: const PosStyles(
              fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
          ),
          PosColumn(
            text: '' + ' ',
            width: 1,
            styles: const PosStyles(
              fontType: PosFontType.fontB,
              align: PosAlign.right,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
          ),
        ]);

        bytes += generator.text('',
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              bold: false,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ));
      }
    }

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.feed(1);
    bytes += generator.cut();

    printTicket(bytes, "USB001");

    return bytes;
  }

  Future<List<String>> getPrinterIPsByCode(String code) async {
    List<String> printers = [];

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Costcenter> costcenters;

    if (screenWidth > screenHeight) {
      costcenters = await futureCostcentersWindows;
    } else {
      costcenters = await futureCostcenters;
    }

    for (var costcenter in costcenters) {
      if (costcenter.code == code) {
        ccname = costcenter.name;
        if (costcenter.printerip1.isNotEmpty) {
          printers.add(costcenter.printerip1);
        }
        if (costcenter.printerip2.isNotEmpty) {
          printers.add(costcenter.printerip2);
        }
        if (costcenter.printerip3.isNotEmpty) {
          printers.add(costcenter.printerip3);
        }
      }
    }

    return printers;
  }

  @override
  Widget build(BuildContext context) {
    /*List<SelectedProduct> selectedProducts = ModalRoute.of(context)!.settings.arguments as List<SelectedProduct>;
*/

    Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    List<SelectedProduct> selectedProducts =
        arguments['selectedProducts'] as List<SelectedProduct>;
    List<SelectedProductModifier> selectedModifiers =
        arguments['selectedModifiers'] as List<SelectedProductModifier>;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Set container width based on screen dimensions
    double containerWidth = screenWidth > screenHeight ? 450 : screenWidth;

    ////////////cost center wise grouping/////////
    // Create a map to group products by cost center code
    Map<String, List<SelectedProduct>> groupedByCostCenter = {};

    for (var product in selectedProducts) {
      if (groupedByCostCenter.containsKey(product.costCenterCode)) {
        groupedByCostCenter[product.costCenterCode]!.add(product);
      } else {
        groupedByCostCenter[product.costCenterCode] = [product];
      }
    }

    // Print the grouped products
    groupedByCostCenter.forEach((costCenterCode, products) {
      print('Cost Center Code: $costCenterCode');
      for (var product in products) {
        print(
            '  Product Name: ${product.name}, Code: ${product.code}, Price: ${product.price}');
      }
    });
    ////////////cost center wise grouping/////////

    Map<String, String> tableinfo =
        arguments['tableinfo'] as Map<String, String>;

    // Example functions for calculating totals (replace with actual logic)
    double calculateSubtotal() {
      return selectedProducts.fold(0.0, (subtotal, item) {
        return subtotal + (item.quantity * item.price);
      });
    }

    double calculateVAT() {
      // Replace with your VAT calculation logic
      return 0.0;
    }

    double calculateServiceCharge() {
      // Replace with your service charge calculation logic
      return 0.0;
    }

    double calculateCGST() {
      // Replace with your CGST calculation logic
      return 0.0;
    }

    double calculateSGST() {
      // Replace with your SGST calculation logic
      return 0.0;
    }

    double calculateTotal() {
      return calculateSubtotal() +
          calculateVAT() +
          calculateServiceCharge() +
          calculateCGST() +
          calculateSGST();
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          padding: const EdgeInsets.only(top: 15.0),
          child: Center(
            child: Text(
              'Order Summary',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFFD5282A),
        toolbarHeight: 60,
      ),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // Centers horizontally
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.0, bottom: 2.0),
                    child: Text(
                      'Table ${tableinfo['name']!}',
                      style: const TextStyle(
                        fontFamily: 'HammersmithOne',
                        fontSize: 24,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 450,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Card(
                      elevation: 5.0,
                      color: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        children: [
                          // Header Row
                          Container(
                            height: 55,
                            width: 450, // Fixed width for header
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5282A),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8.0)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                // Align to the start (left)
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        'Item',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        'Price',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        'Qty',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        'Amount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: 450, // Fixed width for product list
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selectedProducts.length,
                                  itemBuilder: (context, index) {
                                    final item = selectedProducts[index];
                                    final totalPrice =
                                        item.quantity * item.price;

                                    // Filter modifiers for the current product
                                    final itemModifiers = selectedModifiers
                                        .where((modifier) =>
                                            modifier.product_code == item.code)
                                        .toList();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                        child: Text(
                                                          item.name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child: Text(
                                                          "${item.price}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child: Text(
                                                          "${item.quantity}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child: Text(
                                                          totalPrice
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Modifiers List
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: itemModifiers.length,
                                                itemBuilder:
                                                    (context, modIndex) {
                                                  final modifier =
                                                      itemModifiers[modIndex];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              modifier.name,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Center(
                                                            child: Text(
                                                              "${modifier.price_per_unit}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Center(
                                                            child: Text(
                                                              "${modifier.quantity}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Center(
                                                            child: Text(
                                                              (modifier.price_per_unit *
                                                                      modifier
                                                                          .quantity)
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                            height: 1,
                                            color: Color(0xFFE0E0E0)),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 0, thickness: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (Lastclickedmodule == "Take Away" ||
                              Lastclickedmodule == "Counter" ||
                              Lastclickedmodule == "Home Delivery" ||
                              Lastclickedmodule == "Online") {
                            Map<String, dynamic> routeArguments = {
                              'selectedProducts': selectedProducts,
                              'selectedModifiers': selectedModifiers,
                              'tableinfo': tableinfo,
                            };
                            Navigator.pushNamed(context, '/generatebillsscreen',
                                arguments: routeArguments);
                          } else {
                            postData(context, selectedModifiers,
                                selectedProducts, tableinfo);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            side: BorderSide(
                              color: Colors.black,
                              width: 0.1,
                            ),
                          ),
                          backgroundColor: Color(0xFFD5282A),
                          minimumSize: const Size(150, 50),
                        ),
                        child: const Text(
                          'Place order',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final String apirl = '${apiUrl}order/create?DB=' + CLIENTCODE;

  late String gKOTNO;

  Future<void> postData(BuildContext context, List<SelectedProductModifier> sms,
      List<SelectedProduct> sps, Map<String, String> tableinfo)
  async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final orderItems = sps.map((product) => product.toJson()).toList();
    final orderModifiers = sms.map((product) => product.toJson()).toList();

    final response = await http.post(
      Uri.parse(apirl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "orderItems": orderItems,
        "orderModifiers": orderModifiers,
        "order_type": Lastclickedmodule,
        "tableName": tableinfo['name'],
      }),
    );

    print("harshbhai${jsonEncode({
          "orderItems": orderItems,
        })}");

    if (response.statusCode == 201) {
      // If the server returns a 200 OK response, you can handle the success here.
      print("Data Posted Successfully");

      final String url2 =
          '${apiUrl}table/update/${tableinfo['id']!}?DB=$CLIENTCODE';

      final Map<String, dynamic> data2 = {
        "tableName": tableinfo['name'],
        "status": "Occupied",
        "id": tableinfo['id'],
        "area": tableinfo['area'],
        "pax": tableinfo['pax'] ?? 0,
      };

      final headers = {
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.put(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(data2),
        );

        if (response.statusCode == 200) {
          // Request successful
          print('POST request successful');
          print('Response data: ${response.body}');
        } else {
          // Request failed
          print('POST request failed with status: ${response.statusCode}');
          print('Response data: ${response.body}');
        }
      } catch (e) {
        // An error occurred
        print('Error sending POST request: $e');
      }

      Map<String, dynamic> parsedData = json.decode(response.body.toString());
      print(parsedData);

      // Access specific fields in the parsed JSON
      String kotId = parsedData['orderNumber'];
      String itemName = parsedData['itemName'];
      int quantity = parsedData['quantity'];
      String status = parsedData['status'];

      print('KOT ID: $kotId');
      print('Item Name: $itemName');
      print('Quantity: $quantity');
      print('Status: $status');

      gKOTNO = kotId;

      ////////////////////////////////////

      Map<String, List<SelectedProduct>> groupedByCostCenter = {};

      for (var product in sps) {
        if (groupedByCostCenter.containsKey(product.costCenterCode)) {
          groupedByCostCenter[product.costCenterCode]!.add(product);
        } else {
          groupedByCostCenter[product.costCenterCode] = [product];
        }
      }

      groupedByCostCenter.forEach((costCenterCode, products) {
        List<SelectedProduct> tempselectedProducts = [];
        print('Cost Center Code: $costCenterCode');
        for (var product in products) {
          tempselectedProducts.add(product);
          //print('  Product Name: ${product.name}, Code: ${product.code}, Price: ${product.price}');
        }

        //   postData(context, tempselectedProducts, tableinfo);
        testKOT(kotId, tempselectedProducts, sms, tableinfo['name']!);
      });
      ////////////////////////////

      // testKOT(kotId, sps,tableinfo['tableId']!);
      NativeBridge.callNativeMethodKot(
          gKOTNO,
          jsonEncode(orderItems).toString(),
          "₹",
          tableinfo['name']!,
          Lastclickedmodule);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            //  Navigator.of(context).popUntil(ModalRoute.withName('/mainmenu'));// Close the dialog after 3 seconds

            Navigator.of(context).pop();

/*            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenu(),

              ),
            );*/

            if (Lastclickedmodule == "Take Away") {
              Map<String, dynamic> routeArguments = {
                'tableinfo': tableinfo,
              };

              Navigator.pushNamed(context, '/generatebillsscreen',
                  arguments: routeArguments);
            } else {
              if (screenWidth > screenHeight) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainMenuDesk(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainMenu(),
                  ),
                );
              }
            }
          });

          // Define a semi-transparent color for the background
          final backgroundColor = Colors.white.withOpacity(0.7);

          return AlertDialog(
            backgroundColor: backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.check_circle,
                  size: 48.0, // Set the size of the icon
                  color: Colors.green, // Set the color of the icon
                ),
                const SizedBox(height: 16.0),
                // Add some spacing between icon and text
                Text(
                  'No.DN$kotId\nOrder Placed Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: const [],
          );
        },
      );
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception to handle it accordingly.
      print("helloharsh---${response.body}");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(); // Close the dialog after 3 seconds
          });

          // Define a semi-transparent color for the background
          final backgroundColor = Colors.white.withOpacity(0.7);

          return AlertDialog(
            backgroundColor: backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.check_circle,
                  size: 48.0, // Set the size of the icon
                  color: Colors.redAccent, // Set the color of the icon
                ),
                const SizedBox(height: 16.0),
                // Add some spacing between icon and text
                Text(
                  'Failed to place order',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: const [],
          );
        },
      );

      throw Exception('Failed to place order');
    }
  }
}
