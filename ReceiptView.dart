import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sample/main_menu_desk.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sample/list_of_product_screen.dart';
import 'package:flutter_sample/main_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'FireConstants.dart';
import 'global_constatnts.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_sample/Order_Item_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Image;
import 'OrderModifier.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;

void main() => runApp(const ReceiptView());
class ReceiptView extends StatelessWidget {

  const ReceiptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {

    //////////////////////jp///////////////////////////////


    Map<String, dynamic> arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;


    List<BillItem> billItems = arguments['billItems'] as List<BillItem>;
    List<SelectedProductModifier> billModifiers = arguments['billModifiers'] as List<SelectedProductModifier>;



    gREciptViewBillItems = billItems;
    gREciptViewBillModifiers = billModifiers;


    Map<String, String> billinfo = arguments['billinfo'] as Map<String,
        String>;

    gReciptViewStrings = billinfo;

    //////////////////////////jp///////////////////////





    //////////////////////////jp///////////////////////








    return Scaffold(

      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          //   Navigator.of(context).pop();

          DuplicatePrint = 'N';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainMenu(),

            ),
          );
        },
        child: const MainPage(),
      ),
    );

  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}
class MainPageState extends State<MainPage> {
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  TextEditingController phoneNumberController = TextEditingController();


  Future<Uint8List> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  static const darkGrey = Color(0xFF424242);

  late Future<List<OrderItem>> futureKOTs;

  late Future<List<OrderModifier>> futureModifiers;



  bool _isLoading = true;

  String deviceName = 'Unknown';

  String ccname = '';
  List<BillItem> allbillitems = [];
  List<BillItem> allbillitemslocal = [];
  List<SelectedProductModifier> allbillmodifers = [];
  List<LocalTax> allbilltaxes = [];
  String custname = '', custmobile = '', custgst = '';
  double cgst = 0.00;
  double sgst = 0.00;
  double vat = 0.00;
  double sc = 0.00;
  double subtotal = 0.00;
  double grandtotal = 0.00;
  double billamount = 0.00;
  double discount = 0.00;
  String discountremark = "";
  String settlementModeName = "";
  double cgstpercentage = 2.50;
  double sgstpercentage = 2.50;
  double vatpercentage = 0.00;
  double scpercentage = 0.00;
  double discountpercentage = 0;
  double sumoftax = 0.0;
  double serviceCharge=0.0;


  Future<List<int>> testBILL( String billNo,
      List<BillItem> items,
      List<SelectedProductModifier> modifiers,
      String tableNo,
      double grandTotal,
      double discountPercentage,
      double discount,
      String discountRemark,
      int pax,
      String settlementModeName,
      double subtotal,
      List<LocalTax> localtaxes, Uint8List logoBytes )
  async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    String billNo = gReciptViewStrings['BillNo'] ?? '';
    String tableNo = gReciptViewStrings['tableName'] ?? '';
    String settlementModeName = gReciptViewStrings['settlementModeName'] ?? '';
    double discountPercentage = double.parse(
        gReciptViewStrings['discountper'] ?? '0');
    double discount = double.parse(gReciptViewStrings['discount'] ?? '0');
    String discountRemark = gReciptViewStrings['discountremark'] ?? '';
    int pax = int.parse(gReciptViewStrings['pax'] ?? '0');
    String custname = gReciptViewStrings['custname'].toString() ?? '';
    String custmobile = gReciptViewStrings['custmobile'].toString() ?? '';
    String custgst = gReciptViewStrings['custgst'].toString() ?? '';
    double subtotal = 0.00;
    double billamount = 0.00;
    double grandTotal = 0.00;


    // Calculate subtotal
    for (BillItem bill in gREciptViewBillItems) {
      subtotal += bill.totalPrice;
    }

    for (SelectedProductModifier modifier in gREciptViewBillModifiers) {
      double tamt = modifier.quantity * modifier.price_per_unit;
      subtotal += tamt;
    }

    // Apply discount
    if (discount > 0.0) {
      billamount = subtotal - discount;
    } else {
      billamount = subtotal;
    }

    // Calculate taxes
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

      if (isApplicableOncurrentmodlue == "Y") {
        double pec = double.parse(tax.taxPercent);
        double taxable = (discount > 0.0) ? (pec / 100.00) * billamount : (pec / 100.00) * subtotal;
        grandTotal += taxable;
      }
    }

    // Add bill amount to grand total
    grandTotal += billamount;

    String prefix = billNo.substring(0, billNo.length - 3);
    String suffix = billNo.substring(billNo.length - 3);

    if (DuplicatePrint == 'Y') {
      bytes += generator.text('[Duplicate]',
          styles: const PosStyles(fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.center,
          ));
    }
    final img.Image? logo = img.decodeImage(logoBytes);
    if (logo != null) {
      final resizedLogo = img.copyResize(
          logo, width: 300); // Resize the logo if necessary
      bytes += generator.image(resizedLogo);
    }
    // Print settlementModeName
    /*   bytes += generator.text(settlementModeName,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));*/

// Add an empty line for spacing
    // bytes += generator.text("");

// Print brandName
    bytes += generator.text(brandName,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));


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

    if (custname.isNotEmpty) {
      bytes += generator.text(
          '________________________________________________', styles: PosStyles(
        fontType: PosFontType.fontA,
        bold: false,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ));
    }

    if (custname.isNotEmpty) {
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

    if (custmobile.isNotEmpty) {
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

    if (custgst.isNotEmpty) {
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
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),


      PosColumn(
        text: 'PAX :' + pax.toString() + '  ',
        width: 3,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.right,
        ),
      ),
    ]);
    if (Lastclickedmodule == "Dine" || Lastclickedmodule == "Online") {
      bytes += generator.row([
        PosColumn(
          text: '  Table No:',
          width: 5,
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: ' $tableNo',
          width: 7,
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            align: PosAlign.left,
          ),
        ),
      ]);
    }


    if (Lastclickedmodule == "Dine"){
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
          text: '    :    ' + selectedwaitername.toString(),
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
    if (Lastclickedmodule == "Take Away" || Lastclickedmodule == "Counter") {
      // Add a blank row for a little space
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 12, // Adjust width if necessary
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.left,
          ),
        ),
      ]);
    }

    bytes += generator.row([
      PosColumn(
        text: '  Date & Time',
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ':    '+DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),

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
        text: '    :    ' + username,
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
          align: PosAlign.left,
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

    for (BillItem item in gREciptViewBillItems) {
      final itemModifiers = gREciptViewBillModifiers.where((modifier) => modifier.product_code == item.productCode).toList();
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
          fpart = temp.substring(0, spaceIndex);
          spart = temp.substring(spaceIndex + 1);
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
            width: 6,
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
      } else {
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
            text: modi.price_per_unit > 0 ? '>> ' + modi.name : '> ' + modi.name,
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








    // Add discount details if applicable
    if (discount > 0.0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount ' + discountPercentage.toStringAsFixed(0) + '%',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left, underline: false, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          width: 3,
        ),
        PosColumn(
          text: discount.toStringAsFixed(2) + ' ',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Remark(' + discountRemark + ')',
          width: 10,
          styles: const PosStyles(
            align: PosAlign.left, underline: false, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          width: 1,
        ),
        PosColumn(
          text: '  ',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.right, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }

// Calculate bill amount after discount
    if (discount > 0.0) {
      billamount = subtotal - discount;
      bytes += generator.row([
        PosColumn(
          text: 'Bill Amount',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left, underline: false, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          width: 3,
        ),
        PosColumn(
          text: billamount.toStringAsFixed(2) + ' ',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right, height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }

// Calculate and display taxes after discount
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

      if (isApplicableOncurrentmodlue == "Y") {
        double pec = double.parse(tax.taxPercent);
        double taxable = (discount > 0.0) ? (pec / 100.00) * billamount : (pec / 100.00) * subtotal;

        bytes += generator.row([
          PosColumn(
            text: '${tax.taxName} ${tax.taxPercent}%',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left, underline: false, height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            width: 3,
          ),
          PosColumn(
            text: taxable.toStringAsFixed(2) + ' ',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right, height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      }
    }

// Ensure the grand total is displayed correctly
    bytes += generator.text(
        '________________________________________________', styles: PosStyles(
      fontType: PosFontType.fontA,
      bold: false,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ));

    bytes += generator.row([
      PosColumn(
        text: 'Grand Total',
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
        text: grandTotal.toStringAsFixed(2),
        width: 4,
        styles: const PosStyles(fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
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
    bytes += generator.row([
      PosColumn(
        text: '  Paid',  // No leading spaces for 'Paid'
        width: 2,  // Adjusted width for space between columns
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ': ' + settlementModeName,  // No space before the colon
        width: 10,  // Adjusted width
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
    ]);


    bytes += generator.row([
      PosColumn(
        text: '',
        width: 12,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Thank you Visit Us Again!',
        width: 12,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ),
      ),
    ]);






    bytes += generator.feed(1);
    bytes += generator.cut();


    printTicket(bytes,"192.168.1.222");




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

  void openWhatsApp({required String phoneNumber, required String message}) async {
    String url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void shareImageToWhatsApp(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(imageBytes);
    final exists = await file.exists();
    if (exists) {
      print('Image file exists: ${file.path}');
    } else {
      print('Image file does not exist!');
    }
    XFile xFile = XFile(file.path);
    shareWhatsapp.shareFile(xFile);
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery

        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Color(0xFFC7C7C7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5282B),
        title: const Text('', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          alignment: Alignment.topLeft,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => screenWidth > screenHeight ?  MainMenuDesk():MainMenu(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: WidgetsToImage(
                  controller: controller,
                  child: cardWidget(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Row(
                children: [

                  IconButton(
                      icon: const Icon(
                        Icons.print,
                        color: Color(0xFFDAA520),
                        size: 50.0,
                      ),
                      onPressed: () async {
                        String billNo = gReciptViewStrings['BillNo'] ?? '';
                        String tableNo = gReciptViewStrings['tableName'] ?? '';
                        String totalStr = gReciptViewStrings['Total'] ?? '0';
                        String discountPerStr = gReciptViewStrings['discountper'] ?? '0';
                        String discountStr = gReciptViewStrings['discount'] ?? '0';
                        String discountRemark = gReciptViewStrings['discountremark'] ?? '';
                        String paxStr = gReciptViewStrings['pax'] ?? '0';
                        String settleModeName = gReciptViewStrings['settlemodename'] ?? '';
                        String custname = gReciptViewStrings['custname'] ?? '';

                        // Parse the string values to appropriate types
                        double total = double.tryParse(totalStr) ?? 0.0;
                        double discountPer = double.tryParse(discountPerStr) ?? 0.0;
                        double discount = double.tryParse(discountStr) ?? 0.0;
                        int pax = int.tryParse(paxStr) ?? 0;

                        // Calculate subtotal and taxes
                        double subtotal = 0.0;
                        List<LocalTax> localtaxes = [];

                        for (BillItem bill in gREciptViewBillItems) {
                          subtotal += bill.totalPrice;
                        }

                        for (SelectedProductModifier modifier in gREciptViewBillModifiers) {
                          double tamt = modifier.quantity * modifier.price_per_unit;
                          subtotal += tamt;
                        }

                        double billamt = subtotal - discount;

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

                          if (isApplicableOncurrentmodlue == "Y") {
                            double pec = double.parse(tax.taxPercent);
                            double taxable = (discount > 0.0) ? (pec / 100.00) * billamt : (pec / 100.00) * subtotal;
                            localtaxes.add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
                          }
                        }

                        await testBILL(
                            billNo,
                            gREciptViewBillItems,
                            gREciptViewBillModifiers,
                            tableNo,
                            total,
                            discountPer,
                            discount,
                            discountRemark,
                            pax,
                            settlementModeName,
                            subtotal,
                            localtaxes,
                            await loadImage('assets/images/singju.png')
                        );
                      }
                  ),



                  // WhatsApp number input field on the right with reduced width
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30.0),  // Reduced left padding
                      child: TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        cursorColor: Colors.green, // Set the cursor color here
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'HammersmithOne',
                          fontSize: 24,
                        ), // Set the input text color here
                        decoration: InputDecoration(
                          labelText: 'Whatsapp number',
                          labelStyle: TextStyle(color: Colors.green), // Set the label color here
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green), // Default border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green, width: 1), // Focused border color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green), // Enabled border color
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Theme(
        data: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 0.0, // Change this to your desired elevation
          ),
        ),
        child: FloatingActionButton(
          child: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
          onPressed: () async {
            final bytes = await controller.capture();
            setState(() {
              this.bytes = bytes;
            });
            if (bytes != null) {
              shareImageToWhatsApp(bytes);
            }

            openWhatsApp(
              phoneNumber: '91' + phoneNumberController.text,
              message: "Here is your Bill from " + brandName + " link: https://example.com powered by DPOS",
            );
          },
          mini: true,
          backgroundColor: Colors.green, // Change this to your desired color
        ),
      ),
    );

  }
  double gSubtotal = 0.0;
  double gGrandTotal = 0.0;
  double gSumOfTax = 0.0;
  Widget cardWidget() {
    List<LocalTax> localtaxes = [];

    double sttl = 0.00;
    double discount = 0.00;
    double discountper = 0.00;
    double billamt = 0.00;
    String discountremark = '';

    discount = double.parse(gReciptViewStrings['discount'].toString());
    if (discount != null) {
      discountper = double.parse(gReciptViewStrings['discountper'].toString());
      discountremark = gReciptViewStrings['discountremark'].toString();
    }
    double st = 0.00;

    for (BillItem bill in gREciptViewBillItems) {
      st += bill.totalPrice;
    }

    for (SelectedProductModifier modifier in gREciptViewBillModifiers) {
      double tamt = modifier.quantity * modifier.price_per_unit;
      st += tamt;
    }

    if (discount != null) {
      billamt = st - discount;
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

      if (isApplicableOncurrentmodlue == "Y") {
        double pec = double.parse(tax.taxPercent);
        double taxable = 0.0;

        if (discount > 0.0) {
          if (tax.taxName == "Service Charge") {
            if (GLOBALNSC == "Y") {
              taxable = (0.0 / 100.00) * billamt;
            } else {
              taxable = (pec / 100.00) * billamt;
            }
          } else {
            taxable = (pec / 100.00) * billamt;
          }
        } else {
          if (tax.taxName == "Service Charge") {
            if (GLOBALNSC == "Y") {
              taxable = (0.0 / 100.00) * st;
            } else {
              taxable = (pec / 100.00) * st;

              serviceCharge=taxable;
            }
          } else {
            if(serviceCharge!=0.0){
              //double serviceCharge = double.parse(globaltaxlist[0].taxPercent.toString());
              double subTotal=st+serviceCharge; //added service charge
              taxable = (pec / 100.00) * subTotal;
            }else{
              taxable = (pec / 100.00) * st;
            }
          }
    }
        localtaxes.add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
        sttl += taxable; // Add the taxable amount to the total
      }
    }

    sttl += billamt; // Add the bill amount to the total

    String lastThreeDigits = gReciptViewStrings['BillNo'].toString().substring(gReciptViewStrings['BillNo'].toString().length - 3);
    String remainingString = gReciptViewStrings['BillNo'].toString().substring(0, gReciptViewStrings['BillNo'].toString().length - 3);

    return Column(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Color(0xFFFFFFFF), // Change this to your desired color
            BlendMode.srcIn,
          ),
          child: SizedBox(
            width: 400.0, // Set your desired width
            child: Image.asset(
              'assets/images/LinesUpsideDown.png',
              fit: BoxFit.fill,
            ),
          ),
        ),

        // Main Card Content
        Container(
          width: 400,
          color: Color(0xFFFFFFFF),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/singju.png',
                        height: 50,
                      ),
                      if (DuplicatePrint == 'N')
                        Text('[Duplicate]', style: TextStyle(color: darkGrey)),

                      Text(
                        brandName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGrey),
                      ),
                      SizedBox(height: 8),
                      Text(Addresslineone, style: TextStyle(color: darkGrey)),
                      Text(Addresslinetwo, style: TextStyle(color: darkGrey)),
                      Text(Addresslinethree, style: TextStyle(color: darkGrey)),
                      Text('Tel No.: $brandmobile', style: const TextStyle(color: darkGrey)),
                      Text('Email: $emailid', style: const TextStyle(color: darkGrey)),
                    ],
                  ),
                ),
                SizedBox(height: 2),

                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Lastclickedmodule,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGrey),
                      ),
                    ],
                  ),
                ),

                if (gReciptViewStrings['custname'].toString().isNotEmpty)
                  Divider(thickness: 1, color: Colors.black),

                if (gReciptViewStrings['custname'].toString().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          'Guest Name',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 10, // Adjust this width as needed
                        child: Text(
                          ':',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          textAlign: TextAlign.left,
                          gReciptViewStrings['custname'].toString(),
                          style: const TextStyle(color: darkGrey),
                        ),
                      ),
                    ],
                  ),
                if (gReciptViewStrings['custmobile'].toString().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          'Mobile no',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 10, // Adjust this width as needed
                        child: Text(
                          ':',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          textAlign: TextAlign.left,
                          gReciptViewStrings['custmobile'].toString(),
                          style: const TextStyle(color: darkGrey),
                        ),
                      ),
                    ],
                  ),
                if (gReciptViewStrings['custgst'].toString().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          'GSTIN',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 10, // Adjust this width as needed
                        child: Text(
                          ':',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 120, // Adjust this width as needed
                        child: Text(
                          textAlign: TextAlign.left,
                          gReciptViewStrings['custgst'].toString(),
                          style: const TextStyle(color: darkGrey),
                        ),
                      ),
                    ],
                  ),
                Divider(thickness: 1, color: Colors.black),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        'Bill No',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 10, // Adjust this width as needed
                      child: Text(
                        ':',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 65, // Adjust this width as needed
                      child: Text(
                        textAlign: TextAlign.left,
                        remainingString,
                        style: const TextStyle(color: darkGrey),
                      ),
                    ),
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        textAlign: TextAlign.left,
                        lastThreeDigits,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGrey),
                      ),
                    ),
                  ],
                ),
                if (Lastclickedmodule != "Take Away" && Lastclickedmodule != "Counter")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          'Table Name',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),

                      SizedBox(
                        width: 10, // Adjust this width as needed
                        child: Text(
                          ':',
                          style: const TextStyle(color: darkGrey),
                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                          maxLines: null, // Allow text to use multiple lines
                        ),
                      ),
                      SizedBox(
                        width: 100, // Adjust this width as needed
                        child: Text(
                          textAlign: TextAlign.left,
                          gReciptViewStrings['tableName'].toString(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGrey),
                        ),
                      ),
                    ],
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        'Waiter',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 10, // Adjust this width as needed
                      child: Text(
                        ':',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        textAlign: TextAlign.left,
                        selectedwaitername.toString(),
                        style: const TextStyle(color: darkGrey),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        'Date and Time',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 10, // Adjust this width as needed
                      child: Text(
                        ':',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 150, // Adjust this width as needed
                      child: Text(
                        textAlign: TextAlign.left,
                        gReciptViewStrings['DNT'].toString(),
                        style: const TextStyle(color: darkGrey),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        'Bill By',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 10, // Adjust this width as needed
                      child: Text(
                        ':',
                        style: const TextStyle(color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        textAlign: TextAlign.left,
                        gReciptViewStrings['user'].toString(),
                        style: const TextStyle(color: darkGrey),
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.black),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100, // Adjust this width as needed
                      child: Text(
                        "Item Name",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGrey),
                        overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                        maxLines: null, // Allow text to use multiple lines
                      ),
                    ),
                    Text(
                      "Qty",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                    Text(
                      "Price",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                    Text(
                      "Amount",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.black),
                // Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: gREciptViewBillItems.length,
                  itemBuilder: (context, index) {
                    final billItem = gREciptViewBillItems[index];

                    final itemModifiers = gREciptViewBillModifiers.where((modifier) => modifier.product_code == billItem.productCode && modifier.order_id == billItem.notes).toList();

                    return Column(
                      children: [
                        ReceiptItem(
                          itemName: billItem.itemName,
                          quantity: billItem.quantity,
                          price: billItem.price,
                        ),
                        // Add more ReceiptItem or any other widgets here
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                          itemCount: itemModifiers.length,
                          itemBuilder: (context, modIndex) {
                            final modifier = itemModifiers[modIndex];
                            double amtnt = modifier.price_per_unit * modifier.quantity;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Adjust vertical padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Aligns the column to the start
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120, // Adjust this width as needed
                                        child: Text(
                                          modifier.price_per_unit > 0.0 ? '>>' + modifier.name : '>' + modifier.name,
                                          style: const TextStyle(color: darkGrey),
                                          overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
                                          maxLines: null, // Allow text to use multiple lines
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60, // Adjust this width as needed
                                        child: Text(
                                          modifier.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: darkGrey),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60, // Adjust this width as needed
                                        child: Text(
                                          textAlign: TextAlign.right,
                                          '$brandcurrencysymball${modifier.price_per_unit.toStringAsFixed(2)}',
                                          style: const TextStyle(color: darkGrey),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60, // Adjust this width as needed
                                        child: Text(
                                          textAlign: TextAlign.right,
                                          '$brandcurrencysymball${amtnt.toStringAsFixed(2)}',
                                          style: const TextStyle(color: darkGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                Divider(thickness: 1, color: Colors.black),
                SizedBox(height: 2),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sub Total',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                    Text(
                      st.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                  ],
                ),
                if (discount > 0.0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount ' + discountper.toStringAsFixed(0) + '%',
                        style: TextStyle(color: darkGrey),
                      ),
                      Text(
                        discount.toStringAsFixed(2),
                        style: const TextStyle(color: darkGrey),
                      ),
                    ],
                  ),
                if (discount > 0.0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remark(' + discountremark + ')',
                        style: TextStyle(color: darkGrey),
                      ),
                    ],
                  ),
                if (discount > 0.0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bill Amount',
                        style: TextStyle(color: darkGrey),
                      ),
                      Text(
                        billamt.toStringAsFixed(2),
                        style: const TextStyle(color: darkGrey),
                      ),
                    ],
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: localtaxes.length,
                  itemBuilder: (context, index) {
                    final taxItem = localtaxes[index];
                    return TaxItem(
                      amt: taxItem.amount,
                      taxName: taxItem.name,
                      percent: taxItem.percent,
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                    Text(
                      sttl.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Thank you Visit Us Again!', style: TextStyle(color: darkGrey)),
                if (lastMOS == "Multi settlement" || lastMOS == "UPI Online" || lastMOS == "PayPal")
                  Center(
                    child: QrImageView(
                      data: "upi://pay?pa=mab.037325021710017@axisbank&pn=DGPOS LLP&am=${sttl.toStringAsFixed(2)}&cu=INR&aid=uGICAgIDVt_7-dw",
                      size: 100,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(100, 100),
                      ),
                    ),
                  ),


              ],
            ),
          ),
        )
        ,
        // Zigzag Image (Below the Container)
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Color(0xFFFFFFFF), // Change this to your desired color
            BlendMode.srcIn,
          ),
          child: SizedBox(
            width: 400.0, // Set your desired width
            child: Image.asset(
              'assets/images/Lines.png',
              fit: BoxFit.fill,
            ),
          ),
        ),

      ],
    );
  }








}

class ReceiptItem extends StatelessWidget {
  final String itemName;
  final int quantity;
  final double price;

  const ReceiptItem({
    required this.itemName,
    required this.quantity,
    required this.price,
    super.key,
  });
  @override
  Widget build(BuildContext context) {


    // final Map<String, String> receivedStrings = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    const darkGrey = Color(0xFF424242); // Dark grey color
    double amt = price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120, // Adjust this width as needed
            child: Text(
              itemName,
              style: const TextStyle(color: darkGrey),
              overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
              maxLines: null, // Allow text to use multiple lines
            ),
          )
          ,
          SizedBox(
            width: 60, // Adjust this width as needed
            child:  Text(
              quantity.toString(),
              textAlign :TextAlign.center,
              style: const TextStyle(color: darkGrey),
            ),
          ),
          SizedBox(
            width: 60, // Adjust this width as needed
            child:   Text(
              textAlign :TextAlign.right,
              '$brandcurrencysymball${price.toStringAsFixed(2)}',
              style: const TextStyle(color: darkGrey),
            ),
          ),
          SizedBox(
            width: 60, // Adjust this width as needed
            child:   Text(
              textAlign :TextAlign.right,
              '$brandcurrencysymball${amt.toStringAsFixed(2)}',
              style: const TextStyle(color: darkGrey),
            ),
          ),
        ],
      ),
















    );
  }
}

class TaxItem extends StatelessWidget {
  final String taxName;
  final String percent;
  final double amt;

  const TaxItem({
    required this.taxName,
    required this.percent,
    required this.amt,

    super.key,
  });
  @override
  Widget build(BuildContext context) {


    // final Map<String, String> receivedStrings = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    const darkGrey = Color(0xFF424242); // Dark grey color


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 150, // Adjust this width as needed
            child: Text(
              taxName+' '+percent+'%',
              style: const TextStyle(color: darkGrey),
              overflow: TextOverflow.visible, // Allow text to overflow and wrap to the next line
              maxLines: null, // Allow text to use multiple lines
            ),
          )
          ,


          SizedBox(
            width: 60, // Adjust this width as needed
            child:   Text(
              textAlign :TextAlign.right,
              '$brandcurrencysymball${amt.toStringAsFixed(2)}',
              style: const TextStyle(color: darkGrey),
            ),
          ),
        ],
      ),












    );
  }
}

class BillItem {
  String itemName;
  String productCode;
  int quantity;
  String notes;
  double price;
  double totalPrice;
  bool isComp;
  double pricebckp;

  BillItem({
    required this.itemName,
    required this.productCode,
    required this.quantity,
    this.notes = '',
    required this.price,
    required this.totalPrice,
    this.isComp = false,
    this.pricebckp = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'productName': itemName, // Changed from 'productName' to 'itemName' for consistency
      'productCode': productCode,
      'quantity': quantity,
      'notes': notes, // Corrected key name
      'pricePerUnit': price,
      'totalPrice': totalPrice,
    };
  }
}

class   LocalTax {
  String code;
  String name;
  String percent;
  double amount;

  LocalTax(this.code, this.name, this.percent, this.amount);

  @override
  String toString() {
    return 'Tax(name: $name, amount: $amount)';
  }

  Map<String, dynamic> toJson() {
    return {
      "tax_code": code,
      "tax_name": name,
      "tax_percent": percent,
      "tax_amount": amount.toStringAsFixed(2),
    };
  }
}