  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:flutter_sample/kot_model.dart';
  import 'package:flutter_sample/main_menu.dart' as mm;
  import 'package:http/http.dart' as http;
  import 'package:flutter_sample/table_selection.dart';
  import 'package:qr_flutter/qr_flutter.dart';
  import 'Costcenter_model.dart';
  import 'FireConstants.dart';
  import 'OrderModifier.dart';
  import 'Order_Item_model.dart';
  import 'ReceiptView.dart';
  import 'list_of_product_screen.dart';
  import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
  import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

  import 'main_menu_desk.dart';






  List<Color> ribbonColors = [
    Colors.redAccent,
    Colors.blue,
    Colors.green,
    // Add more colors as needed
  ];


  bool _isLoading = true;
  late Future<List<OrderItem>> futureKOTsmine;

  late Future<List<OrderModifier>> futureModifiersmine;
  List<SelectedProductModifier> allbillmodifers = [];
  List<BillItem> allbillitems = [];

  class BusyTableScreen extends StatelessWidget {
    const BusyTableScreen({super.key});



    @override
    Widget build(BuildContext context) {


      final Map<String, String> receivedStrings = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

      double screenWidth = MediaQuery
          .of(context)
          .size
          .width;
      double screenHeight = MediaQuery
          .of(context)
          .size
          .height;


      return Busytablescreen(receivedStrings: receivedStrings);
    }
  }

  class Busytablescreen extends StatelessWidget {



    final Map<String, String> receivedStrings;

    String ccname = '';
    static const darkGrey = Color(0xFF424242);
    Busytablescreen({super.key, required this.receivedStrings});


    void _handleCardTap() {



      /*   switch (index) {
        case 0:
          Navigator.pushNamed(context, '/itemlist');
          print('Tapped on Item 0');
          break;
        case 1:
          print('Tapped on Item 1');
          break;
        default:
          print('Tapped on Item $index');
          break;
      }*/
  }



  void showCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [






                        Text(
                          brandName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(Addresslineone, style: TextStyle(color: darkGrey)),
                        Text(Addresslinetwo, style: TextStyle(color: darkGrey)),
                        Text(Addresslinethree, style: TextStyle(color: darkGrey)),
                        Text(
                          'Tel No.: $brandmobile / $brandmobiletwo',
                          style: const TextStyle(color: darkGrey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Divider(thickness: 2),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Take Away',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 2),
                  const SizedBox(height: 2),
                  const Text(
                    'Thank you for your purchase!',
                    style: TextStyle(color: darkGrey),
                  ),
                  Center(
                    child: QrImageView(
                      data: "upi://pay?pa=harshdhage44-4@oksbi&pn=Harsh Dhage&am=50.00&cu=INR&aid=uGICAgIDVt_7-dw",
                      size: 100,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(100, 100),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust the spacing as needed
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)), // Ensure no rounded corners
                          ),
                          backgroundColor: Colors.green, // Change the background color to redAccent
                        ),
                        onPressed: () {
                          // showCardDialog(context);
                        },
                        child: const Text('Re-print', style: TextStyle(   fontFamily: 'HammersmithOne',color: Colors.white)),
                      ),
                      /*          ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)), // Ensure no rounded corners
                            ),
                            backgroundColor: Colors.orange, // Change the background color to redAccent
                          ),
                          onPressed: () {
                            // showCardDialog(context);
                          },
                          child: const Text('Share', style: TextStyle(color: Colors.white)),
                        ),*/
                    ],
                  )

                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> cancelkot(String kotid)
  async {

    final response = await http.get(Uri.parse('${apiUrl}order/cancelkot/$kotid'+'?DB='+CLIENTCODE));

    if (response.statusCode == 200) {

    } else {
      throw Exception('Failed to cancelkot');
    }


  }



  Future<void> freetable()
  async {

    final String url2 = '${apiUrl}table/update/${receivedStrings['id']!}?DB=$CLIENTCODE';

    final Map<String, dynamic> data2 = {

      "tableName": receivedStrings['name'],
      "status": "Normal",
      "id": receivedStrings['id'],
      'area': receivedStrings['area'],
      "pax": receivedStrings['pax'] ?? 0,

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





  }



  String trimedtime(String time){

    int index = time.indexOf(' ');
    int index2 = time.indexOf('.');

    // Trim the string until the specific character using substring
    String trimmedString = time.substring(index+1,index2);

    return trimmedString;
  }


  List<SelectedProduct> selectedProducts = [];
  List<SelectedProductModifier> selectedModifiers = [];

  Future<List<Kot>> fetchKots(String tablenumber) async {
    final response = await http.get(Uri.parse('${apiUrl}order/kotbytable/$tablenumber'+'?DB='+CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
      return parsed.map<Kot>((json) => Kot.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load Product');
    }
  }





















  Future<List<OrderItem>> fetchKotItemsLatest(String tablenumber) async {
    allbillitems.clear();
    selectedProducts.clear();

    final response = await http.get(Uri.parse('${apiUrl}order/bytable/$tablenumber'+'?DB='+CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      List<OrderItem> toreturn =
      parsed.map<OrderItem>((json) => OrderItem.fromMap(json)).toList();


      for (OrderItem item in toreturn) {
        double tempitemtotal = item.quantity! * item.price!.toDouble();
        BillItem billItem = BillItem(
            productCode: item.itemCode.toString(),
            quantity: item.quantity ?? 0,
            price: item.price ?? 0,
            itemName: item.itemName.toString(),
            totalPrice: tempitemtotal);

        // Add the BillItem object to the list
        allbillitems.add(billItem);

      }



      for (OrderItem item in toreturn) {
        selectedProducts.add(SelectedProduct(

          name: item.itemName.toString(),
          price: item.price ?? 0,
          quantity: item.quantity ?? 0,
          code: item.itemCode.toString(),
          notes: item.orderNumber.toString(),
          costCenterCode: item.costCenterCode.toString(),
        ));
      }




      _isLoading = false;
      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }

  Future<List<OrderModifier>> fetchKotModifiersLatest(String tablenumber) async {
    allbillmodifers.clear();

    final response =
    await http.get(Uri.parse('${apiUrl}order/modifierbytable/$tablenumber'+'?DB='+CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      List<OrderModifier> toreturn =
      parsed.map<OrderModifier>((json) => OrderModifier.fromMap(json)).toList();

      double nsubtotal = 0.0;
      //  subtotal = 0.00;
      for (OrderModifier item in toreturn) {
        double tempitemtotal = item.quantity! * double.parse(item.pricePerUnit);
        SelectedProductModifier modifierItem = SelectedProductModifier(
          code: item.productCode.toString(),
          quantity: item.quantity ?? 0,
          name: item.name,
          price_per_unit: double.parse(item.pricePerUnit),
          product_code: item.productCode.toString(),
          order_id: item.kotId.kotId,
        );

        // Add the BillItem object to the list
        allbillmodifers.add(modifierItem);
        double temp = (double.parse(item.pricePerUnit) ?? 0.00) * (item.quantity ?? 0.00);
        nsubtotal = nsubtotal + temp;
      }
      /*   if (Lastclickedmodule == "Dine") {
          if (subtotal != nsubtotal) {
            updateState(nsubtotal);
          }
        }*/



      _isLoading = false;
      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }









  /////movetable////


  // Update the moveTable function in busy_table_screen.dart file

  Future<bool> moveTable(BuildContext context, String existingTableNo, String newTableNo, String db) async {
    final response = await http.put(
      Uri.parse('${apiUrl}order/movetable?existingTableNo=$existingTableNo&newTableNo=$newTableNo&DB=$db'),
    );

    if (response.statusCode == 200) {
      // Table moved successfully
      // Fetch KOTs for the new table
      List<Kot> kots = await fetchKots(newTableNo);

      // For each KOT, print the new KOT using testCancelKOT
      for (Kot kot in kots) {
        // Fetch KOT items and modifiers for the new table
        List<OrderItem> kotItems = await fetchKotItems(newTableNo);
        List<OrderModifier> kotModifiers = await fetchModifiers(newTableNo);

        // Convert OrderItems and OrderModifiers to SelectedProducts and SelectedProductModifiers
        List<SelectedProduct> selectedProducts = kotItems.map((item) => SelectedProduct(
          name: item.itemName.toString(),
          price: item.price ?? 0,
          quantity: item.quantity ?? 0,
          code: item.itemCode.toString(),
          notes: item.orderNumber.toString(),
          costCenterCode: item.costCenterCode.toString(),
        )).toList();

        List<SelectedProductModifier> selectedModifiers = kotModifiers.map((modifier) => SelectedProductModifier(
          code: modifier.productCode.toString(),
          quantity: modifier.quantity ?? 0,
          name: modifier.name,
          price_per_unit: double.parse(modifier.pricePerUnit),
          product_code: modifier.productCode.toString(),
          order_id: modifier.kotId.toString(),
        )).toList();

        // Call testCancelKOT with the new KOT details
        await MovetestKOT(kot.kotId.toString(), selectedProducts, selectedModifiers, newTableNo, context);
      }

      return true; // Table moved successfully
    } else {
      throw Exception('Failed to move table');
    }
  }  ///movekot////
  Future<bool> moveKot(String kotId, String existingTableNo, String newTableNo) async {
    final response = await http.put(
      Uri.parse('${apiUrl}order/movekot?kotId=$kotId&existingTableNo=$existingTableNo&newTableNo=$newTableNo&DB=$CLIENTCODE'),
    );

    if (response.statusCode == 200) {
      return true; // KOT moved successfully
    } else {
      throw Exception('Failed to move KOT');
    }
  }
  ///moveitem///
  Future<bool> moveItem(String kotId, String itemCode, String existingTableNo, String newTableNo) async {
    final response = await http.put(
      Uri.parse('${apiUrl}order/moveitem?kotId=$kotId&itemCode=$itemCode&existingTableNo=$existingTableNo&newTableNo=$newTableNo&DB=$CLIENTCODE'),
    );

    return response.statusCode == 200; // Return true if status code is 200 (success)
  }
  ///cancelitem///
  Future<bool> cancelItem(String kotId, String itemCode, int tableNo, {int cancelQty = 1}) async {
    // Define the URL for the cancel item API request with the updated parameters
    final response = await http.put(
      Uri.parse('${apiUrl}order/cancelitem?kotId=$kotId&itemCode=$itemCode&tableNo=$tableNo&cancelQty=$cancelQty&DB=$CLIENTCODE'),
    );

    // Check if the response status code is 200 (success)
    return response.statusCode == 200;
  }





  Future<List<OrderItem>> fetchKotItems(String tablenumber) async {
    selectedProducts.clear();

    final response = await http.get(Uri.parse('${apiUrl}order/bytable/$tablenumber' + '?DB=' + CLIENTCODE));

    // Log the response status and body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);

      // Log the parsed data
      print('Parsed data: $parsed');

      List<OrderItem> toreturn = [];

      if (parsed is List) {
        // If the response is a list
        print('Response is a list');
        toreturn = parsed.map<OrderItem>((json) => OrderItem.fromMap(json)).toList();
      } else if (parsed is Map<String, dynamic>) {
        // If the response is a single object
        print('Response is a single object');
        toreturn = [OrderItem.fromMap(parsed)];
      } else {
        print('Unexpected response format');
        throw Exception('Unexpected response format');
      }

      // Log the items added to the selectedProducts list
      print('Parsed OrderItems: $toreturn');

      for (OrderItem item in toreturn) {
        selectedProducts.add(SelectedProduct(
          name: item.itemName.toString(),
          price: item.price ?? 0,
          quantity: item.quantity ?? 0,
          code: item.itemCode.toString(),
          notes: item.orderNumber.toString(),
          costCenterCode: item.costCenterCode.toString(),
        ));

        // Log the selected product being added
        print('Added SelectedProduct: ${item.itemName}');
      }

      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }




  Future<List<TableItem>> fetchAllTables(String dbCode) async {
    final response = await http.get(Uri.parse('${apiUrl}table/getAll?DB='+CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      List<TableItem> toReturn = parsed.map<TableItem>((json) => TableItem.fromMap(json)).toList();
      return toReturn;
    } else {
      throw Exception('Failed to load tables');
    }
  }



  Future<List<OrderModifier>> fetchModifiers(String tablenumber) async {
    selectedModifiers.clear();

    final response =
    await http.get(Uri.parse('${apiUrl}order/modifierbytable/$tablenumber'+'?DB='+CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      List<OrderModifier> toreturn =
      parsed.map<OrderModifier>((json) => OrderModifier.fromMap(json)).toList();




      for (OrderModifier item in toreturn) {


        selectedModifiers.add(SelectedProductModifier(
          code: item.productCode.toString(),
          quantity: item.quantity ?? 0,
          name: item.name,
          price_per_unit: double.parse(item.pricePerUnit),
          product_code: item.productCode.toString(),
          order_id: item.kotId.kotId.toString(),
        ));

      }

      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }



  Future<List<int>> testCancelKOT(String kotno,List<SelectedProduct> items,List<SelectedProductModifier> modifiers,String tableno,context) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);



    List<int> bytes = [];

    // Split the last 3 digits
    String prefix = kotno.substring(0, kotno.length - 3);
    String suffix = kotno.substring(kotno.length - 3);



    String cccode = items[0].costCenterCode.toString();
    List<String> printers = await getPrinterIPsByCode( cccode,context);

    String heading= 'KOT';
    if(ccname.startsWith("Bar"))
    {
      heading = "BOT";
    }else if(ccname.startsWith("Kitchen"))
    {
      heading = "KOT";
    }



    bytes += generator.text('[ Cancelled KOT ]',
      styles: const PosStyles(fontType: PosFontType.fontB,
        bold: false,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        align: PosAlign.center,
      ),);

    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));

    bytes += generator.text(heading,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));

    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(brandName,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));


    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(ccname,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));

    bytes += generator.text('DINE',
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));







    bytes += generator.row([
      PosColumn(
        text: heading+' No:',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: prefix+suffix,
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 5,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: tableno,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: 'Unknown',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text:  DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()) .toString(),
        width: 8,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),

    ]);












    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left
          ,
        ),
      ),
      PosColumn(
        text: 'Item Name',
        width: 9,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ''+' ',
        width: 1,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ),
      ),
    ]);
    bytes += generator.text('________________________________________________',  styles:  PosStyles(
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
      final itemModifiers = modifiers.where((modifier) => modifier.product_code == item.code).toList();



      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 2,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: item.name,
          width: 9,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: ''+' ',
          width: 1,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.right,  bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
      ]);



      //   bytes += generator.feed(1);

      bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
        bold: false,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ));

      for (SelectedProductModifier modi in itemModifiers) {

        bytes += generator.row([
          PosColumn(
            text: modi.price_per_unit > 0 ? '>>':'>',
            width: 2,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: modi.quantity.toString()+' x ' +modi.name,
            width: 9,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: '' + ' ',
            width: 1,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.right,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
        ]);

        bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

      }



    }


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));



    bytes += generator.feed(1);
    bytes += generator.cut();

    for (String ip in printers) {
      printTicket(bytes,ip);
    }

    printers.clear();

    return bytes;
  }


  Future<List<int>> testKOT(String kotno,List<SelectedProduct> items,List<SelectedProductModifier> modifiers,String tableno,BuildContext context) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);



    List<int> bytes = [];

    // Split the last 3 digits
    String prefix = kotno.substring(0, kotno.length - 3);
    String suffix = kotno.substring(kotno.length - 3);



    String cccode = items[0].costCenterCode.toString();
    List<String> printers = await getPrinterIPsByCode( cccode,context);

    String heading= 'KOT';
    if(ccname.startsWith("Bar"))
    {
      heading = "BOT";
    }else if(ccname.startsWith("Kitchen"))
    {
      heading = "KOT";
    }


    if(DuplicateKotPrint == 'Y')
    {

      bytes += generator.text('[Duplicate]',
          styles: const PosStyles(fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.center,
          ));
    }
    bytes += generator.text(heading,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));

    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(brandName,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));


    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(ccname,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));

    bytes += generator.text('DINE',
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));







    bytes += generator.row([
      PosColumn(
        text: heading+' No:',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: prefix+suffix,
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 5,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: tableno,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: 'Unknown',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text:  DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()) .toString(),
        width: 8,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),

    ]);












    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left
          ,
        ),
      ),
      PosColumn(
        text: 'Item Name',
        width: 9,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ''+' ',
        width: 1,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ),
      ),
    ]);
    bytes += generator.text('________________________________________________',  styles:  PosStyles(
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
      final itemModifiers = modifiers.where((modifier) => modifier.product_code == item.code).toList();



      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 2,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: item.name,
          width: 9,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: ''+' ',
          width: 1,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.right,  bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
      ]);



      //   bytes += generator.feed(1);

      bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
        bold: false,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ));

      for (SelectedProductModifier modi in itemModifiers) {

        bytes += generator.row([
          PosColumn(
            text: modi.price_per_unit > 0 ? '>>':'>',
            width: 2,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: modi.quantity.toString()+' x ' +modi.name,
            width: 9,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: '' + ' ',
            width: 1,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.right,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
        ]);

        bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

      }



    }


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));



    bytes += generator.feed(1);
    bytes += generator.cut();

    printTicket(bytes, "192.168.1.222");

    return bytes;
  }
  Future<List<int>> MovetestKOT(String kotno,List<SelectedProduct> items,List<SelectedProductModifier> modifiers,String tableno,BuildContext context)
  async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);



    List<int> bytes = [];

    // Split the last 3 digits
    String prefix = kotno.substring(0, kotno.length - 3);
    String suffix = kotno.substring(kotno.length - 3);



    String cccode = items[0].costCenterCode.toString();
    List<String> printers = await getPrinterIPsByCode( cccode,context);

    String heading= 'KOT';
    if(ccname.startsWith("Bar"))
    {
      heading = "BOT";
    }else if(ccname.startsWith("Kitchen"))
    {
      heading = "KOT";
    }


    if(DuplicateKotPrint == 'N')
    {

      bytes += generator.text('[MOVED]',
          styles: const PosStyles(fontType: PosFontType.fontB,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            align: PosAlign.center,
          ));
    }
    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));
    bytes += generator.text(heading,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));

    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(brandName,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));


    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.text(ccname,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));

    bytes += generator.text('DINE',
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
        ));


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));







    bytes += generator.row([
      PosColumn(
        text: heading+' No:',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: prefix+suffix,
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 5,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: tableno,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: username,
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: 'Unknown',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text: ' ',
        width: 6,
        styles: const PosStyles(fontType: PosFontType.fontA,
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
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),
      PosColumn(
        text:  DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()) .toString(),
        width: 8,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,

        ),
      ),

    ]);












    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));


    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left
          ,
        ),
      ),
      PosColumn(
        text: 'Item Name',
        width: 9,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ''+' ',
        width: 1,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ),
      ),
    ]);
    bytes += generator.text('________________________________________________',  styles:  PosStyles(
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
      final itemModifiers = modifiers.where((modifier) => modifier.product_code == item.code).toList();



      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 2,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: item.name,
          width: 9,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.left, bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
        PosColumn(
          text: ''+' ',
          width: 1,
          styles: const PosStyles(fontType: PosFontType.fontB,align: PosAlign.right,  bold: false, height: PosTextSize.size2,
            width: PosTextSize.size2,),
        ),
      ]);



      //   bytes += generator.feed(1);

      bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
        bold: false,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ));

      for (SelectedProductModifier modi in itemModifiers) {

        bytes += generator.row([
          PosColumn(
            text: modi.price_per_unit > 0 ? '>>':'>',
            width: 2,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: modi.quantity.toString()+' x ' +modi.name,
            width: 9,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.left,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
          PosColumn(
            text: '' + ' ',
            width: 1,
            styles: const PosStyles(fontType: PosFontType.fontB,
              align: PosAlign.right,
              bold: false,
              height: PosTextSize.size2,
              width: PosTextSize.size2,),
          ),
        ]);

        bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

      }



    }


    bytes += generator.text('________________________________________________',  styles:  PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));



    bytes += generator.feed(1);
    bytes += generator.cut();

    for (String ip in printers) {
      printTicket(bytes,ip);
    }

    printers.clear();

    return bytes;
  }

  Future<List<String>> getPrinterIPsByCode( String code,BuildContext context) async {
    List<String> printers = [];





    List<Costcenter> costcenters;



    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    if( screenWidth > screenHeight )
    {
      costcenters = await futureCostcentersWindows;

    }
    else{
      costcenters = await mm.futureCostcenters;
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

  Future<void> printTicket(List<int> ticket,String targetip) async {
    final printer = PrinterNetworkManager(targetip);
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);

      print(printing.msg);
      printer.disconnect();





    }

    DuplicateKotPrint = 'N';


  }












  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingValue = screenWidth <= 540 ? 14 : 20.0;
    double paddingValue2 = (screenWidth <= 540 && screenHeight <= 290) ? 20 : (screenWidth > 290 || screenHeight > 290 ? 290  // For larger screens, use padding 290
        : 20);

    if (screenWidth <= 540) {
      paddingValue2 = 170;
    } else if (screenWidth <= 720) {
      paddingValue2 = 40;
    }

    double containerWidth;
    if (screenWidth > screenHeight) {
      containerWidth = 750;
    }
    else if (screenHeight > 550) {
      containerWidth = 550;
    }
    else {
      containerWidth = 220;
    }


    double dynamiCardHeight = screenWidth <= 540 ? 0.9 : 0.67;
    mm.futurePost = mm.fetchPost();
    mm.futureCategory = mm.fetchCategory();

    Future <List<Kot> > futureKOTs = fetchKots(receivedStrings['name']!);
    Future<List<OrderItem>> futureITEMs = fetchKotItemsLatest(receivedStrings['name']!);
    Future<List<OrderModifier>> futureITEMModifiers = fetchKotModifiersLatest(receivedStrings['name']!);





    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: const Color(0xFFD5282A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate back
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 60, top: 15),
                      child: Center(
                        child: Text(
                          'Table No.${receivedStrings['name']!}',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenWidth > screenHeight ? 50 : (screenWidth > 600 ? 50 : 22),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),




            Expanded(
                child:  Container(
                  width: containerWidth,
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color to white
                    border: Border.all(
                      color: Colors.grey.withOpacity(1),
                      width: 0.5, // Set the width of the border
                    ),
                    borderRadius: BorderRadius.circular(10), // Optional: Add rounded corners to the border
                  ),
                  child: Stack(
                    children: [


                      /* SingleChildScrollView(
                              child:  _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    :FutureBuilder<List<OrderItem>>(
                                  future: futureKOTsmine,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          OrderItem item = snapshot.data![index];


                                          // Filter modifiers for the current product
                                          final itemModifiers = allbillmodifers.where((modifier) => modifier.product_code == item.itemCode.toString()).toList();


                                          final totalPrice = item.quantity! * item.price!;

                                          // Check if it's the first item or if the orderID is different
                                          if (index == 0 ||
                                              item.orderNumber !=
                                                  snapshot.data![index - 1]
                                                      .orderNumber) {
                                            // Add a ListTile for the order number
                                            return

                                              Container(
                                                color: Colors.white, // Background color
                                                child:  Column(
                                              children: [


                                                ListTile(
                                                  contentPadding: EdgeInsets.zero, // Remove default padding around the ListTile
                                                  title: Padding(
                                                    padding: const EdgeInsets.all(0), // Remove padding around the title
                                                    child:Row(
                                                      children:[


                                                        Container(
                                                          color: Colors.white, // Set the background of the entire container to white
                                                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical padding for spacing
                                                          child: Align(
                                                            alignment: Alignment.topLeft, // Align the text to the top-left of the container
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 0, right: 20), // Padding to move text upwards
                                                              child: Container(
                                                                color: Colors.black54, // Set the background color of the order number to black with 54% opacity
                                                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Add padding around the order number
                                                                child: Text(
                                                                  "Order No.${item.orderNumber}", // Displaying the order number dynamically
                                                                  style: const TextStyle(
                                                                    fontFamily: 'HammersmithOne', // Font family for the text
                                                                    fontSize: 16, // Font size for the order number
                                                                    fontWeight: FontWeight.bold, // Make the text bold
                                                                    color: Colors.white, // White text color for contrast
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),


                                                        Container(
                                                          padding: const EdgeInsets.only(top: 4.0,bottom: 4.0,right: 4.0),
                                                          color: Colors.white,

                                                          child: Row(
                                                            children: [
                                                              const SizedBox(height: 2),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  elevation: 0.0,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                    side: BorderSide(
                                                                      color: Colors.black,
                                                                      width: 0.3,
                                                                    ),
                                                                  ),
                                                                  foregroundColor: Colors.white,
                                                                  backgroundColor: Colors.white,
                                                                  minimumSize: const Size(100, 40),
                                                                ),
                                                                onPressed: () {
                                                                  DuplicateKotPrint = 'Y';
                                                                  final filteredProducts = selectedProducts.where((product) {
                                                                    return product.notes == snapshot.data![index].kotId;
                                                                  }).toList();

                                                                  Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                                                  for (var product in filteredProducts) {
                                                                    if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                                      groupedByCostCenter[product.costCenterCode]!.add(product);
                                                                    } else {
                                                                      groupedByCostCenter[product.costCenterCode] = [product];
                                                                    }
                                                                  }

                                                                  groupedByCostCenter.forEach((costCenterCode, products) {
                                                                    List<SelectedProduct> filteredProducts = [];
                                                                    List<SelectedProductModifier> filteredModifiers = [];
                                                                    for (var product in products) {
                                                                      filteredProducts.add(product);
                                                                      filteredModifiers = selectedModifiers.where((modifier) {
                                                                        return modifier.product_code == product.code;
                                                                      }).toList();
                                                                    }
                                                                    testKOT(
                                                                        snapshot.data![index].kotId.toString(),
                                                                        filteredProducts,
                                                                        filteredModifiers,
                                                                        receivedStrings['tableId']!,context
                                                                    );
                                                                  });
                                                                },
                                                                child: const Text(
                                                                  'Re-print',
                                                                  style: TextStyle(
                                                                    fontFamily: 'HammersmithOne',
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 2,width: 10,),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                  side: BorderSide(
                                                                    color: Color(0xFFD5282A), // Border color set to #D5282A
                                                                    width: 1.0, // Set border width to 1.0 (you can adjust as needed)
                                                                  ),
                                                                ),
                                                                foregroundColor: Color(0xFFD5282A),  // Text color set to #D5282A
                                                                backgroundColor: Color(0xFFFFF5F4), // Background color set to #FFF5F4
                                                                minimumSize: const Size(100, 40),

                                                            ),
                                                              onPressed: () async {
                                                                cancelkot(snapshot.data![index].kotId.toString());

                                                                final filteredProducts = selectedProducts.where((product) {
                                                                  return product.notes == snapshot.data![index].kotId;
                                                                }).toList();

                                                                Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                                                for (var product in filteredProducts) {
                                                                  if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                                    groupedByCostCenter[product.costCenterCode]!.add(product);
                                                                  } else {
                                                                    groupedByCostCenter[product.costCenterCode] = [product];
                                                                  }
                                                                }

                                                                groupedByCostCenter.forEach((costCenterCode, products) {
                                                                  List<SelectedProduct> filteredProducts = [];
                                                                  List<SelectedProductModifier> filteredModifiers = [];
                                                                  for (var product in products) {
                                                                    filteredProducts.add(product);
                                                                    filteredModifiers = selectedModifiers.where((modifier) {
                                                                      return modifier.product_code == product.code;
                                                                    }).toList();
                                                                  }
                                                                  testCancelKOT(
                                                                    snapshot.data![index].kotId.toString(),
                                                                    filteredProducts,
                                                                    filteredModifiers,
                                                                    receivedStrings['tableId']!,context,
                                                                  );
                                                                });

                                                                if (snapshot.data!.length <= 1) {
                                                                  freetable();
                                                                  if(screenWidth>screenHeight){
                                                                    await Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => const MainMenuDesk(),
                                                                      ),
                                                                    );

                                                                  }else{
                                                                    await Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => const mm.MainMenu(),
                                                                      ),
                                                                    );
                                                                  }

                                                                } else {






                                                                  if(screenWidth>screenHeight){
                                                                    await Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => const MainMenuDesk(),
                                                                      ),
                                                                    );

                                                                  }else{
                                                                    await Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => const TableSelection(),
                                                                      ),
                                                                    );
                                                                  }











                                                                }
                                                              },
                                                              child: const Text(
                                                                'Cancel KOT',
                                                                style: TextStyle(
                                                                  fontFamily: 'HammersmithOne',
                                                                  color: Color(0xFFD5282A),  // Text color set to #D5282A
                                                                  fontWeight: FontWeight.bold, // Make the text bold
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2,width: 10,),
                                                            // Move KOT Button
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                String kotId = snapshot.data![index].kotId.toString();
                                                                String existingTableNo = snapshot.data![index].tableNumber.toString();
                                                                String? newTableNo;

                                                                // Show dialog for selecting a new table
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return FutureBuilder<List<TableItem>>(
                                                                      future: fetchAllTables(CLIENTCODE),
                                                                      builder: (context, snapshot) {
                                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                                          return AlertDialog(
                                                                            backgroundColor: Colors.white, // Set the background color for the entire dialog
                                                                            title: Text('Move KOT'),
                                                                            content: Center(child: CircularProgressIndicator()),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                onPressed: () => Navigator.pop(context),
                                                                                child: Text('Cancel'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }

                                                                        List<TableItem> tables = snapshot.data ?? [];
                                                                        return AlertDialog(
                                                                          backgroundColor: Colors.white, // Ensure the entire dialog is white
                                                                          title: Text(
                                                                            'Move KOT',
                                                                            textAlign: TextAlign.center, // Center the title text
                                                                            style: TextStyle(
                                                                              color: Color(0xFFD5282A), // Set title text color to hex value 0xFFD5282A
                                                                            ),
                                                                          ),
                                                                          content: Container(
                                                                            color: Colors.white,
                                                                            width: 550,
                                                                            height: 400,
                                                                            child: GridView.builder(
                                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                crossAxisCount: 5,
                                                                                crossAxisSpacing: 8.0,
                                                                                mainAxisSpacing: 8.0,
                                                                              ),
                                                                              itemCount: tables.length,
                                                                              itemBuilder: (context, index) {
                                                                                TableItem table = tables[index];
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    newTableNo = table.tableName;
                                                                                    moveKot(kotId, existingTableNo, newTableNo!).then((success) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(content: Text(success ? 'KOT moved!' : 'Move failed'))
                                                                                      );
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                    });
                                                                                  },
                                                                                  child: Card(
                                                                                    color: newTableNo == table.tableName ? Colors.blue : Colors.white,
                                                                                    elevation: 0, // Removed the shadow effect
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      side: BorderSide(color: Color(0xFF606060), width: 0.5),
                                                                                    ),
                                                                                    margin: EdgeInsets.symmetric(vertical: 5),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        table.tableName,
                                                                                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF606060)),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                          actions: <Widget>[
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                  side: BorderSide(color: Color(0xFFFC9603), width: 1.0),
                                                                ),
                                                                foregroundColor: Color(0xFFFC9603),
                                                                backgroundColor: Color(0xFFFFFBF2),
                                                                minimumSize: const Size(100, 40),                                                            ),
                                                              child: const Text(
                                                                'Move KOT',
                                                                style: TextStyle(
                                                                  fontFamily: 'HammersmithOne',
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            //moveitem


                                                          ],
                                                        ),
                                                      ),
                                                    ],),
                                                ),
                                              ),
                                                SizedBox(height: 1.0),


                                              Column(children: [






                                                Container(
                                                child:Row(



                                                  children:  [





                                                    Container(
                                                      width: 300,
                                                      child:ListView.builder(

                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                                                        itemCount: itemModifiers.length,
                                                        itemBuilder: (context, modIndex) {
                                                          final modifier = itemModifiers[modIndex];
                                                          return Padding(
                                                            padding: const EdgeInsets.fromLTRB(60, 0, 28, 0), // Adjust horizontal padding as needed
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start, // Aligns the column content to the start (left)
                                                              children: [
                                                                // Modifier Name - Aligned to the left
                                                                Text(
                                                                  modifier.name,
                                                                  style: const TextStyle(
                                                                    color: Colors.blueAccent,
                                                                    fontSize: 16, // Adjust font size as needed
                                                                    fontWeight: FontWeight.normal,
                                                                  ),
                                                                ),

                                                                // Row for Rate, Quantity, and Subtotal - Aligned to the right
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end, // Align the entire row to the right
                                                                  children: [
                                                                    // Rate - Move slightly to the left
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 90.0), // Reduce right padding for Rate
                                                                      child: Text(
                                                                        "${modifier.price_per_unit}",
                                                                        style: const TextStyle(
                                                                          color: Colors.blueAccent,
                                                                          fontSize: 14,
                                                                        ),
                                                                        textAlign: TextAlign.end, // Align Rate to the right
                                                                      ),
                                                                    ),

                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 28.0),
                                                                      child: Text(
                                                                        "${modifier.quantity}",
                                                                        style: const TextStyle(
                                                                          color: Colors.blueAccent,
                                                                          fontSize: 14,
                                                                        ),
                                                                        textAlign: TextAlign.end, // Align Quantity to the right
                                                                      ),
                                                                    ),


                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 12.0),
                                                                      child: Text(
                                                                        (modifier.price_per_unit * modifier.quantity).toStringAsFixed(2),
                                                                        style: const TextStyle(
                                                                          color: Colors.blueAccent,
                                                                          fontSize: 14,
                                                                        ),
                                                                        textAlign: TextAlign.end,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                              ],
                                                            ),
                                                          );
                                                        },

                                                      ),),
                                        ],
                                                ),
                                                ),
                                                ListTile(
                                                  title: Transform.translate(
                                                    offset: Offset(0, -15.8), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                    child: Text(
                                                      item.itemName.toString(),
                                                      style: const TextStyle(
                                                        fontFamily: 'HammersmithOne',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start, // Aligning to start
                                                    children: [
                                                      // Column for Price (left-aligned with 240px padding)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 240.0),
                                                        child: Transform.translate(
                                                          offset: Offset(0, -37.8), // Move the price 1 cm up
                                                          child: Text(
                                                            "${item.price}",
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // Column for Quantity (left-aligned with reduced space)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 110.0), // Reduced padding between price and quantity
                                                        child: Transform.translate(
                                                          offset: Offset(0, -37.8), // Move the quantity 1 cm up
                                                          child: Text(
                                                            "${item.quantity}",
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // Column for Total Price (right-aligned)
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight, // Align total price to the right side
                                                          child: Transform.translate(
                                                            offset: Offset(0, -37.8), // Move the total price 1 cm up
                                                            child: Text(
                                                              totalPrice.toStringAsFixed(2),
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ],),


                                            ],
                                          ),);
                                        } else {
                                          // Add a regular ListTile
                                          return
                                            Container(
                                              color: Colors.white, // Background color
                                              child: Column(children: [
                                                ListTile(
                                                title: Transform.translate(
                                                offset: Offset(0, -47.8), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                child: Text(
                                                  item.itemName.toString(),
                                                  style: const TextStyle(
                                                    fontFamily: 'HammersmithOne',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            subtitle: Row(
                                            mainAxisAlignment: MainAxisAlignment.start, // Aligning to start
                                            children: [
                                            // Column for Price (left-aligned with 240px padding)
                                            Padding(
                                            padding: const EdgeInsets.only(left: 240.0), // Move "Price" 240px to the right
                                            child: Transform.translate(
                                            offset: Offset(0, -67.8), // Move the price 1 cm up
                                            child: Text(
                                            "${item.price}",
                                            style: const TextStyle(
                                            fontSize: 14,),),),),

                                            // Column for Quantity (left-aligned with reduced space)
                                            Padding(
                                            padding: const EdgeInsets.only(left: 110.0), // Reduced padding between price and quantity
                                            child: Transform.translate(
                                            offset: Offset(0, -67.8), // Move the quantity 1 cm up
                                            child: Text(
                                            "${item.quantity}",
                                            style: const TextStyle(
                                            fontSize: 14,),),),),

                                            // Column for Total Price (right-aligned)
                                              Expanded(
                                              child: Align(
                                              alignment: Alignment.centerRight, // Align total price to the right side
                                              child: Transform.translate(
                                              offset: Offset(0, -67.8), // Move the total price 1 cm up
                                              child: Text(
                                              totalPrice.toStringAsFixed(2),
                                              style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              ),
                                              ),
                                              ),
                                              ),
                                              ),
                                                ],),),


                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                                                  itemCount: itemModifiers.length,
                                                  itemBuilder: (context, modIndex) {
                                                    final modifier = itemModifiers[modIndex];
                                                    return Padding(
                                                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0), // Adjust vertical padding
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start, // Aligns the column to the start
                                                        children: [
                                                          // Modifier name (moving it 1 cm up)
                                                          Transform.translate(
                                                            offset: Offset(0, -75.8), // Move the modifier name 1 cm up (approximately 37.8 pixels)
                                                            child: Text(
                                                              modifier.name,
                                                              style: const TextStyle(
                                                                color: Colors.blueAccent,
                                                                fontSize: 16, // Adjust font size as needed
                                                                fontWeight: FontWeight.normal, // Make the name stand out
                                                              ),
                                                            ),
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start, // Aligning to start
                                                            children: [
                                                              // Price (left-aligned with padding)
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 240.0), // Move 240px to the left
                                                                child: Transform.translate(
                                                                  offset: Offset(0, -97), // Move the price 1 cm up
                                                                  child: Text(
                                                                    "${modifier.price_per_unit}",
                                                                    style: const TextStyle(
                                                                      color: Colors.blueAccent,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              // Quantity (left-aligned with a small gap)
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 125.0), // Reduced padding between price and quantity
                                                                child: Transform.translate(
                                                                  offset: Offset(0, -97), // Move the quantity 1 cm up
                                                                  child: Text(
                                                                    "${modifier.quantity}",
                                                                    style: const TextStyle(
                                                                      color: Colors.blueAccent,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              // Total Price (right-aligned)
                                                              Expanded(
                                                                child: Align(
                                                                  alignment: Alignment.centerRight, // Align total price to the right side
                                                                  child:   Padding(
                                                    padding: const EdgeInsets.only(right: 18.0), child:Transform.translate(
                                                                    offset: Offset(0, -97), // Move the total price 1 cm up
                                                                    child: Text(
                                                                      (modifier.price_per_unit * modifier.quantity).toStringAsFixed(2),
                                                                      style: const TextStyle(
                                                                        color: Colors.blueAccent,
                                                                        fontSize: 14,
                                                                      ),
                                                                      textAlign: TextAlign.start, // Aligns text to the end of the column
                                                                    ),
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


                                              ],),);
                                        }
                                      },
                                    );

                                  } else {
                                    return const CircularProgressIndicator(); // Placeholder for when data is still loading
                                  }
                                },
                              ),

                          ),*/



                      Positioned.fill(
                        child: FutureBuilder<List<Kot>>(
                          future: futureKOTs,
                          builder: (context, snapshotkot) {
                            if (snapshotkot.hasData) {
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshotkot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 0.7,
                                        ),
                                      ),
                                      elevation: 0.0,
                                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                                      color: Colors.white,
                                      child:Column(

                                        children: [



                                          Row(
                                            children: [





                                              // First column for details
                                              Expanded(
                                                flex: 1,
                                                child: ListTile(
                                                  title: Row(
                                                    children: [




                                                      Text(
                                                        snapshotkot.data![index].kotId.toString(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const SizedBox(width: 2),
                                                          Text(trimedtime(snapshotkot.data![index].orderTime.toString())),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 18),
                                                      Row(
                                                        children: [
                                                          const SizedBox(width: 2),
                                                          Text(
                                                            'Table: ${receivedStrings['name']}',
                                                            style: TextStyle(
                                                              fontFamily: 'HammersmithOne',
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          String kotId = snapshotkot.data![index].kotId.toString();
                                                          String tableNo = snapshotkot.data![index].tableNumber.toString(); // Current table number
                                                          List<String> selectedItems = []; // List to store selected items for move or cancel

                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return StatefulBuilder(
                                                                builder: (context, setState) {
                                                                  return Dialog(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(15.0),
                                                                    ),
                                                                    elevation: 0,
                                                                    backgroundColor: Colors.white,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(16.0),
                                                                      child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          // Header Text
                                                                          Text(
                                                                            'Select Action',
                                                                            style: TextStyle(
                                                                              color: Color(0xFFD5282A),
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 20),

                                                                          // Fetch items for the current table and display as checkboxes
                                                                          FutureBuilder<List<OrderItem>>(
                                                                            future: fetchKotItems(tableNo.toString()), // Fetch items based on table number
                                                                            builder: (context, itemSnapshot) {
                                                                              if (itemSnapshot.connectionState == ConnectionState.waiting) {
                                                                                return CircularProgressIndicator();
                                                                              }

                                                                              if (itemSnapshot.hasError) {
                                                                                return Text('Error: ${itemSnapshot.error}');
                                                                              }

                                                                              List<OrderItem> itemsx = itemSnapshot.data ?? [];
                                                                              List<OrderItem> filteredItems = itemsx.where((item) => item.orderNumber == kotId).toList();

                                                                              if (filteredItems.isEmpty) {
                                                                                return Text('No items found.');
                                                                              }

                                                                              return Column(
                                                                                children: filteredItems.map((OrderItem item) {
                                                                                  // Handle null itemName, itemCode, and qty
                                                                                  String itemName = item.itemName ?? 'Unknown Item';
                                                                                  String itemCode = item.itemCode?.toString() ?? 'Unknown Code';
                                                                                  String qty = item.quantity?.toString() ?? '0'; // Handle null qty

                                                                                  // Add a TextEditingController to track the custom quantity
                                                                                  TextEditingController qtyController = TextEditingController(text: qty);

                                                                                  return CheckboxListTile(
                                                                                    title: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Text(itemName), // Display the item name
                                                                                        ),
                                                                                        // Display "Enter Qty" and the quantity input on the same line
                                                                                        Text('Enter Qty: '),
                                                                                        SizedBox(
                                                                                          width: 50,
                                                                                          child: TextField(
                                                                                            controller: qtyController,
                                                                                            keyboardType: TextInputType.number,
                                                                                            onChanged: (newQty) {
                                                                                              // You can update your model here, for example
                                                                                              item.quantity = int.tryParse(newQty) ?? 0;
                                                                                            },
                                                                                            decoration: InputDecoration(
                                                                                              hintText: 'Qty',
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    value: selectedItems.contains(itemCode), // Check if the item is selected
                                                                                    onChanged: (bool? selected) {
                                                                                      setState(() {
                                                                                        if (selected == true) {
                                                                                          selectedItems.add(itemCode); // Add item to selected list
                                                                                        } else {
                                                                                          selectedItems.remove(itemCode); // Remove item from selected list
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                  );
                                                                                }).toList(),
                                                                              );
                                                                            },
                                                                          ),
                                                                          SizedBox(height: 20),

                                                                          // Action Buttons (Move or Cancel)
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            children: <Widget>[
                                                                              // Cancel Action Button
                                                                              TextButton(
                                                                                onPressed: () async {
                                                                                  if (selectedItems.isNotEmpty && kotId.isNotEmpty) {
                                                                                    try {
                                                                                      for (var itemCode in selectedItems) {
                                                                                        bool success = await cancelItem(kotId, itemCode, tableNo! as int);
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(content: Text(success ? 'Item canceled successfully!' : 'Cancel failed')),
                                                                                        );
                                                                                      }

                                                                                      // Show success dialog after canceling items
                                                                                      showDialog(
                                                                                        context: context,
                                                                                        barrierDismissible: false, // Prevent closing by tapping outside
                                                                                        builder: (BuildContext context) {
                                                                                          return Center(
                                                                                            child: Material(
                                                                                              color: Colors.transparent,
                                                                                              child: Container(
                                                                                                padding: EdgeInsets.all(20),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                                ),
                                                                                                height: 200, // Increased height of the dialog box
                                                                                                child: Column(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center, // Align content vertically
                                                                                                  crossAxisAlignment: CrossAxisAlignment.center, // Align content horizontally
                                                                                                  children: <Widget>[
                                                                                                    const Icon(
                                                                                                      Icons.check_circle,
                                                                                                      size: 48.0,
                                                                                                      color: Colors.green,
                                                                                                    ),
                                                                                                    const SizedBox(height: 16.0),
                                                                                                    Text(
                                                                                                      'Items canceled successfully!',
                                                                                                      textAlign: TextAlign.center,
                                                                                                      style: TextStyle(
                                                                                                        color: Colors.blue.shade800,
                                                                                                        fontSize: 16.0,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      );

                                                                                      // Wait for 3 seconds before closing the success dialog
                                                                                      await Future.delayed(Duration(seconds: 3));

                                                                                      // Close the success dialog
                                                                                      Navigator.of(context).pop();

                                                                                      // Screen orientation logic for navigation based on width/height
                                                                                      double screenWidth = MediaQuery.of(context).size.width;
                                                                                      double screenHeight = MediaQuery.of(context).size.height;

                                                                                      if (screenWidth > screenHeight) {
                                                                                        // Landscape mode
                                                                                        await Navigator.pushReplacement(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => const MainMenuDesk(),
                                                                                          ),
                                                                                        );
                                                                                      } else {
                                                                                        // Portrait mode
                                                                                        await Navigator.pushReplacement(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => const mm.MainMenu(),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                    } catch (e) {
                                                                                      // Show error dialog if an exception occurs
                                                                                      showDialog(
                                                                                        context: context,
                                                                                        barrierDismissible: false, // Prevent closing by tapping outside
                                                                                        builder: (BuildContext context) {
                                                                                          return Center(
                                                                                            child: Material(
                                                                                              color: Colors.transparent,
                                                                                              child: Container(
                                                                                                padding: EdgeInsets.all(20),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                                ),
                                                                                                height: 200, // Increased height of the dialog box
                                                                                                child: Row(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  mainAxisAlignment: MainAxisAlignment.center, // Centering horizontally
                                                                                                  children: [
                                                                                                    Icon(Icons.error, color: Colors.red),
                                                                                                    SizedBox(width: 10),
                                                                                                    Text('Error: $e'),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      );

                                                                                      // Wait for 3 seconds before closing the error dialog
                                                                                      await Future.delayed(Duration(seconds: 3));

                                                                                      // Close the error dialog
                                                                                      Navigator.of(context).pop();
                                                                                    }
                                                                                  } else {
                                                                                    // Show snack bar if no items are selected
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(content: Text('Please select an item to cancel')),
                                                                                    );
                                                                                  }
                                                                                },
                                                                                style: TextButton.styleFrom(
                                                                                  foregroundColor: Color(0xFFD5282A),
                                                                                  backgroundColor: Colors.white, // Set text color to the specific red
                                                                                  textStyle: TextStyle(fontWeight: FontWeight.bold), // Set text style to bold
                                                                                ),
                                                                                child: Text('Cancel Items'),
                                                                              ),



                                                                              TextButton(
                                                                                onPressed: () async {
                                                                                  if (selectedItems.isNotEmpty) {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return FutureBuilder<List<TableItem>>(
                                                                                          future: fetchAllTables(CLIENTCODE),
                                                                                          builder: (context, tableSnapshot) {
                                                                                            if (tableSnapshot.connectionState == ConnectionState.waiting) {
                                                                                              return AlertDialog(
                                                                                                title: Text('Loading Tables'),
                                                                                                content: CircularProgressIndicator(),
                                                                                              );
                                                                                            }
                                                                                            List<TableItem> tables = tableSnapshot.data ?? [];
                                                                                            return StatefulBuilder(
                                                                                              builder: (context, setState) {
                                                                                                return Dialog(
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(15.0),
                                                                                                  ),
                                                                                                  elevation: 0,
                                                                                                  backgroundColor: Colors.white,
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(16.0),
                                                                                                    child: Column(
                                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          'Select Table to Move Items',
                                                                                                          textAlign: TextAlign.center,
                                                                                                          style: TextStyle(
                                                                                                            color: Color(0xFFD5282A),
                                                                                                          ),
                                                                                                        ),
                                                                                                        SizedBox(height: 20),
                                                                                                        Container(
                                                                                                          height: 400,
                                                                                                          width: 500,
                                                                                                          child: GridView.builder(
                                                                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                              crossAxisCount: 4,
                                                                                                              crossAxisSpacing: 8.0,
                                                                                                              mainAxisSpacing: 8.0,
                                                                                                            ),
                                                                                                            itemCount: tables.length,
                                                                                                            itemBuilder: (context, index) {
                                                                                                              TableItem table = tables[index];

                                                                                                              // Determine table card color based on its status
                                                                                                              Color cardColor;
                                                                                                              Color borderColor;
                                                                                                              if (table.status == "Occupied") {
                                                                                                                cardColor = const Color(0xFFD5282A); // Red
                                                                                                                borderColor = const Color(0xFFD5282A);
                                                                                                              } else if (table.status == "Free") {
                                                                                                                cardColor = const Color(0xFF9E9E9E); // Gray
                                                                                                                borderColor = const Color(0xFF9E9E9E);
                                                                                                              } else if (table.status == "Reserved") {
                                                                                                                cardColor = const Color(0xFF24C92F); // Green
                                                                                                                borderColor = const Color(0xFF24C92F);
                                                                                                              } else {
                                                                                                                cardColor = Colors.white; // Default (no status)
                                                                                                                borderColor = Colors.grey[500]!;
                                                                                                              }

                                                                                                              return GestureDetector(
                                                                                                                onTap: () async {
                                                                                                                  String newTableNo = table.tableName;
                                                                                                                  try {
                                                                                                                    for (var itemCode in selectedItems) {
                                                                                                                      bool success = await moveItem(kotId, itemCode, tableNo.toString(), newTableNo);
                                                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                                                        SnackBar(content: Text(success ? 'Item moved successfully!' : 'Move failed')),
                                                                                                                      );
                                                                                                                    }

                                                                                                                    showDialog(
                                                                                                                      context: context,
                                                                                                                      barrierDismissible: false, // Prevent closing by tapping outside
                                                                                                                      builder: (BuildContext context) {
                                                                                                                        return Center(
                                                                                                                          child: Material(
                                                                                                                            color: Colors.transparent,
                                                                                                                            child: Container(
                                                                                                                              padding: EdgeInsets.all(20),
                                                                                                                              decoration: BoxDecoration(
                                                                                                                                color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                                                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                                                              ),
                                                                                                                              height: 200, // Increased height of the dialog box
                                                                                                                              child: Column(
                                                                                                                                mainAxisAlignment: MainAxisAlignment.center, // Align content vertically
                                                                                                                                crossAxisAlignment: CrossAxisAlignment.center, // Align content horizontally
                                                                                                                                children: <Widget>[
                                                                                                                                  const Icon(
                                                                                                                                    Icons.check_circle,
                                                                                                                                    size: 48.0,
                                                                                                                                    color: Colors.green,
                                                                                                                                  ),
                                                                                                                                  const SizedBox(height: 16.0),
                                                                                                                                  Text(
                                                                                                                                    'Item moved successfully!',
                                                                                                                                    textAlign: TextAlign.center,
                                                                                                                                    style: TextStyle(
                                                                                                                                      color: Colors.blue.shade800,
                                                                                                                                      fontSize: 16.0,
                                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                ],
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    );

                                                                                                                    // Wait for 3 seconds before closing the success dialog
                                                                                                                    await Future.delayed(Duration(seconds: 3));

                                                                                                                    // Close the success dialog
                                                                                                                    Navigator.of(context).pop();

                                                                                                                    // Screen orientation logic for navigation based on width/height
                                                                                                                    double screenWidth = MediaQuery.of(context).size.width;
                                                                                                                    double screenHeight = MediaQuery.of(context).size.height;

                                                                                                                    if (screenWidth > screenHeight) {
                                                                                                                      // Landscape mode
                                                                                                                      await Navigator.pushReplacement(
                                                                                                                        context,
                                                                                                                        MaterialPageRoute(
                                                                                                                          builder: (context) => const MainMenuDesk(),
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    } else {
                                                                                                                      // Portrait mode
                                                                                                                      await Navigator.pushReplacement(
                                                                                                                        context,
                                                                                                                        MaterialPageRoute(
                                                                                                                          builder: (context) => const mm.MainMenu(),
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    }
                                                                                                                  } catch (e) {
                                                                                                                    // Show error dialog if an exception occurs
                                                                                                                    showDialog(
                                                                                                                      context: context,
                                                                                                                      barrierDismissible: false, // Prevent closing by tapping outside
                                                                                                                      builder: (BuildContext context) {
                                                                                                                        return Center(
                                                                                                                          child: Material(
                                                                                                                            color: Colors.transparent,
                                                                                                                            child: Container(
                                                                                                                              padding: EdgeInsets.all(20),
                                                                                                                              decoration: BoxDecoration(
                                                                                                                                color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                                                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                                                              ),
                                                                                                                              height: 150, // Increased height of the dialog box
                                                                                                                              child: Row(
                                                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                                                mainAxisAlignment: MainAxisAlignment.center, // Centering horizontally
                                                                                                                                children: [
                                                                                                                                  Icon(Icons.error, color: Colors.red),
                                                                                                                                  SizedBox(width: 10),
                                                                                                                                  Text('Error: $e'),
                                                                                                                                ],
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                    );

                                                                                                                    // Wait for 3 seconds before closing the error dialog
                                                                                                                    await Future.delayed(Duration(seconds: 3));

                                                                                                                    // Close the error dialog
                                                                                                                    Navigator.of(context).pop();
                                                                                                                  }

                                                                                                                  // Close the current dialog after performing actions
                                                                                                                  Navigator.pop(context);
                                                                                                                },
                                                                                                                child: SizedBox(
                                                                                                                  width: 250,
                                                                                                                  height: 250,
                                                                                                                  child: Card(
                                                                                                                    color: table.status == "Occupied"
                                                                                                                        ? const Color(0xFFD5282A)
                                                                                                                        : table.status == "Free"
                                                                                                                        ? const Color(0xFF9E9E9E)
                                                                                                                        : table.status == "Reserved"
                                                                                                                        ? const Color(0xFF24C92F)
                                                                                                                        : Colors.white,
                                                                                                                    elevation: 0.0,
                                                                                                                    shape: RoundedRectangleBorder(
                                                                                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                                                      side: BorderSide(
                                                                                                                        color: table.status == "Occupied"
                                                                                                                            ? const Color(0xFFD5282A)
                                                                                                                            : table.status == "Free"
                                                                                                                            ? const Color(0xFF9E9E9E)
                                                                                                                            : table.status == "Reserved"
                                                                                                                            ? const Color(0xFF24C92F)
                                                                                                                            : Colors.grey[500]!,
                                                                                                                        width: 0.5,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    child: Column(
                                                                                                                      children: [
                                                                                                                        SizedBox(
                                                                                                                          width: double.infinity,
                                                                                                                          height: 82,
                                                                                                                          child: Column(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                'Table',
                                                                                                                                textAlign: TextAlign.center,
                                                                                                                                style: TextStyle(
                                                                                                                                  fontSize: 15,
                                                                                                                                  fontWeight: FontWeight.normal,
                                                                                                                                  color: table.status == "Occupied"
                                                                                                                                      ? const Color(0xFFD5282A)
                                                                                                                                      : table.status == "Free"
                                                                                                                                      ? const Color(0xFF9E9E9E)
                                                                                                                                      : table.status == "Reserved"
                                                                                                                                      ? const Color(0xFF24C92F)
                                                                                                                                      : Colors.grey[500],
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                '${table.tableName}',
                                                                                                                                textAlign: TextAlign.center,
                                                                                                                                style: TextStyle(
                                                                                                                                  fontSize: 30,
                                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                                  color: table.status == "Occupied"
                                                                                                                                      ? const Color(0xFFD5282A)
                                                                                                                                      : table.status == "Free"
                                                                                                                                      ? const Color(0xFF9E9E9E)
                                                                                                                                      : table.status == "Reserved"
                                                                                                                                      ? const Color(0xFF24C92F)
                                                                                                                                      : Colors.grey[500],
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              );


                                                                                                            },
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                );



                                                                                              },
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  } else {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(content: Text('Please select items to move')),
                                                                                    );
                                                                                  }
                                                                                },
                                                                                style: TextButton.styleFrom(
                                                                                  foregroundColor: Color(0xFFD5282A), backgroundColor: Colors.white, // Set text color to the specific red
                                                                                  textStyle: TextStyle(fontWeight: FontWeight.bold), // Set text style to bold
                                                                                ),
                                                                                child: Text('Move Items'),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          foregroundColor: Colors.transparent, // To keep the icon color
                                                          backgroundColor: Colors.transparent, // Light blue background color
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                                            side: BorderSide(color: Color(0xFFFFFFF), width: 1.0),
                                                          ),
                                                          minimumSize: const Size(20, 20),
                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                        ),
                                                        child: const Row(
                                                          children: [
                                                            Icon(
                                                              Icons.edit, // Eye icon
                                                              size: 24,
                                                              color: Colors.black,
                                                            ),
                                                            SizedBox(width: 0), // Adds space between the icon and the text

                                                          ],
                                                        ),
                                                      )



                                                    ],
                                                  ),
                                                ),
                                              ),





                                              // Second column for buttons
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          side: BorderSide(
                                                            color: Colors.black,
                                                            width: 0.3,
                                                          ),
                                                        ),
                                                        foregroundColor: Colors.black,
                                                        backgroundColor: Colors.white,
                                                        minimumSize: const Size(120, 40),
                                                      ),
                                                      onPressed: () {
                                                        DuplicateKotPrint = 'Y';
                                                        final filteredProducts = selectedProducts.where((product) {
                                                          return product.notes == snapshotkot.data![index].kotId;
                                                        }).toList();

                                                        Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                                        for (var product in filteredProducts) {
                                                          if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                            groupedByCostCenter[product.costCenterCode]!.add(product);
                                                          } else {
                                                            groupedByCostCenter[product.costCenterCode] = [product];
                                                          }
                                                        }

                                                        groupedByCostCenter.forEach((costCenterCode, products) {
                                                          List<SelectedProduct> filteredProducts = [];
                                                          List<SelectedProductModifier> filteredModifiers = [];
                                                          for (var product in products) {
                                                            filteredProducts.add(product);
                                                            filteredModifiers = selectedModifiers.where((modifier) {
                                                              return modifier.product_code == product.code;
                                                            }).toList();
                                                          }
                                                          testKOT(
                                                              snapshotkot.data![index].kotId.toString(),
                                                              filteredProducts,
                                                              filteredModifiers,
                                                              receivedStrings['name']!,context
                                                          );
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Re-print',
                                                        style: TextStyle(
                                                          fontFamily: 'HammersmithOne',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          side: BorderSide(
                                                            color: Color(0xFFD5282A), // Border color set to #D5282A
                                                            width: 1.0, // Set border width to 1.0 (you can adjust as needed)
                                                          ),
                                                        ),
                                                        foregroundColor: Color(0xFFD5282A),  // Text color set to #D5282A
                                                        backgroundColor: Color(0xFFFFF5F4), // Background color set to #FFF5F4
                                                        minimumSize: const Size(30, 40),
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          // Call cancelKOT function and filter products based on KOT ID
                                                          cancelkot(snapshotkot.data![index].kotId.toString());

                                                          final filteredProducts = selectedProducts.where((product) {
                                                            return product.notes == snapshotkot.data![index].kotId;
                                                          }).toList();

                                                          // Group the products by cost center
                                                          Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                                          for (var product in filteredProducts) {
                                                            if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                              groupedByCostCenter[product.costCenterCode]!.add(product);
                                                            } else {
                                                              groupedByCostCenter[product.costCenterCode] = [product];
                                                            }
                                                          }

                                                          // Iterate over each cost center and process products
                                                          groupedByCostCenter.forEach((costCenterCode, products) {
                                                            List<SelectedProduct> filteredProducts = [];
                                                            List<SelectedProductModifier> filteredModifiers = [];
                                                            for (var product in products) {
                                                              filteredProducts.add(product);
                                                              filteredModifiers = selectedModifiers.where((modifier) {
                                                                return modifier.product_code == product.code;
                                                              }).toList();
                                                            }

                                                            // Call testCancelKOT with the filtered products and modifiers
                                                            testCancelKOT(
                                                              snapshotkot.data![index].kotId.toString(),
                                                              filteredProducts,
                                                              filteredModifiers,
                                                              receivedStrings['name']!,
                                                              context,
                                                            );
                                                          });

                                                          // Check if only 1 KOT is left
                                                          if (snapshotkot.data!.length <= 1) {
                                                            freetable();
                                                            // Show success dialog
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false, // Prevent closing by tapping outside
                                                              builder: (BuildContext context) {
                                                                return Center(
                                                                  child: Material(
                                                                    color: Colors.transparent,
                                                                    child: Container(
                                                                      padding: EdgeInsets.all(20),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white.withOpacity(0.6), // Adding transparency
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                      ),
                                                                      height: 200, // Increased height of the dialog
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(Icons.check_circle, color: Colors.green),
                                                                          SizedBox(width: 10),
                                                                          Text('KOT cancelled successfully!'),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );

                                                            // Wait for 3 seconds before closing the dialog
                                                            await Future.delayed(Duration(seconds: 3));

                                                            // Close the dialog after 3 seconds
                                                            Navigator.of(context).pop();

                                                            // Navigate based on screen orientation
                                                            if (screenWidth > screenHeight) {
                                                              await Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => const MainMenuDesk(),
                                                                ),
                                                              );
                                                            } else {
                                                              await Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => const mm.MainMenu(),
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            // Show success dialog
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false, // Prevent closing by tapping outside
                                                              builder: (BuildContext context) {
                                                                return Center(
                                                                  child: Material(
                                                                    color: Colors.transparent,
                                                                    child: Container(
                                                                      padding: EdgeInsets.all(20),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white.withOpacity(0.6), // Adding transparency
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                      ),
                                                                      height: 200, // Increased height of the dialog
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(Icons.check_circle, color: Colors.green),
                                                                          SizedBox(width: 10),
                                                                          Text('KOT cancelled successfully!'),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );

                                                            // Wait for 3 seconds before closing the dialog
                                                            await Future.delayed(Duration(seconds: 3));

                                                            // Close the dialog after 3 seconds
                                                            Navigator.of(context).pop();

                                                            // Navigate based on screen orientation
                                                            if (screenWidth > screenHeight) {
                                                              await Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => const MainMenuDesk(),
                                                                ),
                                                              );
                                                            } else {
                                                              await Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => const TableSelection(),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          // Show error dialog if an exception occurs
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible: false, // Prevent closing by tapping outside
                                                            builder: (BuildContext context) {
                                                              return Center(
                                                                child: Material(
                                                                  color: Colors.transparent,
                                                                  child: Container(
                                                                    padding: EdgeInsets.all(20),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white.withOpacity(0.6), // Adding transparency
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                    ),
                                                                    height: 200, // Increased height of the dialog
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Icons.error, color: Colors.red),
                                                                        SizedBox(width: 10),
                                                                        Text('Error: $e'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          // Wait for 3 seconds before closing the error dialog
                                                          await Future.delayed(Duration(seconds: 3));

                                                          // Close the error dialog
                                                          Navigator.of(context).pop();
                                                        }
                                                      },


                                                      child: const Text(
                                                        'Cancel KOT',
                                                        style: TextStyle(
                                                          fontFamily: 'HammersmithOne',
                                                          color: Color(0xFFD5282A),  // Text color set to #D5282A
                                                          fontWeight: FontWeight.bold, // Make the text bold
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Move KOT Button
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Convert kotId and tableNumber explicitly to strings
                                                        String kotId = snapshotkot.data![index].kotId.toString();
                                                        String existingTableNo = snapshotkot.data![index].tableNumber.toString();  // Ensure it's a string
                                                        String? newTableNo;

                                                        // Show dialog for selecting a new table
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return FutureBuilder<List<TableItem>>(
                                                              future: fetchAllTables(CLIENTCODE),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return AlertDialog(
                                                                    backgroundColor: Colors.white,
                                                                    title: Text('Move KOT'),
                                                                    content: Center(child: CircularProgressIndicator()),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(context),
                                                                        child: Text('Cancel'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }

                                                                List<TableItem> tables = snapshot.data ?? [];
                                                                return AlertDialog(
                                                                  backgroundColor: Colors.white,
                                                                  title: Text(
                                                                    'Move Kot',
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      color: Color(0xFFD5282A),
                                                                    ),
                                                                  ),
                                                                  content: Container(
                                                                    width: 500,
                                                                    height: 400,
                                                                    child: GridView.builder(
                                                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                        crossAxisCount: 4,
                                                                        crossAxisSpacing: 8.0,
                                                                        mainAxisSpacing: 8.0,
                                                                      ),
                                                                      itemCount: tables.length,
                                                                      itemBuilder: (context, index) {
                                                                        TableItem table = tables[index];

                                                                        return GestureDetector(
                                                                          onTap: () async {
                                                                            // Ensure tableName is treated as a string
                                                                            newTableNo = table.tableName.toString();  // Convert tableName to string

                                                                            // Ensure newTableNo is valid and not the same as the existing one
                                                                            if (existingTableNo.isEmpty || newTableNo == null || newTableNo == existingTableNo) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(content: Text('Please select a different table')),
                                                                              );
                                                                              return;
                                                                            }

                                                                            // Moving the KOT logic
                                                                            try {
                                                                              bool success = await moveKot(kotId, existingTableNo, newTableNo!);

                                                                              // Show a pop-up alert based on success or failure of the KOT move
                                                                              String message = success ? 'KOT moved successfully!' : 'Failed to move the KOT.';
                                                                              Icon icon = success ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.error, color: Colors.red);

                                                                              // Show dialog
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false, // Prevent closing by tapping outside
                                                                                builder: (BuildContext context) {
                                                                                  return Center( // This ensures the dialog is in the center
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.all(20),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                        ),
                                                                                        height: 200, // Increased height of the dialog box
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center, // Align content vertically
                                                                                          crossAxisAlignment: CrossAxisAlignment.center, // Align content horizontally
                                                                                          children: <Widget>[
                                                                                            icon,
                                                                                            const SizedBox(height: 16.0),
                                                                                            Text(
                                                                                              message,
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(
                                                                                                color: Colors.blue.shade800,
                                                                                                fontSize: 16.0,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                            ),
                                                                                            // Adding the Reprint Button inside the Dialog
                                                                                            ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                elevation: 0.0,
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                                                  side: BorderSide(
                                                                                                    color: Colors.black,
                                                                                                    width: 0.3,
                                                                                                  ),
                                                                                                ),
                                                                                                foregroundColor: Colors.black,
                                                                                                backgroundColor: Colors.white,
                                                                                                minimumSize: const Size(120, 40),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                // Re-print KOT logic
                                                                                                DuplicateKotPrint = 'Y';
                                                                                                final filteredProducts = selectedProducts.where((product) {
                                                                                                  return product.notes == snapshotkot.data![index].kotId;
                                                                                                }).toList();

                                                                                                Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                                                                                for (var product in filteredProducts) {
                                                                                                  if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                                                                    groupedByCostCenter[product.costCenterCode]!.add(product);
                                                                                                  } else {
                                                                                                    groupedByCostCenter[product.costCenterCode] = [product];
                                                                                                  }
                                                                                                }

                                                                                                groupedByCostCenter.forEach((costCenterCode, products) {
                                                                                                  List<SelectedProduct> filteredProducts = [];
                                                                                                  List<SelectedProductModifier> filteredModifiers = [];
                                                                                                  for (var product in products) {
                                                                                                    filteredProducts.add(product);
                                                                                                    filteredModifiers = selectedModifiers.where((modifier) {
                                                                                                      return modifier.product_code == product.code;
                                                                                                    }).toList();
                                                                                                  }
                                                                                                  testKOT(
                                                                                                      snapshotkot.data![index].kotId.toString(),
                                                                                                      filteredProducts,
                                                                                                      filteredModifiers,
                                                                                                      receivedStrings['name']!,
                                                                                                      context
                                                                                                  );
                                                                                                });
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Re-print',
                                                                                                style: TextStyle(
                                                                                                  fontFamily: 'HammersmithOne',
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );

                                                                              // Wait for 6 seconds before closing the dialog
                                                                              await Future.delayed(Duration(seconds: 6));

                                                                              // Close the dialog after 6 seconds
                                                                              Navigator.of(context).pop();
                                                                            } catch (e) {
                                                                              // Show error dialog if exception occurs
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false, // Prevent closing by tapping outside
                                                                                builder: (BuildContext context) {
                                                                                  return Center( // This ensures the dialog is in the center
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.all(20),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white.withOpacity(0.6), // Adding 60% opacity for transparency
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                                                        ),
                                                                                        height: 200, // Increased height of the dialog box
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.center, // Centering horizontally
                                                                                          children: [
                                                                                            Icon(Icons.error, color: Colors.red),
                                                                                            SizedBox(width: 10),
                                                                                            Text('Error: $e'),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );

                                                                              // Wait for 6 seconds before closing the error dialog
                                                                              await Future.delayed(Duration(seconds: 6));

                                                                              // Close the error dialog
                                                                              Navigator.of(context).pop();
                                                                            }

                                                                            Navigator.of(context).pop(); // Close any other previous dialog if it exists

                                                                            // Add orientation-based navigation logic here after the KOT is moved
                                                                            double screenWidth = MediaQuery.of(context).size.width;
                                                                            double screenHeight = MediaQuery.of(context).size.height;

                                                                            if (screenWidth > screenHeight) {
                                                                              await Navigator.pushReplacement(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => const MainMenuDesk(),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              await Navigator.pushReplacement(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => const mm.MainMenu(),
                                                                                ),
                                                                              );
                                                                            }
                                                                          },

                                                                          child: SizedBox(
                                                                            width: 250,
                                                                            height: 250,
                                                                            child: Card(
                                                                              color: table.status == "Occupied"
                                                                                  ? const Color(0xFFD5282A)
                                                                                  : table.status == "Free"
                                                                                  ? const Color(0xFF9E9E9E)
                                                                                  : table.status == "Reserved"
                                                                                  ? const Color(0xFF24C92F)
                                                                                  : Colors.white,
                                                                              elevation: 0.0,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                side: BorderSide(
                                                                                  color: table.status == "Occupied"
                                                                                      ? const Color(0xFFD5282A)
                                                                                      : table.status == "Free"
                                                                                      ? const Color(0xFF9E9E9E)
                                                                                      : table.status == "Reserved"
                                                                                      ? const Color(0xFF24C92F)
                                                                                      : Colors.grey[500]!,
                                                                                  width: 0.5,
                                                                                ),
                                                                              ),
                                                                              child: Column(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: 82,
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Table',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            fontSize: 15,
                                                                                            fontWeight: FontWeight.normal,
                                                                                            color: table.status == "Occupied"
                                                                                                ? const Color(0xFFD5282A)
                                                                                                : table.status == "Free"
                                                                                                ? const Color(0xFF9E9E9E)
                                                                                                : table.status == "Reserved"
                                                                                                ? const Color(0xFF24C92F)
                                                                                                : Colors.grey[500],
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          '${table.tableName}',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            fontSize: 30,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            color: table.status == "Occupied"
                                                                                                ? const Color(0xFFD5282A)
                                                                                                : table.status == "Free"
                                                                                                ? const Color(0xFF9E9E9E)
                                                                                                : table.status == "Reserved"
                                                                                                ? const Color(0xFF24C92F)
                                                                                                : Colors.grey[500],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          side: BorderSide(color: Color(0xFFFC9603), width: 1.0),
                                                        ),
                                                        foregroundColor: Color(0xFFFC9603),
                                                        backgroundColor: Color(0xFFFFFBF2),
                                                        minimumSize: const Size(30, 40),
                                                      ),
                                                      child: const Text(
                                                        'Move KOT',
                                                        style: TextStyle(
                                                          fontFamily: 'HammersmithOne',
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),





                                                    //moveitem


                                                  ],
                                                ),
                                              ),


                                            ],
                                          ),

                                          Container(

                                            child:  _isLoading
                                                ? const Center(child: CircularProgressIndicator())
                                                :FutureBuilder<List<OrderItem>>(
                                              future: futureITEMs,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {

                                                  List<OrderItem> filteredItems = snapshot.data!.where((item) {
                                                    // Replace 'yourOrderNumber' with the order number you want to filter by
                                                    return item.orderNumber == snapshotkot.data![index].kotId.toString();
                                                  }).toList();


                                                  return ListView.builder(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:  filteredItems.length,
                                                    itemBuilder: (context, index) {
                                                      OrderItem item =  filteredItems[index];


                                                      // Filter modifiers for the current product
                                                      final itemModifiers = allbillmodifers.where((modifier) => modifier.product_code == item.itemCode.toString() && modifier.order_id ==item.orderNumber).toList();


                                                      final totalPrice =
                                                          item.quantity! * item.price!;

                                                      // Check if it's the first item or if the orderID is different

                                                      // Add a regular ListTile
                                                      return
                                                        Column(children: [
                                                          Divider(height: 1, color: Color(0xFFE0E0E0)),
                                                          ListTile(

                                                            title: Transform.translate(
                                                              offset: Offset(0, 22), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                              child: SizedBox(
                                                                width:200,

                                                                child:Text(

                                                                  item.itemName.toString(),
                                                                  style: const TextStyle(
                                                                    fontFamily: 'HammersmithOne',
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),),
                                                            ),
                                                            subtitle: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // Padding applied to move the "Rate" to the right
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: paddingValue2), // Use dynamic paddingValue
                                                                      child: Text(
                                                                        "${item.price}",
                                                                        style: const TextStyle(
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    )

                                                                  ],
                                                                ),

                                                                Expanded(
                                                                  child: Center(
                                                                    child: Text(
                                                                      "${item.quantity}",
                                                                      style: const TextStyle(
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  totalPrice.toStringAsFixed(2),
                                                                  style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          ,
                                                          ListView.builder(

                                                            shrinkWrap: true,
                                                            physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                                                            itemCount: itemModifiers.length,
                                                            itemBuilder: (context, modIndex) {
                                                              final modifier = itemModifiers[modIndex];
                                                              return Padding(
                                                                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0), // Adjust vertical padding
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns the column to the start
                                                                    children: [
                                                                      Transform.translate(
                                                                        offset: Offset(0, 0), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                                        child: Text(
                                                                          modifier.name,
                                                                          style: const TextStyle(
                                                                            color: Colors.blueAccent,
                                                                            fontSize: 16, // Adjust font size as needed
                                                                            fontWeight: FontWeight.normal, // Make the name stand out
                                                                          ),
                                                                        ),),
                                                                      Transform.translate(
                                                                        offset: Offset(0, -22), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              child:  Text(
                                                                                "",
                                                                                style: const TextStyle(
                                                                                  color: Colors.blueAccent,
                                                                                  fontSize: 14,
                                                                                ),
                                                                                textAlign: TextAlign.start, // Aligns text to the start of the column
                                                                              ),



                                                                            ),
                                                                            Expanded(
                                                                              child:  Text(
                                                                                "${modifier.price_per_unit}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.blueAccent,
                                                                                  fontSize: 14,
                                                                                ),
                                                                                textAlign: TextAlign.right, // Aligns text to the start of the column
                                                                              ),



                                                                            ),
                                                                            Expanded(
                                                                              child:  Transform.translate(
                                                                                offset: Offset(8, 0), // Move the item name 1 cm up (approximately 37.8 pixels)
                                                                                child: Text(
                                                                                  "${modifier.quantity}",
                                                                                  style: const TextStyle(
                                                                                    color: Colors.blueAccent,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                  textAlign: TextAlign.center, // Centers text in the column
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Align(
                                                                                alignment: Alignment.centerRight, // Aligns text to the right
                                                                                child:Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(0, 0, 18, 0), // Adjust vertical padding
                                                                                  child: Text(
                                                                                    (modifier.price_per_unit * modifier.quantity).toStringAsFixed(2),
                                                                                    style: const TextStyle(
                                                                                      color: Colors.blueAccent,
                                                                                      fontSize: 14,
                                                                                    ),
                                                                                    textAlign: TextAlign.left, // Aligns text to the end of the column
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),),
                                                                    ],
                                                                  )



                                                              );

                                                            },
                                                          ),


                                                        ],);

                                                    },
                                                  );

                                                } else {
                                                  return const CircularProgressIndicator(); // Placeholder for when data is still loading
                                                }
                                              },
                                            ),
                                          ),

                                        ],),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )

            ),





            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Map<String, String> myStrings = {
                      'name': receivedStrings['name'].toString(),
                      'status': receivedStrings['status'].toString(),
                      'id': receivedStrings['id'].toString(),
                      //    'tableId': receivedStrings['tableId'].toString(),
                      'area': receivedStrings['area'].toString(),
                      "pax": (receivedStrings['pax'] != null ? receivedStrings['pax'].toString() : '0'),
                    };
                    Navigator.pushNamed(context, '/itemlist', arguments: myStrings);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(
                        color: Color(0xBB008AA9),
                        width: 0.1,
                      ),
                    ),
                    backgroundColor: Color(0xFFD5282A),
                    minimumSize: const Size(30, 50),
                  ),
                  child: const Text(
                    'Add More',
                    style: TextStyle(
                      fontFamily: 'HammersmithOne',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> routeArguments = {
                      'tableinfo': receivedStrings,
                    };
                    Navigator.pushNamed(context, '/generatebillsscreen', arguments: routeArguments);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(
                        color: Color(0xFFD5282A),
                        width: 1.0,
                      ),
                    ),
                    minimumSize: const Size(60, 50),

                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Bill',
                    style: TextStyle(
                      fontFamily: 'HammersmithOne',
                      fontSize: 22,
                      color: Color(0xFFD5282A),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String existingTableNo = receivedStrings['name']!;
                        String? newTableNo;

                        return FutureBuilder<List<TableItem>>(
                          future: fetchAllTables(CLIENTCODE),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return AlertDialog(
                                title: Text('Move Table'),
                                content: CircularProgressIndicator(),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                                ],
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return AlertDialog(
                                title: Text('Move Table'),
                                content: Text('No tables available'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close')),
                                ],
                              );
                            }

                            List<TableItem> tables = snapshot.data!;

                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                'Move Table',
                                textAlign: TextAlign.center, // Center the title text
                                style: TextStyle(
                                  color: Color(0xFFD5282A), // Set title text color to hex value 0xFFD5282A (Red)
                                ),
                              ),
                              content: Container(
                                width: 500,
                                height: 400,
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                  ),
                                  itemCount: tables.length,
                                  itemBuilder: (context, index) {
                                    TableItem table = tables[index];

                                    return GestureDetector(
                                      onTap: () async {
                                        newTableNo = table.tableName;

                                        if (existingTableNo.isEmpty || newTableNo == null) return;

                                        try {
                                          bool success = await moveTable(context, existingTableNo, newTableNo!, CLIENTCODE);

                                          if (success) {
                                            // Fetch KOTs and handle testCancelKOT after moving the table
                                            final kots = await fetchKots(existingTableNo);
                                            for (var kot in kots) {
                                              final filteredProducts = selectedProducts.where((product) {
                                                return product.notes == kot.kotId;
                                              }).toList();

                                              Map<String, List<SelectedProduct>> groupedByCostCenter = {};

                                              for (var product in filteredProducts) {
                                                if (groupedByCostCenter.containsKey(product.costCenterCode)) {
                                                  groupedByCostCenter[product.costCenterCode]!.add(product);
                                                } else {
                                                  groupedByCostCenter[product.costCenterCode] = [product];
                                                }
                                              }

                                              groupedByCostCenter.forEach((costCenterCode, products) {
                                                List<SelectedProduct> filteredProducts = [];
                                                List<SelectedProductModifier> filteredModifiers = [];
                                                for (var product in products) {
                                                  filteredProducts.add(product);
                                                  filteredModifiers = selectedModifiers.where((modifier) {
                                                    return modifier.product_code == product.code;
                                                  }).toList();
                                                }
                                                // Call MovetestKOT with the new table details
                                                MovetestKOT(
                                                  kot.kotId.toString(),
                                                  filteredProducts,
                                                  filteredModifiers,
                                                  newTableNo!,
                                                  context,
                                                );
                                              });
                                            }

                                            // Show success dialog after moving table
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false, // Prevent closing by tapping outside
                                              builder: (BuildContext context) {
                                                return Center(
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: Container(
                                                      padding: EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.6), // Adding opacity for transparency
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                      ),
                                                      height: 200,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget>[
                                                          const Icon(Icons.check_circle, size: 48.0, color: Colors.green),
                                                          const SizedBox(height: 16.0),
                                                          Text(
                                                            'Table moved successfully!',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Colors.blue.shade800,
                                                              fontSize: 16.0,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );

                                            // Wait for 3 seconds before closing the dialog
                                            await Future.delayed(Duration(seconds: 3));

                                            // Close the success dialog
                                            Navigator.of(context).pop();

                                            // Screen orientation logic for navigation based on width/height
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double screenHeight = MediaQuery.of(context).size.height;

                                            if (screenWidth > screenHeight) {
                                              // Landscape mode
                                              await Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const MainMenuDesk(),
                                                ),
                                              );
                                            } else {
                                              // Portrait mode
                                              await Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const mm.MainMenu(),
                                                ),
                                              );
                                            }
                                          } else {
                                            throw Exception('Failed to move the table.');
                                          }
                                        } catch (e) {
                                          // Show error dialog if an exception occurs
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false, // Prevent closing by tapping outside
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.6), // Adding opacity for transparency
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                                    ),
                                                    height: 200,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.error, color: Colors.red),
                                                        SizedBox(width: 10),
                                                        Text('Error: $e'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                          // Wait for 3 seconds before closing the error dialog
                                          await Future.delayed(Duration(seconds: 3));

                                          // Close the error dialog
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: Card(
                                          color: table.status == "Occupied"
                                              ? const Color(0xFFD5282A) // Red for Occupied
                                              : table.status == "Free"
                                              ? const Color(0xFF9E9E9E) // Gray for Free
                                              : table.status == "Reserved"
                                              ? const Color(0xFF24C92F) // Green for Reserved
                                              : Colors.white, // Default color
                                          elevation: 0.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            side: BorderSide(
                                              color: table.status == "Occupied"
                                                  ? const Color(0xFFD5282A)
                                                  : table.status == "Free"
                                                  ? const Color(0xFF9E9E9E)
                                                  : table.status == "Reserved"
                                                  ? const Color(0xFF24C92F)
                                                  : Colors.grey[500]!,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                height: 82,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Table',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal,
                                                        color: table.status == "Occupied"
                                                            ? const Color(0xFFD5282A)
                                                            : table.status == "Free"
                                                            ? const Color(0xFF9E9E9E)
                                                            : table.status == "Reserved"
                                                            ? const Color(0xFF24C92F)
                                                            : Colors.grey[500],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${table.tableName}',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight: FontWeight.bold,
                                                        color: table.status == "Occupied"
                                                            ? const Color(0xFFD5282A)
                                                            : table.status == "Free"
                                                            ? const Color(0xFF9E9E9E)
                                                            : table.status == "Reserved"
                                                            ? const Color(0xFF24C92F)
                                                            : Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: BorderSide(color: Colors.green, width: 0.5),
                      ),
                      foregroundColor: Colors.green,
                      backgroundColor: Color(0xFFF9FFF3),
                      minimumSize: const Size(60, 50),
                      padding: EdgeInsets.only(top: 28)
                  ),
                  child: Text(
                    'Move Table',
                    style: TextStyle(fontFamily: 'HammersmithOne', fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )

              ],
            ),
          ],
        ),
      ),
    );

  }
}

class TableItem {
  final String tableName;
  final String area;
  final String status;

  TableItem({required this.tableName,required this.area,required this.status});

  factory TableItem.fromMap(Map<String, dynamic> map) {
    return TableItem(
      tableName: map['tableName'],
      area: map['area'],
      status: map['area'],
    );
  }
}






class OccupiedLabel extends StatelessWidget {
  const OccupiedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Change to white
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.redAccent), // Optional: Add a border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: const Text(
        'OCCUPIED',
        style: TextStyle(
          color: Colors.redAccent, // Change text color to match the border or desired color
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }








}



class RoundedButton extends StatelessWidget {
  final String label;
  final bool selected;

  const RoundedButton({super.key,
    required this.label,
    this.selected = false, // By default, the button is not selected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff197fd5) : const Color(0xFFdde0ed),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xff0b63ad),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}