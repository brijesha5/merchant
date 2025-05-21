import 'dart:convert';

import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:flutter_sample/main_menu_desk.dart';
import 'package:flutter_sample/utils/toast_utils.dart';
import 'package:flutter_scanner_aar/flutter_scanner_aar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sample/Order_Item_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Costcenter_model.dart';
import 'FireConstants.dart';
import 'NativeBridge.dart';
import 'OrderModifier.dart';
import 'ReceiptView.dart';
import 'dialogs/qr_dialog.dart';
import 'list_of_product_screen.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter/material.dart';

import 'logger.dart';
import 'main_menu.dart';

class GenerateBillscreen extends StatefulWidget {
  const GenerateBillscreen({super.key});

  @override
  _GenerateBillscreenState createState() => _GenerateBillscreenState();
}

class _GenerateBillscreenState extends State<GenerateBillscreen> {
  late Map<String, String> tableinfo;

  /////kot////////
  List<SelectedProduct> selectedProducts = [];
  List<SelectedProductModifier> selectedModifiers = [];

  List<Widget> rows = [];

///////////////////////mosambe////////////////
  String currentTask = "",
      _transactionId = "",
      _message = "",
      _transactionAmount = "",
      _transactionReasonCode = "",
      _transactionReason = "",
      _task = "",
      _iin = "";

  dynamic _transactionData;

  late String _username = "9920593222", //"7738718086",
      _password = "3241",
      _amount = "10";

///////////////////////mosambe////////////////
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
  String tableName = "";
  double cgstpercentage = 2.50;
  double sgstpercentage = 2.50;
  double vatpercentage = 0.00;
  double scpercentage = 0.00;
  double discountpercentage = 0;
  double sumoftax = 0.0;
  String serviceTax='';
  //ADDED BY SANTOSH
  String addRemoveItems="";
  //ENDED
  Future<List<OrderItem>> fetchKotItems(String tablenumber) async {
    allbillitems.clear();

    final response = await http.get(
        Uri.parse('${apiUrl}order/bytable/$tablenumber' + '?DB=' + CLIENTCODE));

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
            notes: item.orderNumber.toString(),
            totalPrice: tempitemtotal);

        // Add the BillItem object to the list
        allbillitems.add(billItem);
        double temp = (item.price ?? 0.00) * (item.quantity ?? 0.00);
        nsubtotal = nsubtotal + temp;
      }
      if (Lastclickedmodule == "Dine") {
        if (subtotal != nsubtotal) {
          updateState(nsubtotal);
        }
      }

      _isLoading = false;
      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }

  Future<List<OrderModifier>> fetchModifiers(String tablenumber) async {
    allbillmodifers.clear();

    final response = await http.get(Uri.parse(
        '${apiUrl}order/modifierbytable/$tablenumber' + '?DB=' + CLIENTCODE));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

      List<OrderModifier> toreturn = parsed
          .map<OrderModifier>((json) => OrderModifier.fromMap(json))
          .toList();

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
        double temp =
            (double.parse(item.pricePerUnit) ?? 0.00) * (item.quantity ?? 0.00);
        nsubtotal = nsubtotal + temp;
      }
      /*   if (Lastclickedmodule == "Dine") {
        if (subtotal != nsubtotal) {
          updateState(nsubtotal);
        }
      }*/

      updateState(nsubtotal + subtotal);

      _isLoading = false;
      return toreturn;
    } else {
      throw Exception('Failed to load Product');
    }
  }

  void updateState(double nsubtotal) {
    /*if (subtotal == nsubtotal) {
      print("Skipping updateState to prevent duplicate execution");
      return; // Prevent unnecessary execution
    }*/

    setState(() {
      print("Updating state for $Lastclickedmodule");
      subtotal = nsubtotal;
      rows.clear();
      double temptaxsum = 0.0;
      allbilltaxes.clear();

      for (var tax in globaltaxlist) {
        String isApplicableOncurrentmodlue = "N";

        switch (Lastclickedmodule) {
          case 'Dine':
            isApplicableOncurrentmodlue = tax.isApplicableonDinein;
            serviceTax="10";

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
          double pec = double.parse(tax.taxPercent);

          double taxable = 0.0;
          if (billamount > 0.0) {
            // taxable = (pec / 100.00) * billamount;
            taxable = (pec / 100.00) * subtotal;

          } else {
            double serviceCharge = double.parse(globaltaxlist[0].taxPercent.toString());
            if(globaltaxlist.indexOf(tax) == 0){
              taxable = (pec / 100.00) * nsubtotal;
            }else{
              double serviceTax=subtotal * serviceCharge /100;
              double nsubtotal=serviceTax + subtotal;
              taxable = (pec / 100.00) * nsubtotal;
            }
          }
          allbilltaxes
              .add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
          temptaxsum += taxable;
          rows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tax.taxName}:(${tax.taxPercent}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  taxable.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );

        }
      }

      /*  double taxCharges =subtotal * double.parse(serviceTax)/100;
      nsubtotal=subtotal + taxCharges; // service charge plus total amount*/
      if (sumoftax != temptaxsum) {
        sumoftax = temptaxsum;
      }

      cgst = (cgstpercentage / 100.00) * nsubtotal;
      sgst = (sgstpercentage / 100.00) * nsubtotal;
      sc = (scpercentage / 100.00) * nsubtotal;
      vat = (vatpercentage / 100.00) * nsubtotal;
      discount = (discountpercentage / 100.00) * nsubtotal;

      if (billamount > 0.0) {
        grandtotal = billamount + temptaxsum;
        _amount = grandtotal.toString();
      } else {
        grandtotal = subtotal - discount + temptaxsum;
        _amount = grandtotal.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    TextEditingController mobileController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController gstController = TextEditingController();

    // Retrieve the arguments from the ModalRoute
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Map<String, dynamic>? arguments =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        Map<String, String> tableinfo = arguments['tableinfo']
        as Map<String, String>; // Access route arguments
        futureKOTs = fetchKotItems(tableinfo['name']!);

        futureModifiers = fetchModifiers(tableinfo['name']!);

        setState(() {}); // Trigger rebuild to update UI with tableinfo
      }
      // Fetch the KOT items
    });

    requestPermission();

    _listenTransactionData();
    _listenPrinter();
  }

  ///////////////////////mosambeee////////////////

  Future<void> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.phone
    ].request();
  }

  Future<void> _listenTransactionData() async {
    FlutterMosambeeAar.onResult.listen((resultData) async {
      Logger.d(
          " =========== Result data is ============ ${resultData.toMap()}");

      if (resultData.result != null && resultData.result == true) {
        //Logger.d(resultData.transactionData ?? "");

        final body = json.decode(resultData.transactionData ?? "{}");

        if (currentTask == "CASH" || currentTask == "CHEQUE") {
          printReceiptWithTransactionId("${body['transactionId']}");
        } else {
          if (body["result"] != null &&
              body["result"] == "success" &&
              body["transactionId"] != "NA" &&
              body["transactionId"] != "00") {
            printReceipt(resultData.transactionData ?? "");
          } else {
            if (resultData.reasonCode == "MD14") {
              Logger.d("Duplicate Transaction");
            } else {
              Logger.d("Transaction Failed");
            }
          }
        }
      } else {
        ToastUtils.showErrorToast(resultData.reason ?? "");
      }

      try {
        if (QRDialog.isDialogOpen()) {
          QRDialog.closeDialog();
        }
      } catch (e) {
        Logger.d("Exception in QR Dialog::::$e");
      }

      if (resultData.result != null && resultData.result == true) {
        final body = json.decode(resultData.transactionData ?? "{}");
        if (currentTask == "GENERATE BQR" || currentTask == "UPI QR") {
          if (currentTask == "GENERATE BQR") {
            QRDialog.showQRDialog(context, currentTask, body["message"],
                "AMOUNT : ${body["amount"]}");
          } else if (currentTask == "UPI QR") {
            QRDialog.showQRDialog(context, currentTask, body["message"],
                "AMOUNT : ${resultData.amount}");
          } else {
            QRDialog.showQRDialog(context, currentTask, body["message"], "");
          }
        } else {
          _transactionId = body["transactionId"] ?? "";
          _transactionAmount = body["amount"] ?? "";
          _transactionData = body;

          handleSuccessResponse(resultData.transactionData ?? "", currentTask);
        }
      } else {
        _transactionReason = resultData.reason ?? "";
        _transactionReasonCode = resultData.reasonCode ?? "";
        _task =
        "Transaction Failed\n$_transactionReasonCode\n$_transactionReason";
        performActions(_task);
      }
    });

    FlutterMosambeeAar.onCommand.listen((command) {
      Logger.d("Command data is $command");
      ToastUtils.showNormalToast(command);
      if (command != "Signature Required.") {
        getAndroidBuildModel().then((String model) {
          if (model == "D20" && command.contains("Enter PIN")) {
          } else {}
        });
      } else {}
    });

    FlutterScannerAar.onScanResult.listen((result) {
      Logger.d(
          " ===========ScanResult Result data is ============ ${result.toMap()}");

      ToastUtils.showErrorToast(result.toMap().toString());
    });
  }

  Future<void> _listenPrinter() async {
    FlutterMosambeeAar.onPrintStart.listen((onPrintStart) async {
      ToastUtils.showNormalToast(onPrintStart);
    });

    FlutterMosambeeAar.onPrintFinish.listen((onPrintFinish) async {
      ToastUtils.showNormalToast(onPrintFinish);
      FlutterMosambeeAar.closePrinter();
    });

    FlutterMosambeeAar.onPrintError.listen((command) {
      Logger.d("Command data is $command");
      ToastUtils.showErrorToast(command.message ?? "");
      FlutterMosambeeAar.closePrinter();
    });
  }

  void handleSuccessResponse(String transactionData, String currentTask) {
    postData(context, selectedProducts, selectedModifiers, tableinfo);
    lastMOS = 'Card';

    Logger.d("Current Task :$currentTask");

    if (currentTask == "") {
      return;
    }
    switch (currentTask) {
      case "SCAN":
        performActions("SCAN");
        return;

      case "SALE":
      case "PREAUTH":
      case "CASH":
      case "CHEQUE":
      case "PWCB":
      case "CASH WITHDRAWAL":
      case "BALANCE ENQUIRY":
        _task = "Transaction Success\n$_transactionId\n$_transactionAmount";
        showResponseDialog(_task);
        return;
      case "SALE+TIP":
        String tip = _transactionData["tipAmount"];
        _task =
        "Transaction Success\n$_transactionId\nAmount - $_transactionAmount\nTipAmount - $tip";
        showResponseDialog(_task);
        return;

      case "PRINT RECEIPT":
        FlutterMosambeeAar.initialise(_username, _password);
        FlutterMosambeeAar.setInternalUi(false);
        try {
          FlutterMosambeeAar.printSettlementBatchDetails(
              _transactionData["settlementSummary"], false, 1, 0);
        } catch (e) {
          Logger.d("Exception in Settlement Batch Details::::$e");
        }
        currentTask = "NA";
        return;

      case "NA":
        showResponseDialog(_transactionData);
        return;
      case "UPI COLLECT":
        try {
          _task = _transactionData["message"] +
              "\n" +
              _transactionData["transactionId"];
          showResponseDialog(_task);
        } catch (e) {
          Logger.d("Exception in Settlement Batch Details::::$e");
        }
        return;
      case "UPI CHECK STATUS":
        try {
          _task = _transactionData["message"] +
              "\n" +
              _transactionData["transactionId"];
          showResponseDialog(_task);
        } catch (e) {
          Logger.d("Exception in Settlement Batch Details::::$e");
        }
        return;
      case "BQR CHECK STATUS":
        Logger.d("Handle Success BQR check status");
        try {
          _task = _transactionData["message"] +
              "\n" +
              _transactionData["transactionID"];
          showResponseDialog(_task);
        } catch (e) {
          Logger.d("Exception in Settlement Batch Details::::$e");
        }
        return;
      case "VOID":
        showResponseDialog(_transactionData);
        return;
      case "BQR":
        return;
      case "UPI":
        return;
      case "CARD TRANSACTION HISTORY":
        showResponseDialog(_transactionData);
        return;
      case "NON CARD TRANSACTION HISTORY":
        showResponseDialog(_transactionData);
        return;
      case "ONLINE HISTORY":
        showResponseDialog(_transactionData);
        return;
      case "SALE COMPLETE":
        showResponseDialog(_transactionData);
        return;
      case "ADVANCE HISTORY":
        showResponseDialog(_transactionData);
        return;
      default:
        _task = "Transaction Success\n$_transactionId\n$_transactionAmount";
        showResponseDialog(_transactionData);
        return;
    }
  }

  Future<String> getAndroidBuildModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }

  void printReceipt(String jsonObject) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.printReceipt(jsonObject, 0, false, true);

    print("Print Receipt called$jsonObject");
  }

  void printReceiptWithTransactionId(String transactionId) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.printTransactionReceipt(transactionId, 0);
  }

  void performNonCardTransaction(String transactionType) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.setInternalUi(false);
    switch (transactionType) {
      case "GENERATE BQR":
        FlutterMosambeeAar.generateBharatQR(
            double.parse(_amount), "test", "", false);
        break;

      case "BQR CHECK STATUS":
        currentTask = "BQR CHECK STATUS";
        FlutterMosambeeAar.checkBharatQRStatus(
            double.parse(_amount), "2023-01-22", "test", "123123234");
        break;

      case "UPI COLLECT":
        FlutterMosambeeAar.callToUPI(
            "", double.parse(_amount), "", "anju.katiyar@okhdfcbank");
        break;

      case "UPI CHECK STATUS":
        FlutterMosambeeAar.checkUPIStatus("2023110611314645898651464");
        break;

      case "UPI QR":
        FlutterMosambeeAar.generateUPIQR(double.parse(_amount), "Test");
        break;

      case "SMS PAY":
        FlutterMosambeeAar.callToSMSPay(
            "8850790331", double.parse(_amount), "", "");
        break;

      case "EMAIL":
        FlutterMosambeeAar.sendEmail("607769221", "quality@mosambee.com");
        break;

      case "SMS":
        FlutterMosambeeAar.sendSMS("607769221", "8850790331");
        break;

      case "CASH":
        FlutterMosambeeAar.doChequeCash("CASH", double.parse(_amount), "Hardik",
            "", "12345678", "h", false);
        break;

      case "CHEQUE":
        FlutterMosambeeAar.doChequeCash("CHEQUE", double.parse(_amount),
            "Hardik", "1232233243", "123", "jhj", false);
        break;

      case "PRINT RECEIPT":
        FlutterMosambeeAar.printTransactionReceipt("292854260208", 0);
        break;

      case "ONLINE HISTORY":
      case "NON CARD TRANSACTION HISTORY":
        FlutterMosambeeAar.getNonCardTransactionHistory("10");
        break;
      case "ADVANCE HISTORY":
        FlutterMosambeeAar.getAdvanceHistory(
            "SALE", "2021-01-01", "2023-11-01", "10");
        break;
      case "CARD TRANSACTION HISTORY":
        FlutterMosambeeAar.getTransactionHistory("10");
        break;
      case "VOID":
        FlutterMosambeeAar.getVoidList();
        break;
      case "SETTLEMENT":
        FlutterMosambeeAar.doSettlement();
        break;
      case "SALE COMPLETE":
        FlutterMosambeeAar.getSaleCompleteList();
        break;
    }
  }

  void showResponseDialog(dynamic transactionData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Response'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('$transactionData'), // Long text for demonstration
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
            ),
          ],
        );
      },
    );
  }

  customPrint() async {
    FlutterMosambeeAar.openPrinter();
    int? state = await FlutterMosambeeAar.getPrinterState();
    if (kDebugMode) {
      print('state: $state');
    }
    FlutterMosambeeAar.setPrintFont("/system/fonts/Android-1.ttf");
    FlutterMosambeeAar.setPrintGray(2000);
    FlutterMosambeeAar.setLineSpace(5);
    //FlutterMosambeeAar.cleanCache();
    String str1 = "This is an example of a receipt";
    FlutterMosambeeAar.printText2(str1, FlutterMosambeeAar.PRINTLINE_CENTER);

    ByteData bytes = await rootBundle.load('assets/images/hdfc_logo1.png');
    var buffer = bytes.buffer;
    var base64Image = base64.encode(Uint8List.view(buffer));

    if (kDebugMode) {
      print("img_pan : $base64Image");
    }

    FlutterMosambeeAar.printImage(
        base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);

    FlutterMosambeeAar.setPrintFontAssets("poppins_regular.ttf");

    String str2 =
        "Floor ** , Building **, No.*** LONG DONG Avenue, Pudong New District, Shanghai, China";
    FlutterMosambeeAar.printText3(
        str2, FlutterMosambeeAar.PRINTLINE_CENTER, 20);

    FlutterMosambeeAar.setPrintFont("/system/fonts/DroidSansMono.ttf");
    FlutterMosambeeAar.printList(
        "DATE: 17-11-2022", "", "TIME: 16:28:44", 20, false);

    FlutterMosambeeAar.printList(
        "ഇത് സാമ്പിൾ ആണ്", "", "TIME: 16:28:44", 20, false);
    FlutterMosambeeAar.printList("ಇದು ಮಾದರಿ", "", "TIME: 16:28:44", 20, false);
    FlutterMosambeeAar.printList("이것은 샘플입니다", "", "TIME: 16:28:44", 20, false);
    FlutterMosambeeAar.printList(
        "यह नमूना है", "", "TIME: 16:28:44", 20, false);
    FlutterMosambeeAar.printList(
        "ਇਹ ਨਮੂਨਾ ਹੈ", "", "TIME: 16:28:44", 20, false);

    FlutterMosambeeAar.printList("Item", "Quantity", "Price", 24, true);
    FlutterMosambeeAar.printList("Tomato", "1", "\$2.08", 24, false);
    FlutterMosambeeAar.printList("Orange", "1", "\$1.06", 24, false);

    FlutterMosambeeAar.printText2(
        "Total  \$3.14", FlutterMosambeeAar.PRINTLINE_RIGHT);
    FlutterMosambeeAar.printText1("");

    FlutterMosambeeAar.printText1("");
    String str3 =
        "Did you know you could have earned Rewards points on this purchase?";
    FlutterMosambeeAar.printText2(str3, FlutterMosambeeAar.PRINTLINE_CENTER);

    FlutterMosambeeAar.printText2("Simply sign up today for a Membership Card!",
        FlutterMosambeeAar.PRINTLINE_CENTER);

    FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

    if (state != null && state == 4) {
      FlutterMosambeeAar.closePrinter();
      return;
    }
    FlutterMosambeeAar.beginPrint();
  }

  performActions(final String task) {
    if (currentTask == "SCAN") {
      FlutterScannerAar.initialise();
      FlutterScannerAar.setWorkMode(0);
      FlutterScannerAar.startScan();
      if (kDebugMode) {
        // KozenScanner.startScan();

        // print("""version:::${KozenScanner().getPlatformVersion()}""");
        // print(KozenScanner().getPlatformVersion());
      }
    } else if (task == "getAmount") {
      if (currentTask == "GENERATE BQR" ||
          currentTask == "BQR CHECK STATUS" ||
          currentTask == "UPI CHECK STATUS" ||
          currentTask == "UPI QR" ||
          currentTask == "PRINT RECEIPT" ||
          currentTask == "CARD TRANSACTION HISTORY" ||
          currentTask == "NON CARD TRANSACTION HISTORY" ||
          currentTask == "ADVANCE HISTORY" ||
          currentTask == "VOID" ||
          currentTask == "SETTLEMENT" ||
          currentTask == "SALE COMPLETE") {
        performNonCardTransaction(currentTask);
      } else {
        // Logger.d("Current Task is $currentTask");
        performTransaction(currentTask, _amount, false);
      }
    } else if (task == "getAmount_Para1") {
      if (currentTask == "SALE+TIP" || currentTask == "PWCB") {
        performTransactionWithCashback(currentTask, _amount, "1");
      } else {
        performNonCardTransaction(currentTask);
      }
    }
  }

  void performTransactionWithCashback(
      String transType, String amount, String cashbackAmount) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.initializeSignatureView("#55004A", "#750F5A");
    FlutterMosambeeAar.initialiseFields(transType, "", "cGjhE\$@fdhj4675riesae",
        false, "", "merchantRef1", "bt", "09082013101105", cashbackAmount);
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.processTransaction("123456", "", double.parse(amount),
        double.parse("0"), "ShiperId-879209", "INR");
  }

  void performTransaction(
      String transactionType, String amount, bool isCardNumberCall) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.initializeSignatureView("#55004A", "#750F5A");
    FlutterMosambeeAar.initialiseFields(
        transactionType, "", "", false, "", "merchantRef1", "bt", "", "");
    FlutterMosambeeAar.setInternalUi(false);
    try {
      FlutterMosambeeAar.setAdditionalTransactionData("null");
    } catch (e) {
      Logger.d("Exception in setAdditionalTransactionData::::$e");
    }
    FlutterMosambeeAar.getCardNumber(isCardNumberCall);
    FlutterMosambeeAar.processTransaction("1234567", "Test",
        double.parse(amount), double.parse("0"), "ShiperId-879209", "INR");
  }

  ///////////////////////mosambeee////////////////

  Future<void> printTicket(List<int> ticket, String targetip) async {
    final printer = PrinterNetworkManager(targetip);
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);

      print(printing.msg);
      printer.disconnect();
    }
  }

  Future<List<int>> testBILL(
      String billno,
      List<BillItem> items,
      List<SelectedProductModifier> modifiers,
      String tableno,
      double grandtotal,
      double cgstpercentt,
      double sgstpercentt,
      double cgstt,
      double sgstt,
      double vattpercentt,
      double vatt,
      double scpercentt,
      double scc,
      double discpercentt,
      double disc,
      String drmark,
      int pax) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    double grandttle = subtotal + sumoftax - discount;

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

    bytes += generator.text(brandName,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
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
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));

    bytes += generator.text(Addresslinetwo,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));

    bytes += generator.text(Addresslinethree,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
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

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text(
      Lastclickedmodule,
      styles: const PosStyles(
        fontType: PosFontType.fontB,
        bold: false,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        align: PosAlign.center,
      ),
    );
    if (custname.isNotEmpty) {
      bytes +=
          generator.text('________________________________________________',
              styles: PosStyles(
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
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: ':    ' + custname.toString(),
          width: 8,
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

    if (custmobile.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: '  Mobile No',
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
          text: '    :    ' + brandmobile.toString(),
          width: 9,
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

    if (custgst.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: '  GSTIN',
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
          text: '    :    ' + custgst.toString(),
          width: 9,
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
    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
        text: 'Bill No       :',
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
        text: prefix,
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          align: PosAlign.right,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: suffix,
        width: 2,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'PAX :' + pax.toString() + '  ',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.right,
        ),
      ),
    ]);

    if (Lastclickedmodule != "Take Away" &&
        Lastclickedmodule != "Counter" &&
        Lastclickedmodule != "Online") {
      bytes += generator.row([
        PosColumn(
          text: '  Table No      :',
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
          text: ' ' + tableno,
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

    bytes += generator.row([
      PosColumn(
        text: '  Waiter',
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
        text: '    :    ' + selectedwaitername,
        width: 9,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
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
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: ':    ' +
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

    bytes += generator.row([
      PosColumn(
        text: '  Bill By',
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
        text: '    :    ' + username,
        width: 9,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
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
        text: 'Item Name',
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
        text: 'Qty',
        width: 2,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ),
      ),
      PosColumn(
        text: 'Price' + ' ',
        width: 2,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ),
      ),
      PosColumn(
        text: 'Amount' + ' ',
        width: 3,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.right,
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
    for (BillItem item in items) {
      final itemModifiers = modifiers
          .where((modifier) =>
      modifier.product_code == item.productCode &&
          modifier.order_id == item.notes)
          .toList();

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
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.quantity.toString(),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.price.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.totalPrice.toStringAsFixed(2) + ' ',
            width: 3,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: spart,
            width: 6,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: '  ',
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      } else {
        bytes += generator.row([
          PosColumn(
            text: item.itemName,
            width: 5,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.quantity.toString(),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.price.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: item.totalPrice.toStringAsFixed(2) + ' ',
            width: 3,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      }

      for (SelectedProductModifier modi in itemModifiers) {
        double tamount = modi.price_per_unit * modi.quantity;
        bytes += generator.row([
          PosColumn(
            text:
            modi.price_per_unit > 0 ? '>> ' + modi.name : '> ' + modi.name,
            width: 5,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: modi.quantity.toString(),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: modi.price_per_unit.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: tamount.toStringAsFixed(2) + ' ',
            width: 3,
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      }
    }

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
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
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        width: 4,
      ),
      PosColumn(
        text: subtotal.toStringAsFixed(2) + ' ',
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
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

    if (discpercentt > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount ' + discpercentt.toString() + '%',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          width: 3,
        ),
        PosColumn(
          text: disc.toStringAsFixed(2) + ' ',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Remark(' + drmark + ')',
          width: 10,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            height: PosTextSize.size1,
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
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }

    if (disc > 0.0) {
      bytes += generator.row([
        PosColumn(
          text: 'Bill Amount',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            height: PosTextSize.size1,
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
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
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

      if (isApplicableOncurrentmodlue == "Y") {
        double pec = double.parse(tax.taxPercent);
        double taxable = 0.0;

        if (discount > 0.0) {
          if (tax.taxName == "Service Charge") {
            if (GLOBALNSC == "Y") {
              taxable = (0.0 / 100.00) * billamount;
            } else {
              //service tax
              double serviceCharge = double.parse(globaltaxlist[0].taxPercent.toString());
              if(globaltaxlist.indexOf(tax) == 0){
                taxable = (pec / 100.00) * subtotal;

                //taxable = (pec / 100.00) * billamount;
              }else{
                if(Lastclickedmodule=="Dine"){
                  double serviceTax=subtotal * serviceCharge /100;
                  double billamount=serviceTax + subtotal;
                  taxable = (pec / 100.00) * billamount;
                }else{
                  taxable = (pec / 100.00) * subtotal;

                }
              }

              //taxable = (pec / 100.00) * billamount;
            }
          } else {
            taxable = (pec / 100.00) * billamount;
          }
        } else {
          if (tax.taxName == "Service Charge") {
            if (GLOBALNSC == "Y") {
              taxable = (0.0 / 100.00) * subtotal;
            } else {
              taxable = (pec / 100.00) * subtotal;
            }
          } else {
            //service tax
            double serviceCharge = double.parse(globaltaxlist[0].taxPercent.toString());
            if(globaltaxlist.indexOf(tax) == 0){
              taxable = (pec / 100.00) * billamount;
            }else{
              if(Lastclickedmodule=="Dine"){
                double serviceTax=subtotal * serviceCharge /100;
                double billamount=serviceTax + subtotal;
                taxable = (pec / 100.00) * billamount;
              }else{
                taxable = (pec / 100.00) * subtotal;
              }

            }
    // taxable = (pec / 100.00) * subtotal;
    }
    }
        bytes += generator.row([
          PosColumn(
            text: '${tax.taxName} ${tax.taxPercent}%',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              underline: false,
              height: PosTextSize.size1,
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
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      }
    }

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
        text: ' Grand Total',
        width: 5,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
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
          text: grandttle.toStringAsFixed(2) + '  ',
          width: 4,
          styles: const PosStyles(
            fontType: PosFontType.fontB,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.text('________________________________________________',
        styles: PosStyles(
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

    bytes += generator.text(Lastclickedmodule,
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
        text: prefix,
        width: 2,
        styles: const PosStyles(
          fontType: PosFontType.fontB,
          bold: false,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
      PosColumn(
        text: suffix,
        width: 8,
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.left,
        ),
      ),
    ]);

    if (tableno != "0") {
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
          text: ' ' + tableno,
          width: 3,
          styles: const PosStyles(
            fontType: PosFontType.fontA,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            align: PosAlign.center,
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
    }

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
          .where((modifier) =>
      modifier.product_code == item.code &&
          modifier.order_id == item.notes)
          .toList();

      String temp = item.name;

      String fpart = '';
      String spart = '';
      bool ismultline = false;

      if (temp.length <= 22) {
        print('String length is less than or equal to 20 characters: $temp');
      } else {
        int spaceIndex = temp.lastIndexOf(' ', 23);

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
            text: fpart,
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

        bytes += generator.row([
          PosColumn(
            text: '',
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
            text: spart,
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
      } else {
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
        bytes += generator.text('',
            styles: const PosStyles(
              fontType: PosFontType.fontA,
              bold: false,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ));
      }

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

    for (String ip in printers) {
      printTicket(bytes, ip);
    }

    printers.clear();

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
  Widget build(BuildContext contextmain) {
    Map<String, dynamic> arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    /* List<
        SelectedProduct> selectedProducts = arguments['selectedProducts'] as List<
        SelectedProduct>;*/
    tableinfo = arguments['tableinfo'] as Map<String, String>;

    /////kot////////

    if (Lastclickedmodule == "Take Away") {
      selectedProducts = arguments['selectedProducts'] as List<SelectedProduct>;
      selectedModifiers =
      arguments['selectedModifiers'] as List<SelectedProductModifier>;
      double subtotal = 0.0;

      // Calculate subtotal for selected products
      for (var product in selectedProducts) {
        subtotal += product.price * product.quantity;
      }

      // Calculate subtotal for selected modifiers
      for (var modifier in selectedModifiers) {
        subtotal += modifier.price_per_unit * modifier.quantity;
      }

      updateState(subtotal);
    } else if (Lastclickedmodule == "Counter") {
      // Assuming you have the list of products and modifiers for the Counter module
      selectedProducts = arguments['selectedProducts'] as List<SelectedProduct>;
      selectedModifiers =
      arguments['selectedModifiers'] as List<SelectedProductModifier>;
      double subtotal = 0.0;

      // Calculate subtotal for selected products
      for (var product in selectedProducts) {
        subtotal += product.price * product.quantity;
      }

      // Calculate subtotal for selected modifiers
      for (var modifier in selectedModifiers) {
        subtotal += modifier.price_per_unit * modifier.quantity;
      }

      updateState(subtotal);
    } else if (Lastclickedmodule == "Online") {
      // Assuming you have the list of products and modifiers for the Counter module
      selectedProducts = arguments['selectedProducts'] as List<SelectedProduct>;
      selectedModifiers =
      arguments['selectedModifiers'] as List<SelectedProductModifier>;
      double subtotal = 0.0;

      // Calculate subtotal for selected products
      for (var product in selectedProducts) {
        subtotal += product.price * product.quantity;
      }

      // Calculate subtotal for selected modifiers
      for (var modifier in selectedModifiers) {
        subtotal += modifier.price_per_unit * modifier.quantity;
      }

      updateState(subtotal);
    } else if (Lastclickedmodule == "Home Delivery") {
      // Assuming you have the list of products and modifiers for the Counter module
      selectedProducts = arguments['selectedProducts'] as List<SelectedProduct>;
      selectedModifiers =
      arguments['selectedModifiers'] as List<SelectedProductModifier>;
      double subtotal = 0.0;

      // Calculate subtotal for selected products
      for (var product in selectedProducts) {
        subtotal += product.price * product.quantity;
      }

      for (var modifier in selectedModifiers) {
        subtotal += modifier.price_per_unit * modifier.quantity;
      }
      updateState(subtotal);
    } else if (Lastclickedmodule == "Dine") {
      if(addRemoveItems!="1"){
        double subtotal = 0.0;
        for (BillItem bi in allbillitems) {
          subtotal += (bi.price ?? 0.00) * (bi.quantity ?? 0.00);
        }
        for (SelectedProductModifier m in allbillmodifers) {
          subtotal += m.price_per_unit * m.quantity;
        }

        updateState(subtotal);
      }

    }

    /////kot////////

    Widget buildList(List<SelectedProduct> items) {
      bool isDesktop = MediaQuery.of(context).size.width > 600;
      return ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          SelectedProduct item = items[index];
          final totalPrice = item.quantity * item.price;
          final itemModifiers = selectedModifiers
              .where((modifier) =>
          modifier.product_code == item.code &&
              modifier.order_id == item.notes)
              .toList();

          return ListTile(
            leading: SizedBox(
              width: 30,
              height: 40,
              child: InkWell(
                onTap: () {
                  // Add your button click logic here
                  print('Button Clicked');

                  setState(() {
                    item.isComp = !item.isComp;

                    if (item.isComp) {
                      // Set the price to 0.00 and store the current price in pricebckp
                      item.pricebckp = item.price;
                      item.price = 0.00;
                    } else {
                      // Restore the original price from pricebckp
                      item.price = item.pricebckp;
                    }

                    // Update the corresponding BillItem in allbillitems
                    for (var billItem in allbillitems) {
                      if (billItem.productCode == item.code.toString()) {
                        billItem.price = item.price;
                        billItem.totalPrice =
                            billItem.quantity * billItem.price;
                        break;
                      }
                    }

                    // Recalculate the subtotal
                    double newSubtotal = allbillitems.fold(
                        0.0, (sum, billItem) => sum + billItem.totalPrice);
                    updateState(newSubtotal);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: item.isComp ? Colors.green : Colors.grey,
                  ),
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: Text(
                      'Com',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              item.name.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: isDesktop
                                  ? 1030.0
                                  : 140.0), // Change padding for desktop vs mobile
                          child: Text(
                            "${item.price}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Text(
                      totalPrice.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  // Prevent nested scrolling
                  itemCount: itemModifiers.length,
                  itemBuilder: (context, modIndex) {
                    final modifier = itemModifiers[modIndex];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      // Adjust vertical padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Aligns the column to the start
                        children: [
                          Text(
                            modifier.name,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 16, // Adjust font size as needed
                              fontWeight:
                              FontWeight.normal, // Make the name stand out
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 120.0),
                                    // Move 120px to the left
                                    child: Text(
                                      "${modifier.price_per_unit}",
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "${modifier.quantity}",
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Text(
                                (modifier.price_per_unit * modifier.quantity)
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    // Example functions for calculating totals (replace with actual logic)
    double calculateSubtotal() {
      return 0.0;
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

    void showDiscountDialog() async {
      TextEditingController discountpercantageController =
      TextEditingController(text: discountpercentage.toInt().toString());
      TextEditingController discountamountController = TextEditingController();
      TextEditingController discountremarkController =
      TextEditingController(text: discountremark.toString());

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Theme(
            data: ThemeData(
              // Customize the background color of the AlertDialog
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              title: const Center(
                child: Text(
                  'Discount',
                  style: TextStyle(
                    color: Color(0xFFD5282A),
                    // Red color for the discount header
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Increased font size for the title
                  ),
                ),
              ),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Percentage field with grey labels inside the box
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        controller: discountpercantageController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                          Color(0xff707070), // Dark grey text inside input
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Percentage %',
                          labelStyle: TextStyle(color: Color(0xff707070)),
                          // Light grey label above input
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(
                                    0xffd3d3d3)), // Red border when focused
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Divider line before and after "Or" text
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFD5282A),
                            thickness: 0.2, // Red color and width of 0.2
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Or',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFD5282A),
                              // New red color for 'Or'
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFFD5282A),
                            thickness: 0.2, // Red color and width of 0.2
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Amount field with grey labels inside the box
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        controller: discountamountController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                          Color(0xff707070), // Dark grey text inside input
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: Color(0xff707070)),
                          // Light grey label above input
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(
                                    0xffd3d3d3)), // Red border when focused
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Remark field with grey labels inside the box
                    SizedBox(
                      height: 80, // Adjust the height as needed
                      child: TextField(
                        controller: discountremarkController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                          Color(0xff707070), // Dark grey text inside input
                        ),
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          labelText: 'Remark',
                          labelStyle: TextStyle(color: Color(0xff707070)),
                          // Light grey label above input
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(
                                    0xffd3d3d3)), // Red border when focused
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),

                    // Add Button (rounded square)
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFFEE0606)),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        ),
                      ),
                      onPressed: () {
                        String textFieldValue =
                            discountpercantageController.text;
                        String descountamountfeild =
                            discountpercantageController.text;
                        String remark = discountremarkController.text;

                        double convertedValue = double.parse(textFieldValue);
                        double descamtconvertedValue =
                        double.parse(textFieldValue);

                        double dsc = 0.0;

                        if (convertedValue == 0 && descamtconvertedValue > 0) {
                          dsc = descamtconvertedValue;
                        } else {
                          dsc = (convertedValue / 100.00) * subtotal;
                        }

                        setState(() {
                          discountpercentage = convertedValue;
                          discount = dsc;
                          discountremark = remark;
                          billamount = subtotal - discount;
                        });

                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel Button (grey text)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey, // Grey text color
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          // Rounded corners
                          side: BorderSide(color: Colors.grey), // Grey border
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              actions: const [], // No actions, no close icon
            ),
          );
        },
      );
    }

    void showNSCDialog() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Theme(
            data: ThemeData(
              // Customize the background color of the AlertDialog
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              title: const Center(
                child: Text(
                  'NSC',
                  style: TextStyle(
                    color: Color(0xFFD5282A),
                    // Red color for the discount header
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Increased font size for the title
                  ),
                ),
              ),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Percentage field with grey labels inside the box

                    const SizedBox(height: 10),

                    // Divider line before and after "Or" text

                    // Add Button (rounded square)
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFFEE0606)),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        ),
                      ),
                      onPressed: () {
                        if (GLOBALNSC == "Y") {
                          GLOBALNSC = "N";
                        } else if (GLOBALNSC == "N") {
                          GLOBALNSC = "Y";
                        }

                        updateState(subtotal);

                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        GLOBALNSC == 'Y'
                            ? 'Remove Service Charge'
                            : 'Add Service Charge',
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel Button (grey text)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey, // Grey text color
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          // Rounded corners
                          side: BorderSide(color: Colors.grey), // Grey border
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              actions: const [], // No actions, no close icon
            ),
          );
        },
      );
    }

    void showCustomerDialog() async {
      TextEditingController mobileController = TextEditingController();
      TextEditingController nameController = TextEditingController();
      TextEditingController gstController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Theme(
            data: ThemeData(
              // Customize the background color of the AlertDialog
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              title: const Center(
                child: Text(
                  'Customer Details',
                  style: TextStyle(
                    color: Color(0xFFD5282A), // Red title color
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Increased font size for the title
                  ),
                ),
              ),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mobile No. field
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        controller: mobileController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xff000000), // Black text color inside input
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mobile No.',
                          labelStyle: TextStyle(color: Color(0xff000000)),
                          // Black label text
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                Color(0xff000000)), // Black focused border
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xff000000), // Black text color inside input
                        ),
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Color(0xff000000)),
                          // Black label text
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                Color(0xff000000)), // Black focused border
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // GST No. field
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        controller: gstController,
                        inputFormatters: [UpperCaseTextFormatter()],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xff000000), // Black text color inside input
                        ),
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          labelText: 'GST NO',
                          labelStyle: TextStyle(color: Color(0xff000000)),
                          // Black label text
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffd3d3d3)), // Light grey border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                Color(0xff000000)), // Black focused border
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Done Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        backgroundColor: Color(0xFFD5282A),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 25),
                      ),
                      onPressed: () {
                        custmobile = mobileController.text;
                        custname = nameController.text;
                        custgst = gstController.text;

                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15, // Increased font size for button text
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFFD5282A), // Red color for Cancel button
                      fontSize: 16, // Font size for Cancel button
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingValue2 = (screenWidth <= 540 && screenHeight <= 290)
        ? 20
        : (screenWidth > 290 || screenHeight > 290 ? 290 : 20);
    double containerHeight = (screenWidth > screenHeight) ? 400 : 500;
// Determine height based on screen width and height comparison
    double boxHeight = (screenWidth > screenHeight) ? 158 : 258;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
///////////////////////////////wrokin//////////////////////
            Column(
              children: [
                // Red rectangle with back button and Bill Summary title
                Container(
                  width: double.infinity,
                  // Ensures the red rectangle takes up full screen width
                  height: 90.0,
                  // Height of the red rectangle
                  color: Color(0xFFD5282A),
                  // Red color
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Space between items
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // Center vertically
                    children: [
                      // Back button icon (white color)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // Go back to the previous page
                          Navigator.pop(context);
                        },
                      ),
                      // Bill Summary Title (centered vertically with some space adjustment)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        // Add top padding to move the text down
                        child: Text(
                          'Bill Summary',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: 25,
                            color: Colors.white, // White color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Empty container to maintain space balance (optional)
                      SizedBox(width: 48),
                      // This can be adjusted as per your design needs
                    ],
                  ),
                ),

                // Padding between the red rectangle and Table Name text
                const SizedBox(height: 10.0),

                // Table Name Text
                Text(
                  'Table No.${tableinfo['name'] ?? "Unknown"}',
                  // Safeguard in case of null
                  style: const TextStyle(
                    fontFamily: 'HammersmithOne',
                    fontSize: 22,
                    color: Colors.black54, // Red color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            ///////////////   above //////////////////////////

            Container(
              height: containerHeight,
              child: Card(
                elevation: 1.0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  side: BorderSide(
                    color: Colors.black,
                    // Change this color to whatever you want for the border
                    width: 0.1, // Adjust the width as needed
                  ),
                ),
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5282A), // Red color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        // Add some padding around the text
                        child: Row(
                          children: [
                            // Item Header - moved 2cm (roughly 20px) to the right
                            Padding(
                              padding: EdgeInsets.only(left: 40.0),
                              // 2cm roughly corresponds to 20px, adjust as needed
                              child: Text(
                                'Item',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // Smaller font size
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Space between "Item" and "Rate"

                            // Spacer to push "Rate" and "Qty" to the right
                            Spacer(),

                            // Rate Header - moved towards right
                            Text(
                              'Rate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Font size
                              ),
                            ),
                            SizedBox(width: 20),
                            // Space between "Rate" and "Qty"

                            // Qty Header - moved towards right
                            Text(
                              'Qty',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Font size
                              ),
                            ),
                            SizedBox(width: 30),
                            // Space between "Qty" and "Subtotal"

                            // Subtotal Header - stays on the left side
                            Transform.translate(
                              offset: Offset(-10, 0),
                              // Negative value to move it left by ~75.6 pixels (about 2 cm)
                              child: Text(
                                'Subtotal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: SizedBox(
                        height: boxHeight,
                        child:
                        Lastclickedmodule == 'Take Away' ||
                            Lastclickedmodule == 'Counter' ||
                            Lastclickedmodule == 'Home Delivery' ||
                            Lastclickedmodule == 'Online'
                            ? buildList(selectedProducts)
                            : _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : FutureBuilder<List<OrderItem>>(
                          future: futureKOTs,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  OrderItem item =
                                  snapshot.data![index];

                                  // Filter modifiers for the current product
                                  final itemModifiers = allbillmodifers
                                      .where((modifier) =>
                                  modifier.product_code ==
                                      item.itemCode
                                          .toString() &&
                                      modifier.order_id ==
                                          item.orderNumber)
                                      .toList();

                                  final totalPrice =
                                      item.quantity! *
                                          item.price!;

                                  // Check if it's the first item or if the orderID is different
                                  if (index == 0 ||
                                      item.orderNumber !=snapshot
                                          .data![index - 1]
                                          .orderNumber) {
                                    // Add a ListTile for the order number
                                    return Column(
                                      children: [
                                        ListTile(
                                          contentPadding:
                                          EdgeInsets.zero,
                                          // Remove default padding around the ListTile
                                          title: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(0),
                                            // Remove padding around the title
                                            child: Container(
                                              color:
                                              Colors.black54,
                                              // Background color of the container
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  vertical:
                                                  8.0),
                                              // Keep some vertical padding
                                              child: Align(
                                                alignment:
                                                Alignment
                                                    .topLeft,
                                                // Align text to the top-left of the container
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      top: 0),
                                                  // Add a little top padding to move text upwards
                                                  child: Text(
                                                    "Order Number: ${item.orderNumber}",
                                                    style:
                                                    const TextStyle(
                                                      fontFamily:
                                                      'HammersmithOne',
                                                      fontSize:
                                                      16,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .white, // Text color for visibility
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            ListTile(
                                              leading: SizedBox(
                                                width:
                                                30, // <-- Your width
                                                height: 40,
                                                child: InkWell(
                                                  onTap: () {
                                                    // Add your button click logic here
                                                    print('Button Clicked');
                                                    addRemoveItems="1";

                                                    setState(() {
                                                      item.isComp =
                                                      !item
                                                          .isComp;

                                                      if (item.isComp) {
                                                        // Set the price to 0.00 and store the current price in pricebckp
                                                        item.pricebckp =item.price!;
                                                        item.price =0.00;
                                                        subtotal=subtotal-double.parse(item.pricebckp.toString());
                                                      } else {
                                                        // Restore the original price from pricebckp
                                                        item.price =
                                                            item.pricebckp;
                                                        subtotal=subtotal+double.parse(item.price.toString());

                                                        //add here
                                                      }

                                                      updateState(
                                                          subtotal);
                                                    });
                                                  },
                                                  child:
                                                  Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      color: item
                                                          .isComp
                                                          ? Colors
                                                          .green
                                                          : Colors
                                                          .grey, // Change color based on isComp
                                                    ),
                                                    padding:
                                                    EdgeInsets
                                                        .zero,
                                                    // Setting padding to zero
                                                    child:
                                                    const Center(
                                                      child: Text(
                                                        'Com',
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          'HammersmithOne',
                                                          color: Colors
                                                              .white,
                                                          // White text color
                                                          fontSize:
                                                          10.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                item.itemName
                                                    .toString(),
                                                style:
                                                const TextStyle(
                                                  fontFamily:
                                                  'HammersmithOne',
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                ),
                                              ),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left:
                                                            130.0),
                                                        // Move 120px to the left
                                                        child:
                                                        Text(
                                                          "${item.price}",
                                                          style:
                                                          const TextStyle(
                                                            fontSize:
                                                            14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        "${item.quantity}",
                                                        style:
                                                        const TextStyle(
                                                          fontSize:
                                                          14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    totalPrice
                                                        .toStringAsFixed(
                                                        2),
                                                    style:
                                                    const TextStyle(
                                                      fontSize:
                                                      16,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: ListView
                                                  .builder(
                                                shrinkWrap: true,
                                                physics:
                                                NeverScrollableScrollPhysics(),
                                                // Prevent nested scrolling
                                                itemCount:
                                                itemModifiers
                                                    .length,
                                                itemBuilder:
                                                    (context,
                                                    modIndex) {
                                                  final modifier =
                                                  itemModifiers[
                                                  modIndex];
                                                  return Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .fromLTRB(
                                                        60,
                                                        0,
                                                        28,
                                                        0),
                                                    // Adjust horizontal padding as needed
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      // Aligns the column content to the start (left)
                                                      children: [
                                                        // Modifier Name - Aligned to the left
                                                        Text(
                                                          modifier
                                                              .name,
                                                          style:
                                                          const TextStyle(
                                                            color:
                                                            Colors.blueAccent,
                                                            fontSize:
                                                            16,
                                                            // Adjust font size as needed
                                                            fontWeight:
                                                            FontWeight.normal,
                                                          ),
                                                        ),

                                                        // Row for Rate, Quantity, and Subtotal - Aligned to the right
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          // Align the entire row to the right
                                                          children: [
                                                            // Rate - Move slightly to the left
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(right: 40.0),
                                                              // Reduce right padding for Rate
                                                              child:
                                                              Text(
                                                                "${modifier.price_per_unit}",
                                                                style: const TextStyle(
                                                                  color: Colors.blueAccent,
                                                                  fontSize: 14,
                                                                ),
                                                                textAlign: TextAlign.end, // Align Rate to the right
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(right: 28.0),
                                                              child:
                                                              Text(
                                                                "${modifier.quantity}",
                                                                style: const TextStyle(
                                                                  color: Colors.blueAccent,
                                                                  fontSize: 14,
                                                                ),
                                                                textAlign: TextAlign.end, // Align Quantity to the right
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(right: 12.0),
                                                              child:
                                                              Text(
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
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  } else {
                                    // Add a regular ListTile
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: SizedBox(
                                            width:
                                            30, // <-- Your width
                                            height: 40,
                                            child: InkWell(
                                              onTap: () {
                                                // Add your button click logic here
                                                print('Button Clicked');

                                                setState(() {
                                                  item.isComp = !item
                                                      .isComp; // Toggle the 'isComp' state

                                                  if (item
                                                      .isComp) {
                                                    // Set the price to 0.00 and store the current price in pricebckp
                                                    item.pricebckp =item.price!;
                                                    item.price = 0.00;
                                                    subtotal=subtotal-double.parse(item.pricebckp.toString());

                                                    //here do minus
                                                  } else {
                                                    // Restore the original price from pricebckp
                                                    item.price = item.pricebckp;
                                                    subtotal=subtotal+double.parse(item.price.toString());

                                                  }
                                                  //ADDED BY SANTOSH
                                                  addRemoveItems="1";
                                                  //ENDED
                                                  updateState(
                                                      subtotal); // Make sure to update the subtotal or other relevant states
                                                });
                                              }, //2nd com//
                                              child: Container(
                                                decoration:
                                                BoxDecoration(
                                                  color: item.isComp
                                                      ? Colors
                                                      .green
                                                      : Colors
                                                      .grey,
                                                  // Change color to green when 'isComp' is true, else grey
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      0), // Optional: adds rounded corners
                                                ),
                                                padding:
                                                EdgeInsets
                                                    .zero,
                                                // Setting padding to zero
                                                child:
                                                const Center(
                                                  child: Text(
                                                    'Com',
                                                    style:
                                                    TextStyle(
                                                      fontFamily:
                                                      'HammersmithOne',
                                                      color: Colors
                                                          .white,
                                                      fontSize:
                                                      10.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            item.itemName
                                                .toString(),
                                            style:
                                            const TextStyle(
                                              fontFamily:
                                              'HammersmithOne',
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  // Padding applied to move the "Rate" to the right
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left:
                                                        130.0),
                                                    // Move it 50px to the right
                                                    child: Text(
                                                      "${item.price}",
                                                      style:
                                                      const TextStyle(
                                                        fontSize:
                                                        14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    "${item.quantity}",
                                                    style:
                                                    const TextStyle(
                                                      fontSize:
                                                      14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                totalPrice
                                                    .toStringAsFixed(
                                                    2),
                                                style:
                                                const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                          NeverScrollableScrollPhysics(),
                                          // Prevent nested scrolling
                                          itemCount: itemModifiers
                                              .length,
                                          itemBuilder: (context,
                                              modIndex) {
                                            final modifier =
                                            itemModifiers[
                                            modIndex];
                                            return Padding(
                                                padding:
                                                const EdgeInsets
                                                    .fromLTRB(
                                                    16,
                                                    0,
                                                    8,
                                                    0),
                                                // Adjust vertical padding
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  // Aligns the column to the start
                                                  children: [
                                                    Text(
                                                      modifier
                                                          .name,
                                                      style:
                                                      const TextStyle(
                                                        color: Colors
                                                            .blueAccent,
                                                        fontSize:
                                                        16,
                                                        // Adjust font size as needed
                                                        fontWeight:
                                                        FontWeight
                                                            .normal, // Make the name stand out
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: 120.0),
                                                            // Move 120px to the left
                                                            child:
                                                            Align(
                                                              alignment:
                                                              Alignment.centerLeft,
                                                              // Aligns text to the left
                                                              child:
                                                              Text(
                                                                "${modifier.price_per_unit}",
                                                                style: const TextStyle(
                                                                  color: Colors.blueAccent,
                                                                  fontSize: 14,
                                                                ),
                                                                textAlign: TextAlign.start, // Aligns text to the start of the column
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                          Text(
                                                            "${modifier.quantity}",
                                                            style:
                                                            const TextStyle(
                                                              color:
                                                              Colors.blueAccent,
                                                              fontSize:
                                                              14,
                                                            ),
                                                            textAlign:
                                                            TextAlign.end, // Centers text in the column
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                          Align(
                                                            alignment:
                                                            Alignment.centerRight,
                                                            // Aligns text to the right
                                                            child:
                                                            Text(
                                                              (modifier.price_per_unit * modifier.quantity).toStringAsFixed(2),
                                                              style:
                                                              const TextStyle(
                                                                color: Colors.blueAccent,
                                                                fontSize: 14,
                                                              ),
                                                              textAlign:
                                                              TextAlign.end, // Aligns text to the end of the column
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ));
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            } else {
                              return const CircularProgressIndicator(); // Placeholder for when data is still loading
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 2, thickness: 2),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtotal != 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Sub Total:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "$subtotal",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          if (discount != 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Discount:(${discountpercentage.toInt()}%)",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  discount.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (discount != 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200, // Set the desired width
                                  child: Text(
                                    "Remark: $discountremark",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines:
                                    2, // Set the maximum number of lines
                                    overflow: TextOverflow
                                        .ellipsis, // Set overflow behavior (ellipsis, fade, clip, visible)
                                  ),
                                ),
                                const Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (discount != 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Bill Amount:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "$billamount",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: rows),
                          const Divider(height: 2, thickness: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  color: Color(0xFFD5282A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${grandtotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFFD5282A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add your circular button here
                // Customer Details Button

// Generate Bill Button
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (Lastclickedmodule == "Take Away" ||
                          Lastclickedmodule == "Counter" ||
                          Lastclickedmodule == "Home Delivery" ||
                          Lastclickedmodule == "Online") {
                        _showSettleBillDrawer(
                            selectedProducts, selectedModifiers, tableinfo);
                      } else {
                        postBillData(context, allbillitems, allbillmodifers,
                            allbilltaxes, tableinfo);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            5)), // Rounded corners with radius 5
                      ),
                      backgroundColor: Color(0xFFD5282A),
                      // Red background color (hex code)
                      padding: const EdgeInsets.symmetric(
                          horizontal: 101.0,
                          vertical: 10.0), // Increased vertical padding
                    ),
                    child: const Text(
                      'Generate Bill',
                      style: TextStyle(
                        fontFamily: 'HammersmithOne', // Custom font
                        fontSize: 21,
                        color: Colors.white, // Pure white text color
                      ),
                    ),
                  ),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showCustomerDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        // Rounded corners with radius 5
                        side: BorderSide(
                            color: Color(0xFFD5282A),
                            width: 0.5), // Red border with width 0.5
                      ),
                      backgroundColor: Colors.white, // White background
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0), // Reduced horizontal padding
                    ),
                    child: const Icon(
                      Icons.account_circle, // Icon for the button
                      size: 25.0, // Icon size
                      color: Color(0xFFD5282A), // Red icon color
                    ),
                  ),
                ),

                // Discount Button
                ElevatedButton(
                  onPressed: () {
                    // Add your discount logic here
                    showDiscountDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      // Rounded corners
                      side: BorderSide(
                          color: Color(0xFFD5282A), width: 0.5), // Red border
                    ),
                    backgroundColor: Colors.white, // White background
                    padding: const EdgeInsets.fromLTRB(
                        16.0, 0, 16, 0), // Padding for button text
                  ),
                  child: const Text(
                    "Discount",
                    style: TextStyle(
                      color: Color(0xFFD5282A), // Red text color
                      fontSize: 14,
                    ),
                  ),
                ),

                // DC Button (only shown when Lastclickedmodule is not "Take Away")
                if (Lastclickedmodule != "Take Away" &&
                    Lastclickedmodule != "Dine" &&
                    Lastclickedmodule != "Counter")
                  ElevatedButton(
                    onPressed: () {
                      // Add your discount logic here
                      showDiscountDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        // Rounded corners
                        side: BorderSide(
                            color: Color(0xFFD5282A), width: 0.5), // Red border
                      ),
                      backgroundColor: Colors.white, // White background
                      padding:
                      const EdgeInsets.all(1.0), // Padding for button text
                    ),
                    child: const Text(
                      "Del Charge",
                      style: TextStyle(
                        color: Color(0xFFD5282A), // Red text color
                        fontSize: 14,
                      ),
                    ),
                  ),

                // NSC Button (only shown when Lastclickedmodule is not "Take Away")
                if (Lastclickedmodule != "Take Away" &&
                    Lastclickedmodule != "Counter" &&
                    Lastclickedmodule != "Home Delivery" &&
                    Lastclickedmodule != "Online")
                  ElevatedButton(
                    onPressed: () {
                      showNSCDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        // Rounded corners
                        side: BorderSide(
                            color: Color(0xFFD5282A), width: 0.5), // Red border
                      ),
                      backgroundColor: Colors.white, // White background
                      padding:
                      const EdgeInsets.all(1.0), // Padding for button text
                    ),
                    child: const Text(
                      "NSC",
                      style: TextStyle(
                        color: Color(0xFFD5282A), // Red text color
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  final String apiUrlpost = '${apiUrl}bill/create?DB=' + CLIENTCODE;

  late String gBILLNO;
  bool isBillPosted = false;

  Future<void> postBillData(
      BuildContext context,
      List<BillItem> bills,
      List<SelectedProductModifier> modifiers,
      List<LocalTax> taxes,
      Map<String, String> tableinfo) async {
    if (isBillPosted) {
      print("Bill already posted. Skipping duplicate entry.");
      return; // Prevent duplicate API calls
    }
    isBillPosted = true;
    final billItems = bills.map((product) => product.toJson()).toList();
    final billModifiers = modifiers.map((product) => product.toJson()).toList();

    DateFormat dateFormat = DateFormat("dd-MM-yyyy");

    //Converting DateTime object to String
    // String dateandtime = dateFormat.format(DateTime.now()); //saytem date
    String dateandtimepos =
    dateFormat.format(DateTime.parse(posdate.toString())); //pos date
    String dateandtime = dateandtimepos; //pos date
    String billtime =
    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now().toUtc());

    String tableno = tableinfo['name'].toString();
    String statuss = "N";
    String tempmos = "";

    if (tableno == '0') {
      statuss = "Y";
      tempmos =
          lastMOS; // In case it's a Take Away or other module, use the lastMOS
    }

    double mysubtotal = 0.0;
    if (Lastclickedmodule == "Take Away" ||
        Lastclickedmodule == "Counter" ||
        Lastclickedmodule == "Home Delivery") {
      for (BillItem item in bills) {
        mysubtotal += item.price * item.quantity;
      }
      for (var modifier in modifiers) {
        mysubtotal += modifier.price_per_unit * modifier.quantity;
      }
      // Update state with the subtotal calculated for Take Away
      updateState(mysubtotal);
    } else if (Lastclickedmodule == "Dine") {
      // Calculate subtotal for Dine-in using allbillitems and allbillmodifiers
      for (BillItem item in allbillitems) {
        mysubtotal += item.price * item.quantity;
      }
      for (var modifier in modifiers) {
        mysubtotal += modifier.price_per_unit * modifier.quantity;
      }

      updateState(mysubtotal);
    }
    if (Lastclickedmodule == "Take Away" ||
        Lastclickedmodule == "Home Delivery" ||
        Lastclickedmodule == "Counter" ||
        Lastclickedmodule == "Online") {
      statuss = "Y";
    }

    String? tableNumber = (Lastclickedmodule == "Take Away" ||
        Lastclickedmodule == "Home Delivery" ||
        Lastclickedmodule == "Counter" ||
        Lastclickedmodule == "Online")
        ? '0'
        : tableinfo['name'];
    String settlementModeName = (Lastclickedmodule == "Dine") ? "" : lastMOS;

    final response = await http.post(
      Uri.parse(apiUrlpost),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "billItems": billItems,
        "billModifiers": billModifiers,
        "billTaxes": taxes,
        "customerName": custname,
        "customerMobile": custmobile,
        "customerGst": custgst,
        "waiter": selectedwaitername,
        "user": username,
        "tableNumber": tableNumber,
        "billDate": dateandtime,
        "totalAmount": subtotal,
        "isSettle": statuss,
        "settlement_mode_name": settlementModeName, // Will be empty for Dine
        "home_deliverycharge": '0.0',
        "order_type": Lastclickedmodule,
        "bill_tax": sumoftax,
        "bill_discount": discount,
        "bill_discount_percent": discountpercentage,
        "bill_discount_remark": discountremark,
        "billTime": billtime,
        "pax": selectedPax,
        "GrandTotal": grandtotal,
      }),
    );

    if (response.statusCode == 201) {
      // If the server returns a 200 OK response, you can handle the success here.
      print("Data Posted Successfully");

      final String url2 =
          '${apiUrl}table/update/${tableinfo['id']!}' + '?DB=' + CLIENTCODE;

      final Map<String, dynamic> data2 = {
        "tableName": tableinfo['name'],
        "status": "Billed",
        "id": tableinfo['id'],
        "area": tableinfo['area'],
        "pax": tableinfo['pax'] ?? 1,
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
      String billId = parsedData['billNo'].toString();
      gBILLNO = billId; // You can use this Bill ID further if needed

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 2), () {
            // Navigator.of(context).popUntil(ModalRoute.withName('/mainmenu'));// Close the dialog after 3 seconds

            testBILL(
                gBILLNO,
                bills,
                modifiers,
                tableinfo['name']!,
                grandtotal.toDouble(),
                cgstpercentage,
                sgstpercentage,
                cgst,
                sgst,
                vatpercentage,
                vat,
                scpercentage,
                sc,
                discountpercentage,
                discount,
                discountremark,
                1);

            NativeBridge.callNativeMethodBill(
                gBILLNO,
                jsonEncode(billItems).toString(),
                "₹",
                'Kitchen',
                Lastclickedmodule,
                custmobile,
                custname,
                custgst,
                tableinfo['name']!,
                cgst.toString(),
                cgstpercentage.toString(),
                sgst.toString(),
                sgstpercentage.toString());

            Navigator.of(context).pop();

            Map<String, String> billinfo = {
              'name': "pratk",
              'Total': "$grandtotal",
              'BillNo': "$gBILLNO",
              'tableName': tableinfo['name']!,
              'waiter': selectedwaitername,
              'pax': selectedPax.toString(),
              'discount': "$discount",
              'discountper': "$discountpercentage",
              'discountremark': "$discountremark",
              'custname': "$custname",
              'custmobile': "$custmobile",
              'custgst': "$custgst",
              'user': "$username",
              'settlementModeName': "$settlementModeName",
              'DNT': posdate.toString(),
            };

            Map<String, dynamic> routeArguments = {
              'billItems': bills,
              'billModifiers': modifiers,
              'billinfo': billinfo,
            };

            Navigator.pushNamed(context, '/reciptview',
                arguments: routeArguments);
          });

          final backgroundColor = Colors.white.withOpacity(0.7);
//bill//
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
                const SizedBox(
                    height: 16.0), // Add some spacing between icon and text
                Text(
                  'Bill No.$billId\nGenerated Successfully',
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
                  size: 48.0,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Failed to Generate Bill',
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

      throw Exception('Failed to Generate Bill');
    }
  }

  ///////////kot////////////////

  final String apirl = '${apiUrl}order/create?DB=$CLIENTCODE';

  late String gKOTNO;

  Future<void> postData(BuildContext context, List<SelectedProduct> sps,
      List<SelectedProductModifier> sml, Map<String, String> tableinfo) async {
    for (SelectedProduct item in sps) {
      double tempitemtotal = item.quantity! * item.price!.toDouble();
      BillItem billItem = BillItem(
          productCode: item.code.toString(),
          quantity: item.quantity ?? 0,
          price: item.price ?? 0,
          itemName: item.name.toString(),
          totalPrice: tempitemtotal,
          notes: item.notes);

      // Add the BillItem object to the list
      allbillitemslocal.add(billItem);
    }

    final orderItems = sps.map((product) => product.toJson()).toList();
    final orderModifiers = sml.map((product) => product.toJson()).toList();
    String tableNumber = tableinfo['name'] ?? '0';
    final response = await http.post(
      Uri.parse(apirl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "orderItems": orderItems,
        "orderModifiers": orderModifiers,
        "order_type": Lastclickedmodule,
        "tableNumber": tableNumber,
      }),
    );

    print("harshbhai${jsonEncode({
      "orderItems": orderItems,
    })}");

    if (response.statusCode == 201) {
      // If the server returns a 200 OK response, you can handle the success here.
      print("Data Posted Successfully");

      final String url2 =
          '${apiUrl}table/update/${tableinfo['id']!}' + '?DB=' + CLIENTCODE;

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
        testKOT(kotId, tempselectedProducts, sml, tableinfo['name']!);
      });
      ////////////////////////////

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
            //   Navigator.of(context).pop();
/*            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenu(),
              ),
            );*/
            postBillData(
                context, allbillitemslocal, sml, allbilltaxes, tableinfo);

            /*    Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainMenu(),
                ),
              );*/
          });
          // Define a semi-transparent color for the background
          //kot print//
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
                const SizedBox(
                    height: 16.0), // Add some spacing between icon and text
                Text(
                  'No.$kotId\nOrder Placed Successfully',
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
                const SizedBox(
                    height: 16.0), // Add some spacing between icon and text
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

  ///////////kot////////////////
  whatsapp() async {
    var contact = "+919920593888";
    var androidUrl = "whatsapp://send?phone=$contact&text=Hi, I need some help";
    var iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";
    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      //  EasyLoading.showError('WhatsApp is not installed.');
    }
  }

  void _showSettleBillDrawer(
      List<SelectedProduct> selectedProductss,
      List<SelectedProductModifier> selectedModifiers,
      Map<String, String> tableinfoo) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            // Wrap Column with SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  // Adjust top padding to reduce space
                  child: const Text(
                    'Settlement',
                    style: TextStyle(
                      color: Color(0xFFD5282A),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8.0),
                // Adjust this to move grid up or down

                // Use a GridView without specifying the fixed height
                GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  // Ensure the GridView only takes as much space as needed
                  childAspectRatio: screenWidth > screenHeight ? 1.4 : 1.0,
                  // Aspect ratio adjustment based on orientation
                  children: [
                    GridItem(
                      title: 'Cash',
                      onTap: () {
                        lastMOS = 'Cash';
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                      },
                      imageUrl: 'assets/images/cash.png',
                    ),
                    GridItem(
                      title: 'Card',
                      onTap: () {
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                        lastMOS = 'Card';
                        _username = "9920593222";
                        _password = "3241";

                        currentTask = "SALE";
                        _task = "getAmount";

                        // Step 5: Perform the transaction and print receipt on success
                        FlutterMosambeeAar.onResult.listen((resultData) async {
                          if (resultData.result == true) {
                            final body =
                            json.decode(resultData.transactionData ?? "{}");

                            // Check if the transaction succeeded
                            if (body["result"] == "Success" &&
                                body["transactionId"] != "NA") {
                              printReceipt(resultData.transactionData ??
                                  ""); // Print receipt
                              ToastUtils.showSuccessToast(
                                  "Transaction successful and receipt printed.");
                            } else {
                              ToastUtils.showErrorToast("Transaction failed.");
                            }
                          } else {
                            ToastUtils.showErrorToast(
                                "Transaction error: ${resultData.reason}");
                          }
                        });

                        // Step 6: Trigger the transaction process
                        performActions("getAmount");
                      },
                      imageUrl: 'assets/images/card.png',
                    ),
                    GridItem(
                      title: 'UPI',
                      onTap: () {
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                        lastMOS = 'UPI Online';
                        _username = "9920593222";
                        _password = "3241";
                        currentTask = "UPI QR";
                        currentTask == "PRINT RECEIPT";
                        _task = "getAmount";
                        performActions("getAmount");
                      },
                      imageUrl: 'assets/images/upi.png',
                    ),
                    GridItem(
                      title: 'Part settlement',
                      onTap: () {
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                        lastMOS = 'Part Settlement';
                      },
                      imageUrl: 'assets/images/multi settlement.png',
                    ),
                    GridItem(
                      title: 'Zomato',
                      onTap: () {
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                        lastMOS = 'Zomato';
                      },
                      imageUrl: 'assets/images/ZOMATO.png',
                    ),
                    GridItem(
                      title: 'Swiggy',
                      onTap: () {
                        postData(context, selectedProductss, selectedModifiers,
                            tableinfoo);
                        lastMOS = 'Swiggy';
                      },
                      imageUrl: 'assets/images/SWIGGY.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BillModifier {
  Map<String, dynamic> toJson() {
    return {};
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class SettleBillDrawer extends StatelessWidget {
  const SettleBillDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      color: Colors.white,
      child: SingleChildScrollView(
        // Wrap the Column with SingleChildScrollView for scrolling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding:
              const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              // Adjust top padding to reduce space
              child: const Text(
                'Settlement',
                style: TextStyle(
                  color: Color(0xFFD5282A),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8.0), // Adjust this to move grid up or down
            GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              childAspectRatio: 1.4,
              // Add this line to make the grid occupy only the needed space
              children: [
                GridItem(
                  title: 'Cash',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/cash.png',
                ),
                GridItem(
                  title: 'Multi settlement',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/2.png',
                ),
                GridItem(
                  title: 'National/UPI',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/upi.png',
                ),
                GridItem(
                  title: 'Card',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/card1.png',
                ),
                GridItem(
                  title: 'Zomato',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/ZOMATO.png',
                ),
                GridItem(
                  title: 'Swiggy',
                  onTap: () {
                    // Your implementation here
                    print('Item tapped!');
                  },
                  imageUrl: 'assets/images/SWIGGY.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final String imageUrl; // New parameter for the image URL or asset
  final VoidCallback onTap;

  const GridItem({
    super.key,
    required this.title,
    required this.imageUrl, // Initialize imageUrl
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Color(0xFFF6F6F6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image
            Image.asset(
              imageUrl,
              width: 65.0, // Adjust the size of the image
              height: 65.0,
            ),
            const SizedBox(height: 8.0),
            // Display the icon

            const SizedBox(height: 8.0),
            // Display the title
            Text(
              title,
              style: const TextStyle(
                color: Colors.black, // Black color for the text
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
