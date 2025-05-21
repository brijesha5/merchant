import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sks_ticket_view/sks_ticket_view.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'BillDetails.dart'  as billdetail;
import 'Bill_model.dart';
import 'FireConstants.dart';
import 'OrderModifier.dart';
import 'Order_Item_model.dart';
import 'ReceiptView.dart';
import 'list_of_product_screen.dart';
import 'main_menu.dart';

void main() {
  runApp(const SettledBillsScreen());
}

class SettledBillsScreen extends StatelessWidget {
  const SettledBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidthmy = MediaQuery.of(context).size.width;
    double screenHeightmy = MediaQuery.of(context).size.height;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          //   Navigator.of(context).pop();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainMenu(),

            ),
          );
        },

        child: Scaffold(
          appBar: null, // Set the app bar to null to remove it
          backgroundColor: Colors.white, // Set background to white
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Red Rectangle Container with Text and Back Icon
                  Container(
                    width: double.infinity, // Make width infinite
                    padding: EdgeInsets.only(left: 10, top: 40, right: 90, bottom: 10), // Increased top padding to move text down
                    color: Color(0xFFD5282A), // Set the red color
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white), // White color for the back icon
                          iconSize: 28.0,
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40), // Shift text 2cm (~45px) to the left
                              child: Text(
                                'Settled Bills',
                                style: TextStyle(
                                  fontFamily: 'HammersmithOne',
                                  fontSize: screenWidthmy > screenHeightmy
                                      ? 50
                                      : (screenWidthmy > 600 ? 50 : 22),
                                  color: Colors.white, // Set text color to white
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10), // Space between the red container and the bill list
                ],
              ),
               BillList(), // Your list widget
            ],
          ),
        ),
      ),
    );
  }
}

class BillList extends StatelessWidget {
   BillList({super.key});




  List<BillItem> allbillitems = [];
  List<SelectedProductModifier> allbillmodifers = [];
  List<LocalTax> allbilltaxes = [];


  bool _isLoading = true;
  String custname = '', custmobile = '', custgst = '';
  double subtotal = 0.00;
  double grandtotal = 0.00;
  double billamount = 0.00;
  double discount = 0.00;
  double discountpercentage = 0.00;
  String discountremark = "";
  double sumoftax = 0.0;

   Future<List<Bill>> fetchPendingBill() async {
     final response = await http.get(Uri.parse('${apiUrl}bill/settled?DB=$CLIENTCODE'));

     if (response.statusCode == 200) {
       final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
       return parsed.map<Bill>((json) => Bill.fromMap(json)).toList();
     } else {
       throw Exception('Failed to load Pending Bills');
     }
   }



   Future<billdetail.BillDetails> fetchBillDetails(String BillNo) async {
     final response = await http.get(Uri.parse('${apiUrl}bill/getbybillno/$BillNo?DB='+CLIENTCODE));

     if (response.statusCode == 200) {
       final parsed = json.decode(response.body);

       billdetail.BillDetails a = billdetail.BillDetails.fromMap(parsed);
       discount = double.parse(a.billDiscount);
       discountpercentage =  double.parse(a.billDiscountPercent);
       discountremark = a.billDiscountRemark;
       custname = a.customerName.toString();
       custmobile = a.customerMobile.toString();
       custgst = a.customerGst.toString();
       return a;
     } else {
       throw Exception('Failed to load Pending Bill');
     }
   }




   Future<List<OrderItem>> fetchKotItems(String tablenumber) async {
     allbillitems.clear();

     final response =
     await http.get(Uri.parse('${apiUrl}order/bytableforreprint/$tablenumber'+'?DB='+CLIENTCODE));

     if (response.statusCode == 200) {
       final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

       List<OrderItem> toreturn =
       parsed.map<OrderItem>((json) => OrderItem.fromMap(json)).toList();

       double nsubtotal = 0.0;
       subtotal = 0.00;
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
         double temp = (item.price ?? 0.00) * (item.quantity ?? 0.00);
         nsubtotal = nsubtotal + temp;
       }

       subtotal += nsubtotal;
       /*     if (Lastclickedmodule == "Dine") {
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


   Future<List<OrderModifier>> fetchModifiers(String tablenumber) async {
     allbillmodifers.clear();

     final response =
     await http.get(Uri.parse('${apiUrl}order/modifierbytableforreprint/$tablenumber'+'?DB='+CLIENTCODE));

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
         );

         // Add the BillItem object to the list
         allbillmodifers.add(modifierItem);
         double temp = (double.parse(item.pricePerUnit) ?? 0.00) * (item.quantity ?? 0.00);
         nsubtotal = nsubtotal + temp;
       }


       subtotal += nsubtotal;
       /*   if (Lastclickedmodule == "Dine") {
        if (subtotal != nsubtotal) {
          updateState(nsubtotal);
        }
      }*/

       /*updateState(nsubtotal+subtotal);*/

       _isLoading = false;
       return toreturn;
     } else {
       throw Exception('Failed to load Product');
     }
   }







  void _rePrintBill(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bill Details',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SKSTicketView(
            backgroundPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            backgroundColor: Colors.redAccent,
            contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            drawArc: false,
            triangleAxis: Axis.vertical,
            borderRadius: 6,
            drawDivider: true,
            trianglePos: .5,
            child: Container(), // Add content for the bill
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }




   Future<List<int>> testBILL(String billno, List<BillItem> items, List<SelectedProductModifier> modifiers,String tableno,double grandtotal,double discpercentt, double disc,String drmark,int pax,String settlemodename) async {
     final profile = await CapabilityProfile.load();
     final generator = Generator(PaperSize.mm80, profile);







     List<int> bytes = [];

     // Split the last 3 digits
     String prefix = billno.substring(0, billno.length - 3);
     String suffix = billno.substring(billno.length - 3);


/*

    bytes += generator.text("heading",
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
    ));*/

     if(DuplicatePrint == 'Y') {
       bytes += generator.text('[Duplicate]',
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.center,
           ));
     }
     bytes += generator.text(brandName,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size2,
           width: PosTextSize.size2,
           align: PosAlign.center,
         ));


/*    bytes +=
        generator.text('', styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));*/


     bytes += generator.text(Addresslineone,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.center,
         ));


     bytes += generator.text(Addresslinetwo,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.center,
         ));


     bytes += generator.text(Addresslinethree,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.center,
         ));

/*
    bytes += generator.text('',  styles:  const PosStyles(fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));*/


     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));

     bytes += generator.text(Lastclickedmodule,
       styles: const PosStyles(fontType: PosFontType.fontB,
         bold: false,
         height: PosTextSize.size2,
         width: PosTextSize.size2,
         align: PosAlign.center,
       ),);
     if(custname.isNotEmpty) {
       bytes += generator.text(
           '________________________________________________', styles: PosStyles(
         fontType: PosFontType.fontA,
         bold: false,
         height: PosTextSize.size1,
         width: PosTextSize.size1,
       ));
     }
     if(custname.isNotEmpty) {
       bytes += generator.row([
         PosColumn(
           text: '  Guest Name',
           width: 4,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),
         PosColumn(
           text: ':    ' + custname.toString(),
           width: 8,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),

       ]);
     }

     if(custmobile.isNotEmpty) {
       bytes += generator.row([
         PosColumn(
           text: '  Mobile No',
           width: 3,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),
         PosColumn(
           text: '    :    ' + custmobile.toString(),
           width: 9,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),

       ]);
     }


     if(custgst.isNotEmpty) {
       bytes += generator.row([
         PosColumn(
           text: '  GSTIN',
           width: 3,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),
         PosColumn(
           text: '    :    ' + custgst.toString(),
           width: 9,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),

       ]);
     }
     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));


     bytes += generator.row([
       PosColumn(
         text: 'Bill No       :',
         width: 4,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),
       PosColumn(
         text: prefix,
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           align: PosAlign.right,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,),
       ),
       PosColumn(
         text: suffix,
         width: 2,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: true,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,
         ),
       ),


       PosColumn(
         text: 'PAX :'+pax.toString()+'  ',
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: true,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.right,
         ),
       ),
     ]);


     if (Lastclickedmodule != "Take Away") {
       bytes += generator.row([
         PosColumn(
           text: '  Table No      :',
           width: 5,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size1,
             width: PosTextSize.size1,
             align: PosAlign.left,

           ),
         ),
         PosColumn(
           text: ' '+tableno,

           width: 7,
           styles: const PosStyles(fontType: PosFontType.fontA,
             bold: false,
             height: PosTextSize.size2,
             width: PosTextSize.size2,
             align: PosAlign.left,
           ),
         ),

       ]);
     }


     bytes += generator.row([
       PosColumn(
         text: '  Waiter',
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),
       PosColumn(
         text: '    :    '+username,
         width: 9,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),

     ]);


/*    bytes +=
        generator.text('', styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));*/

     bytes += generator.row([
       PosColumn(
         text: '  Date and Time',
         width: 4,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),
       PosColumn(
         text: ':    '+DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())
             .toString(),
         width: 8,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: true,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),

     ]);


     bytes += generator.row([
       PosColumn(
         text: '  Bill By',
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),
       PosColumn(
         text: '    :    '+username,
         width: 9,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),

     ]);


     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));


     bytes += generator.row([
       PosColumn(
         text: 'Item Name',
         width: 5,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left
           ,
         ),
       ),
       PosColumn(
         text: 'Qty',
         width: 2,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.center,
         ),
       ),

       PosColumn(
         text: 'Price' + ' ',
         width: 2,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.center,
         ),
       ),
       PosColumn(
         text: 'Amount' + ' ',
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.right,
         ),
       ),
     ]);
     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
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
     for (BillItem item in items) {


       final itemModifiers = modifiers.where((modifier) => modifier.product_code == item.productCode).toList();


       String temp = item.itemName;



       String fpart = '';
       String spart = '';
       bool ismultline = false;

       if (temp.length <= 20) {
         print('String length is less than or equal to 20 characters: $temp');
       } else {
         int spaceIndex = temp.lastIndexOf(' ', 19);

         if (spaceIndex == -1) {
           print('No space found before 20 characters.');
         } else {
           ismultline = true;
           fpart = temp.substring(0, spaceIndex); // Part before the last space
           spart = temp.substring(spaceIndex + 1); // Part after the last space


         }
       }

       if (ismultline) {
         bytes += generator.row([
           PosColumn(
             text: fpart,
             width: 5,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.quantity.toString(),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.center,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.price.toStringAsFixed(2),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.totalPrice.toStringAsFixed(2) + ' ',
             width: 3,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
         ]);

         bytes += generator.row([
           PosColumn(
             text: spart,
             width:6,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: '',
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: '',
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: '  ',
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
         ]);
       }

       else {
         bytes += generator.row([
           PosColumn(
             text: item.itemName,
             width: 5,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.quantity.toString(),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.center,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.price.toStringAsFixed(2),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: item.totalPrice.toStringAsFixed(2) + ' ',
             width: 3,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
         ]);
       }

       for (SelectedProductModifier modi in itemModifiers) {

         double tamount = modi.price_per_unit * modi.quantity;
         bytes += generator.row([
           PosColumn(
             text: modi.price_per_unit > 0 ? '>> '+modi.name:'> '+modi.name,
             width: 5,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.left,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: modi.quantity.toString(),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.center,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: modi.price_per_unit.toStringAsFixed(2),
             width: 2,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             text: tamount.toStringAsFixed(2) + ' ',
             width: 3,
             styles: const PosStyles(fontType: PosFontType.fontA,
               align: PosAlign.right,
               bold: true,
               height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
         ]);

       }

     }


     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));


     bytes += generator.row([
       PosColumn(
         text: 'Sub Total',
         width: 4,
         styles: const PosStyles(
           align: PosAlign.left, bold: true, height: PosTextSize.size1,
           width: PosTextSize.size1,),
       ),
       PosColumn(

         width: 4,

       ),
       PosColumn(
         text: subtotal.toStringAsFixed(2) + ' ',
         width: 4,
         styles: const PosStyles(
           align: PosAlign.right, bold: true, height: PosTextSize.size1,
           width: PosTextSize.size1,),
       ),
     ]);

     bytes += generator.text(
         '________________________________________________', styles: PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));








     if (discountpercentage > 0) {
       bytes += generator.row([
         PosColumn(
           text: 'Discount ' + discpercentt.toStringAsFixed(0) + '%',
           width: 5,
           styles: const PosStyles(
             align: PosAlign.left, underline: false, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
         PosColumn(
           width: 3,
         ),
         PosColumn(
           text: disc.toStringAsFixed(2) + ' ',
           width: 4,
           styles: const PosStyles(
             align: PosAlign.right, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
       ]);

       bytes += generator.row([
         PosColumn(
           text: 'Remark(' + discountremark + ')',
           width: 10,
           styles: const PosStyles(
             align: PosAlign.left, underline: false, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
         PosColumn(
           width: 1,
         ),
         PosColumn(
           text: '  ',
           width: 1,
           styles: const PosStyles(
             align: PosAlign.right, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
       ]);
     }

     if (disc > 0.0) {

       billamount = subtotal - discount;
       bytes += generator.row([
         PosColumn(
           text: 'Bill Amount',
           width: 5,
           styles: const PosStyles(
             align: PosAlign.left, underline: false, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
         PosColumn(
           width: 3,
         ),
         PosColumn(
           text: billamount .toStringAsFixed(2) + ' ',
           width: 4,
           styles: const PosStyles(
             align: PosAlign.right, height: PosTextSize.size1,
             width: PosTextSize.size1,),
         ),
       ]);
     }












     for (var tax in globaltaxlist) {




       String isApplicableOncurrentmodlue = "N";

       switch (Lastclickedmodule) {
         case 'Dine':
           isApplicableOncurrentmodlue = tax.isApplicableonDinein;
           break;
         case 'Take Away':
           isApplicableOncurrentmodlue = tax.isApplicableonTakeaway;
           break;
         case 'Home Delivery':
           isApplicableOncurrentmodlue = tax.isApplicableonHomedelivery;
           break;
         case 'Counter':
           isApplicableOncurrentmodlue = tax.isApplicableCountersale;
           break;
         case 'Online':
           isApplicableOncurrentmodlue = tax.isApplicableOnlineorder;
           break;

       }




       if(isApplicableOncurrentmodlue == "Y") {


         double pec = 0.0;


         pec = double.parse(tax.taxPercent);



         double taxable = 0.0;

         if(discount > 0.0 ) {
           taxable = (pec / 100.00) * billamount;
         }
         else{
           taxable = (pec / 100.00) * subtotal;
         }
         bytes += generator.row([
           PosColumn(
             text: '${tax.taxName} ${tax.taxPercent}%',
             width: 5,
             styles: const PosStyles(
               align: PosAlign.left, underline: false, height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
           PosColumn(
             width: 3,
           ),
           PosColumn(
             text: taxable.toStringAsFixed(2)+' '  ,
             width: 4,
             styles: const PosStyles(
               align: PosAlign.right, height: PosTextSize.size1,
               width: PosTextSize.size1,),
           ),
         ]);
       }
     }


     bytes += generator.row([
       PosColumn(
         text: '  Paid',
         width: 3,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
           height: PosTextSize.size1,
           width: PosTextSize.size1,
           align: PosAlign.left,

         ),
       ),
       PosColumn(
         text: '    :    '+settlemodename,
         width: 9,
         styles: const PosStyles(fontType: PosFontType.fontA,
           bold: false,
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
         text: ' Grand Total',
         width: 5,
         styles: const PosStyles(fontType: PosFontType.fontB,
           bold: false,
           height: PosTextSize.size2,
           width: PosTextSize.size2,
           align: PosAlign.left,
         ),
       ),
       PosColumn(

         width: 3,

       ),
       PosColumn(
           text: grandtotal.toStringAsFixed(2)+'  ',
           width: 4,
           styles: const PosStyles(fontType: PosFontType.fontB,
             bold: false,
             height: PosTextSize.size2,
             width: PosTextSize.size2,
             align: PosAlign.right,
           )
       ),
     ]);

     bytes += generator.text('________________________________________________',  styles:  PosStyles(
       fontType: PosFontType.fontA,
       bold: false,
       height: PosTextSize.size1,
       width: PosTextSize.size1,
     ));





     bytes += generator.feed(1);
     bytes += generator.cut();


     printTicket(bytes,"192.168.29.201");




     return bytes;
   }


   Future<void> printTicket(List<int> ticket,String targetip) async {
     final printer = PrinterNetworkManager(targetip);
     PosPrintResult connect = await printer.connect();
     if (connect == PosPrintResult.success) {
       PosPrintResult printing = await printer.printTicket(ticket);

       print(printing.msg);
       printer.disconnect();


     }




   }



   @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Future<List<Bill>> futurePendingBills = fetchPendingBill();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add the text widget above the ListView
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 120.0, bottom: 10),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Bill>>(
            future: futurePendingBills,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 0), // Adjust position for the first grid
                          child: Container(
                            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0), // Further reduce margin
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Tighten padding
                            color: Colors.white, // White background for the grid items
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bill number and other information
                                Text(
                                  snapshot.data![index].billNo.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black, // Bill number text color
                                  ),
                                ),
                                const SizedBox(height: 3), // Reduced space between title and other details
                                // Bill details row (time)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Color(0xFFD5282A), // Amount text color
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      snapshot.data![index].billDate.toString(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2), // Reduced space between bill time and table number
                                // Table number row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.table_chart,
                                      color: Color(0xFFD5282A), // Amount text color
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Table: ${snapshot.data![index].tableNumber == 0 ? "TK" : snapshot.data![index].tableNumber}',

                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2), // Reduced space between table number and amount
                                // Amount with the specified color


                    Row(
                    mainAxisAlignment:MainAxisAlignment. spaceBetween,
                    children: [
                                Text(
                                  'Amount: ${snapshot.data![index].totalAmount}',
                                  style: const TextStyle(
                                    color: Color(0xFFD5282A), // Amount text color
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4), // Reduced space before the button
                                // Re-print Button aligned to the right, moved up by 3cm (80px)


                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
 Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          side: BorderSide(
                                            color: Color(0xBB45B100),
                                            width: 0.1,
                                          ),
                                        ),
                                        fixedSize: Size(
                                          screenWidth > screenHeight ? 120 : 110,
                                          screenWidth > screenHeight ? 20 : 10,
                                        ),
                                        backgroundColor: Color(0xBB4CAF50),
                                      ),
                                      onPressed: () async {
                                        DuplicatePrint = 'Y';

                                        var tableNumber = snapshot.data![index].tableNumber.toString();

                                        try {
                                          // Fetch the necessary data
                                          List<dynamic> results = await Future.wait([
                                            fetchKotItems(tableNumber),
                                            fetchModifiers(tableNumber),
                                            fetchBillDetails(snapshot.data![index].billNo.toString()),
                                          ]);

                                          allbilltaxes.clear();
                                          double temptaxsum = 0.0;

                                          // Process the taxes
                                          for (var tax in globaltaxlist) {
                                            String isApplicableOncurrentmodlue = "N";

                                            switch (Lastclickedmodule) {
                                              case 'Dine':
                                                isApplicableOncurrentmodlue = tax.isApplicableonDinein;
                                                break;
                                              case 'Take Away':
                                                isApplicableOncurrentmodlue = tax.isApplicableonTakeaway;
                                                break;
                                              case 'Home Delivery':
                                                isApplicableOncurrentmodlue = tax.isApplicableonHomedelivery;
                                                break;
                                              case 'Counter':
                                                isApplicableOncurrentmodlue = tax.isApplicableCountersale;
                                                break;
                                              case 'Online':
                                                isApplicableOncurrentmodlue = tax.isApplicableOnlineorder;
                                                break;
                                            }

                                            if (isApplicableOncurrentmodlue == 'Y') {
                                              billamount = subtotal - discount;

                                              double pec = double.parse(tax.taxPercent);
                                              double taxable = 0.0;

                                              taxable = (billamount > 0.0) ? (pec / 100.00) * billamount : (pec / 100.00) * subtotal;
                                              allbilltaxes.add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
                                              temptaxsum += taxable;
                                            }
                                          }

                                          sumoftax = temptaxsum;
                                          grandtotal = subtotal + sumoftax - discount;

                                          // Collect bill info
                                          Map<String, String> billinfo = {
                                            'name': "pratk",
                                            'Total': "$grandtotal",
                                            'BillNo': snapshot.data![index].billNo.toString(),
                                            'waiter': "$username",
                                            'discount': "$discount",
                                            'discountper': "$discountpercentage",
                                            'discountremark': "$discountremark",
                                            'custname': "$custname",
                                            'custmobile': "$custmobile",
                                            'custgst': "$custgst",
                                            'user': "$username",
                                            //'DNT': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()).toString(),
                                            'DNT': posdate,
                                          };

                                          Map<String, dynamic> routeArguments = {
                                            'billItems': allbillitems,
                                            'billModifiers': allbillmodifers,
                                            'billinfo': billinfo,
                                          };

                                          testBILL(snapshot.data![index].billNo.toString(), allbillitems, allbillmodifers, snapshot.data![index].tableNumber.toString(), grandtotal.toDouble(), discountpercentage, discount, discountremark, 1,snapshot.data![index].settlementModeName.toString());

                                          Navigator.pushNamed(context, '/reciptview', arguments: routeArguments);
                                        } catch (e) {
                                          print("Error loading data: $e");
                                        }
                                      },
                                      child: const Text(
                                        'Re-print',
                                        style: TextStyle(
                                          fontFamily: 'HammersmithOne',
                                          color: Colors.white, // Text color for the button
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),

                      const SizedBox(height: 4),



                                Align(
                                  alignment: Alignment.topRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        side: BorderSide(
                                          color: Color(0xBB45B100),
                                          width: 0.1,
                                        ),
                                      ),
                                      fixedSize: Size(
                                        screenWidth > screenHeight ? 120 : 110,
                                        screenWidth > screenHeight ? 20 : 10,
                                      ),
                                      backgroundColor: Color(0xBB4CAF50),
                                    ),
                                    onPressed: () async {
                                      DuplicatePrint = 'Y';

                                      var tableNumber = snapshot.data![index].tableNumber.toString();

                                      try {
                                        // Fetch the necessary data
                                        List<dynamic> results = await Future.wait([
                                          fetchKotItems(tableNumber),
                                          fetchModifiers(tableNumber),
                                          fetchBillDetails(snapshot.data![index].billNo.toString()),
                                        ]);

                                        allbilltaxes.clear();
                                        double temptaxsum = 0.0;

                                        // Process the taxes
                                        for (var tax in globaltaxlist) {
                                          String isApplicableOncurrentmodlue = "N";

                                          switch (Lastclickedmodule) {
                                            case 'Dine':
                                              isApplicableOncurrentmodlue = tax.isApplicableonDinein;
                                              break;
                                            case 'Take Away':
                                              isApplicableOncurrentmodlue = tax.isApplicableonTakeaway;
                                              break;
                                            case 'Home Delivery':
                                              isApplicableOncurrentmodlue = tax.isApplicableonHomedelivery;
                                              break;
                                            case 'Counter':
                                              isApplicableOncurrentmodlue = tax.isApplicableCountersale;
                                              break;
                                            case 'Online':
                                              isApplicableOncurrentmodlue = tax.isApplicableOnlineorder;
                                              break;
                                          }

                                          if (isApplicableOncurrentmodlue == 'Y') {
                                            billamount = subtotal - discount;

                                            double pec = double.parse(tax.taxPercent);
                                            double taxable = 0.0;

                                            taxable = (billamount > 0.0) ? (pec / 100.00) * billamount : (pec / 100.00) * subtotal;
                                            allbilltaxes.add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
                                            temptaxsum += taxable;
                                          }
                                        }

                                        sumoftax = temptaxsum;
                                        grandtotal = subtotal + sumoftax - discount;

                                        // Collect bill info
                                        Map<String, String> billinfo = {
                                          'name': "pratk",
                                          'Total': "$grandtotal",
                                          'BillNo': snapshot.data![index].billNo.toString(),
                                          'waiter': "$username",
                                          'discount': "$discount",
                                          'discountper': "$discountpercentage",
                                          'discountremark': "$discountremark",
                                          'custname': "$custname",
                                          'custmobile': "$custmobile",
                                          'custgst': "$custgst",
                                          'user': "$username",
                                          //'DNT': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()).toString(),
                                          'DNT': posdate,
                                        };

                                        Map<String, dynamic> routeArguments = {
                                          'billItems': allbillitems,
                                          'billModifiers': allbillmodifers,
                                          'billinfo': billinfo,
                                        };

                                      //  testBILL(snapshot.data![index].billNo.toString(), allbillitems, allbillmodifers, snapshot.data![index].tableNumber.toString(), grandtotal.toDouble(), discountpercentage, discount, discountremark, 1,snapshot.data![index].settlementModeName.toString());

                                        Navigator.pushNamed(context, '/reciptview', arguments: routeArguments);
                                      } catch (e) {
                                        print("Error loading data: $e");
                                      }
                                    },
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        fontFamily: 'HammersmithOne',
                                        color: Colors.white, // Text color for the button
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                      ],),



                    ]



                    ),
                              ],
                            ),
                          ),
                        ),
                        // Move divider closer to the grid by adjusting offset
                        Transform.translate(
                          offset: const Offset(0, 0), // Move the divider up by 10px (~1cm)
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20), // Add 1cm spacing (10px on each side)
                            child: Divider(
                              color: Colors.black26, // Divider color set to black26
                              thickness: 1, // Divider thickness
                            ),
                          ),
                        ),
                      ],
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
    );
  }
}
