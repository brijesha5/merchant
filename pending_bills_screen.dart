import 'dart:async';
import 'dart:convert';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'BillDetails.dart'  as billdetail;
import 'Bill_model.dart';
import 'FireConstants.dart';
import 'OrderModifier.dart';
import 'Order_Item_model.dart';
import 'ReceiptView.dart';
import 'home/home_page.dart';
import 'list_of_product_screen.dart';
import 'main_menu.dart';
import 'main_menu_desk.dart';
import 'dart:core';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:flutter_scanner_aar/flutter_scanner_aar.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/emi_data_list.dart';
import '../../models/online_history_list.dart';
import '../dialogs/qr_dialog.dart';
import '../logger.dart';
import '../utils/toast_utils.dart';
void main() {
  runApp(const PendingBillsScreen());
}

class PendingBillsScreen extends StatelessWidget {
  const PendingBillsScreen({super.key});





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
          backgroundColor: Colors.white,
          appBar: null,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0.0),
                    color: Color(0xFFD5282A),
                    width: double.infinity,
                    height: 80.0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            iconSize: 28.0,
                            onPressed: () async {
                              if( screenWidthmy > screenHeightmy )
                              {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainMenuDesk(),

                                  ),
                                );

                              }
                              else{
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainMenu(),

                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 50.0,top: 15),
                                  child: Text(
                                    'Pending Bills',
                                    style: TextStyle(
                                      fontFamily: 'HammersmithOne',
                                      fontSize: screenWidthmy > screenHeightmy
                                          ? 50
                                          : (screenWidthmy > 600 ? 50 : 22),
                                      color: Colors.white, // White text
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: BillList()),
                ],
              ),
            ],
          ),
        ),
      ),
    );




  }
}

class BillList extends StatefulWidget {
  const BillList({super.key});

  @override
  _BillListState createState() => _BillListState();
}
class _BillListState extends State<BillList> {
  List<BillItem> allbillitems = [];
  List<SelectedProductModifier> allbillmodifers = [];
  List<LocalTax> allbilltaxes = [];

  String? selectedBillId;
  bool _isLoading = true;
  String custname = '', custmobile = '', custgst = '';
  double subtotal = 0.00;
  double grandtotal = 0.00;
  double billamount = 0.00;
  double discount = 0.00;
  double discountpercentage = 0.00;
  String discountremark = "";
  double sumoftax = 0.0;
  String currentTask = "",
      _transactionId = "",
      _message = "",
      _transactionAmount = "",
      _transactionReasonCode = "",
      _transactionReason = "",
      _task = "",
      _iin = "";
  Timer? _transactionCheckTimer;
  dynamic _transactionData;

  late String _username = "9920593222";
  late String _password = "3241";
  late String   _amount = "10";
  String billNoValue="";
  @override
  void initState() {
    super.initState();
    requestPermission();
    _listenTransactionData("");
    _listenPrinter();
  }

  @override
  Widget build1(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: allbillitems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(allbillitems[index].itemName),
          subtitle: Text('Quantity: ${allbillitems[index].quantity}, Price: ${allbillitems[index].price}'),
          trailing: Text('Total: ${allbillitems[index].totalPrice}'),
        );
      },
    );
  }

  Future<List<Bill>> fetchPendingBill() async {
    try {
      final response = await http.get(Uri.parse('${apiUrl}bill/pending?DB=$CLIENTCODE'));

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
        final bills = parsed.map<Bill>((json) => Bill.fromMap(json)).toList();
        print('Fetched pending bills: ${bills.length}');
        return bills.reversed.toList();
      } else {
        print('Failed to load Pending Bills: ${response.statusCode}');
        throw Exception('Failed to load Pending Bills');
      }
    } catch (e) {
      print('Error fetching pending bills: $e');
      throw Exception('Error fetching pending bills');
    }
  }


  Future<String> cancelBill(String billNo) async {
    final url = Uri.parse('${apiUrl}order/cancelbill?billNo=$billNo&DB=$CLIENTCODE');

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('SUCCESS: Bill $billNo successfully cancelled');
        return response.body;
      } else {
        print('FAILED: Failed to cancel Bill $billNo');
        print('Response Body: ${response.body}');
        return 'Failed to cancel Bill: ${response.body}';
      }
    } catch (e) {
      print('ERROR: Error occurred while canceling Bill $billNo: $e');
      return 'Error occurred while canceling Bill: $e';
    }
  }



  Future<void> updateBillWithDiscount(String billNo, double discountPercent) async {

    final url = Uri.parse('${apiUrl}order/updatediscount?billNo=$billNo&discountPercent=$discountPercent&DB=$CLIENTCODE');

    try {

      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Bill $billNo successfully updated with $discountPercent% discount');
      } else {

        print('Failed to update Bill $billNo: ${response.body}');
        throw Exception('Failed to update Bill');
      }
    } catch (e) {

      print('Error occurred while updating Bill $billNo: $e');
      throw Exception('Error occurred while updating Bill');
    }
  }

  Future<void> updateBillWithTax(String billNo) async {
    try {
      final url = Uri.parse('${apiUrl}order/updatetax?billNo=$billNo&DB=$CLIENTCODE');
      final response = await http.put(url);

      if (response.statusCode == 200) {
        String responseMessage = response.body.trim();
        final updatedBillData = await fetchBillDetails(billNo);
        bool isNSCEnabled = updatedBillData.billTax != "0.00";
        GLOBALNSC = isNSCEnabled ? "Y" : "N";
        await executeReprintLogic(updatedBillData);
        await showSuccessDialog(
          context,
          "NSC ${isNSCEnabled ? "Applied" : "Removed"} Successfully!",
        );
      } else {
        print('Failed to update Bill $billNo: ${response.body}');
        throw Exception('Failed to update Bill');
      }
    } catch (e) {
      print('Error updating Bill $billNo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update NSC status')),
      );
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



  void _showSettleBillDrawer(BuildContext context, String billno, double amount) {

    billNoValue=billno;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SettleBillDrawer(
          billId: billno,
          amount: amount,
          performTransaction: (String task, double amount) async {
            Logger.d("DEBUG: Task: $task for Bill ID: $billno, Amount: $amount");
            setState(() {
              currentTask = task;
              _amount = amount.toString();
            });
            if (task == 'Cash') {

              _showCashSettlementDialog(context, billno, amount);
            }
            else if (task == ' UPI QR') {
              Logger.d("DEBUG: Storing Bill ID for UPI: $billno");
              FlutterMosambeeAar.generateUPIQR(amount, " UPI QR");
              Future.delayed(Duration(seconds: 2), () {
                Logger.d("DEBUG: Initializing Scanner for UPI QR");
                FlutterScannerAar.initialise();
                FlutterScannerAar.setWorkMode(0);
                FlutterScannerAar.startScan();
              });
              Future.delayed(Duration(seconds: 2), () {
                Logger.d("DEBUG: Calling _listenTransactionData() with Bill ID: $billno");
                _listenTransactionData(billno);
              });
            }
            else if (task == 'Card') {
              performTransaction('SALE', amount, false);
            }
            else if (task == 'Cash') {
              await _updateSettlementMode(billno, task);
            } else {
              final String settlementMode = task;
              performTransaction(settlementMode, amount, false);
            }
          },
        );
      },
    );
  }

  Future<void> _updateSettlementMode(String billId, String settlementMode) async {
    String settlementTime = DateTime.now().toIso8601String();
    print("SETTLE BY "+settlementMode);
    print("SETTLE BY "+billId);
    final String url2 = '${apiUrl}bill/updatesettle/$billId?settlementModeName=$settlementMode&DB=$CLIENTCODE';

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url2),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Settlement updated ');

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop();
              if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuDesk()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenu()),
                );
              }
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
                    'Transaction ID $billId\nSettled Successfully ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print('GET request failed with status: ${response.statusCode}');
        print('Response data: ${response.body}');
      }
    } catch (e) {
      print('Error sending GET request: $e');
    }
  }

  void _showCashSettlementDialog(BuildContext context, String billId, double billAmount) {
    TextEditingController givenAmountController = TextEditingController();
    TextEditingController refundAmountController = TextEditingController();

    givenAmountController.addListener(() {
      double givenAmount = double.tryParse(givenAmountController.text) ?? 0.0;
      double refundAmount = givenAmount - billAmount;
      refundAmountController.text = refundAmount > 0 ? refundAmount.toStringAsFixed(2) : '0.00';
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cash Payment',
            style: TextStyle(color: Color(0xFFD5282A), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bill Amount: ₹${billAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: givenAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Given Amount', border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),
              TextField(
                controller: refundAmountController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Refund Amount', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double givenAmount = double.tryParse(givenAmountController.text) ?? 0.0;
                if (givenAmount < billAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Given amount must be greater than or equal to bill amount!')),
                  );
                } else {
                  Navigator.pop(context);
                  _updateSettlementMode(billId, "Cash");
                }
              },
              child: Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  void _showCardTipDialog(BuildContext context, String billId, double billAmount) {
    TextEditingController tipAmountController = TextEditingController();
    TextEditingController finalAmountController = TextEditingController(text: billAmount.toStringAsFixed(2));

    tipAmountController.addListener(() {
      double tipAmount = double.tryParse(tipAmountController.text) ?? 0.0;
      double finalAmount = billAmount + tipAmount;
      finalAmountController.text = finalAmount.toStringAsFixed(2);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Card Payment with Tip',
            style: TextStyle(color: Color(0xFFD5282A), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bill Amount: ₹${billAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // Input for Tip Amount
              TextField(
                controller: tipAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Tip Amount', border: OutlineInputBorder()),
              ),

              SizedBox(height: 10),

              // Auto-calculated Final Amount (Bill + Tip)
              TextField(
                controller: finalAmountController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Final Amount (Bill + Tip)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double tipAmount = double.tryParse(tipAmountController.text) ?? 0.0;
                double finalAmount = billAmount + tipAmount;

                Navigator.pop(context);
                _updateSettlementMode(billId, "Card");
              },
              child: Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.phone
    ].request();
  }
  Future<void> _listenTransactionData(String billno) async {
    FlutterMosambeeAar.onResult.listen((resultData) async {
      if (resultData.result != null && resultData.result == true) {
        final body = json.decode(resultData.transactionData ?? "{}");

        _transactionId = resultData.transactionId ?? "";
        Logger.d("DEBUG: Stored Transaction ID: $_transactionId");

        if (!QRDialog.isDialogOpen()) {
          QRDialog.showQRDialog(context, currentTask, body["message"], "AMOUNT : ${resultData.amount ?? body["amount"]}");
        }

        Logger.d("DEBUG: Successfully stored Transaction ID: $_transactionId");


        if(currentTask == "UPI QR") {
          if (billno != null && billno.isNotEmpty) {
            Logger.d("DEBUG: Updating settlement for Bill ID: $billno");
            _updateSettlementMode(billNoValue, " UPI QR");
          } else {
            Logger.d("ERROR: Missing Bill ID for settlement update!");
          }
        }else{
          _transactionId = body["transactionId"] ?? "";
          _transactionAmount = body["amount"] ?? "";
          _transactionData = body;

          handleSuccessResponse(resultData.transactionData ?? "", currentTask);
          _updateSettlementMode(billNoValue, "Card");

        }
        // checkBharatQRStatusRepeatedly(context, billNoValue);  // Still needed for confirmation checks
      } else {
        ToastUtils.showErrorToast(resultData.reason ?? "");
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
  }



////
  void checkBharatQRStatusRepeatedly(BuildContext context, String billId) {
    if (billId.isEmpty) {
      Logger.d("ERROR: Bill ID is missing! Retrying...");
      Future.delayed(Duration(seconds: 2), () {
        if (selectedBillId != null && selectedBillId!.isNotEmpty) {
          checkBharatQRStatusRepeatedly(context, selectedBillId!);
        } else {
          Logger.d("ERROR: Bill ID is STILL missing after retry!");
          return;
        }
      });
    }

    int maxAttempts = 12;
    int attempts = 0;
    bool isSuccess=false;
    _transactionCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      attempts++;

      Logger.d("Checking Bharat QR Status for ID: $_transactionId");
      if(isSuccess!=true){
        FlutterMosambeeAar.checkBharatQRStatus(1.00, "2025-01-24", "test", _transactionId);
      }

      FlutterMosambeeAar.onResult.listen((resultData) async {
        if (resultData.result == true) {
          _transactionCheckTimer?.cancel();

          printReceiptWithTransactionId(_transactionId);
          Future.delayed(Duration(seconds: 3), () {
            QRDialog.closeDialog();
            isSuccess=true;
            _updateSettlementMode(billId, "UPI QR"); // Removed extra space
          });
        } else if (attempts >= maxAttempts) {
          _transactionCheckTimer?.cancel();
          QRDialog.closeDialog();
        }else{

          //_transactionCheckTimer?.cancel();
          // QRDialog.closeDialog();
        }
      });
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
    Logger.d("Current Task :$currentTask");
    Logger.d("Transaction Data: $transactionData");

    if (currentTask.isEmpty) {
      return;
    }

    switch (currentTask) {
      case "SCAN":
        performActions("SCAN");
        return;

      case "SALE":
      case "Card":
      case "PREAUTH":
      case "CASH":
      case "CHEQUE":
      case "PWCB":
      case "CASH WITHDRAWAL":
      case "BALANCE ENQUIRY":
        _task = "Transaction Success\n$_transactionId\n$_transactionAmount";
        showResponseDialog(_task);
        closeWindowAndPrintReceipt(transactionData);
        return;

      case "SALE+TIP":
        String tip = _transactionData["tipAmount"];
        _task = "Transaction Success\n$_transactionId\nAmount - $_transactionAmount\nTipAmount - $tip";
        showResponseDialog(_task);
        printReceipt(transactionData);
        closeWindowAndPrintReceipt(transactionData);
        return;
      case "UPI QR":
        FlutterMosambeeAar.getNonCardTransactionHistory("10");
        return;
      case "PRINT RECEIPT":
        FlutterMosambeeAar.initialise(_username, _password);
        FlutterMosambeeAar.setInternalUi(false);
        try {
          FlutterMosambeeAar.printSettlementBatchDetails(
              _transactionData["settlementSummary"], false, 1, 0);
        } catch (e) {
          Logger.e("Exception in Settlement Batch Details::::$e");
        }
        currentTask = "NA";
        return;

      case "NA":
        showResponseDialog(_transactionData);
        return;

      case "UPI COLLECT":
      case "UPI CHECK STATUS":
      case "BQR CHECK STATUS":
        Logger.d("Handle Success $currentTask");
        try {
          _task = _transactionData["message"] + "\n" + _transactionData["transactionID"];
          showResponseDialog(_task);
        } catch (e) {
          Logger.e("Exception in $currentTask Details::::$e");
        }
        return;

      case "VOID":
      case "CARD TRANSACTION HISTORY":
      case "NON CARD TRANSACTION HISTORY":
      case "ONLINE HISTORY":
      case "SALE COMPLETE":
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

    print("Print Receipt called $jsonObject");
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
        FlutterMosambeeAar.getNonCardTransactionHistory("10");
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
                Text('$transactionData'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  performActions(final String task) {
    if (currentTask == "SCAN") {
      FlutterScannerAar.initialise();
      FlutterScannerAar.setWorkMode(0);
      FlutterScannerAar.startScan();
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
          currentTask == "SALE COMPLETE" ||
          currentTask == "Pay") {
        performNonCardTransaction(currentTask);
      } else {
        double amount = double.parse(_amount);
        performTransaction(currentTask, amount,"1" as bool);
      }
    } else if (task == "getAmount_Para1") {
      if (currentTask == "SALE+TIP" || currentTask == "PWCB") {
        performTransactionWithCashback(currentTask, _amount.toString() as double, "1" as double);
      } else {
        performNonCardTransaction(currentTask);
      }
    }
  }
  void performTransaction(String task, double amount, bool isCardNumberCall) {
    FlutterMosambeeAar.initialise(_username, _password);

    if (task == 'UPI QR') {
      FlutterMosambeeAar.generateUPIQR(amount, "Test");
      FlutterScannerAar.initialise();
      FlutterScannerAar.setWorkMode(0);
      FlutterScannerAar.startScan();
    } else if (task == 'Card' || task == 'SALE') {
      FlutterMosambeeAar.initializeSignatureView("#55004A", "#750F5A");
      FlutterMosambeeAar.initialiseFields(
          task, "", "", false, "", "merchantRef1", "bt", "", "");
      FlutterMosambeeAar.setInternalUi(false);
      try {
        FlutterMosambeeAar.setAdditionalTransactionData("null");
      } catch (e) {
        Logger.d("Exception in setAdditionalTransactionData::::$e");
      }
      FlutterMosambeeAar.getCardNumber(isCardNumberCall);
      FlutterMosambeeAar.processTransaction("1234567", "Test",
          amount, double.parse("0"), "ShiperId-879209", "INR");
    } else {
      Logger.d("Unknown transaction type: $task");
    }
  }







  void performTransactionWithCashback(String transType, double amount, double cashbackAmount) {
    FlutterMosambeeAar.initialise(_username, _password);
    FlutterMosambeeAar.initializeSignatureView("#55004A", "#750F5A");
    FlutterMosambeeAar.initialiseFields(transType, "", "cGjhE\$@fdhj4675riesae",
        false, "", "merchantRef1", "bt", "09082013101105", cashbackAmount.toString());
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.processTransaction("123456", "", amount,
        0.0, "ShiperId-879209", "INR");
  }



  Future<List<int>> testBILL(String billno, List<BillItem> items, List<SelectedProductModifier> modifiers,String tableno,double grandtotal,double discpercentt, double disc,String drmark,int pax) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);







    List<int> bytes = [];

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
    if (DuplicatePrint == 'N') {
      bytes += generator.text('[Cancelled Bill]',
        styles: const PosStyles(
          fontType: PosFontType.fontA,
          bold: false,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ),
      );
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



    ////////////for reprint/////////////////






    late Future<List<OrderItem>> futureKOTs;

    late Future<List<OrderModifier>> futureModifiers;


    ////////////for reprint/////////////////






    Future <List<Bill> > futurePendingBills = fetchPendingBill();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder<List<Bill>>(
            future: futurePendingBills,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    double totalAmount = double.tryParse(snapshot.data![index].totalAmount ?? '0') ?? 0.0;
                    double billTax = (snapshot.data![index].billTax != null && snapshot.data![index].billTax!.isNotEmpty)
                        ? double.tryParse(snapshot.data![index].billTax!) ?? 0.00
                        : 0.00;
                    double billDiscount = double.tryParse(snapshot.data![index].billDiscount ?? '0') ?? 0.0;
                    double finalAmount = totalAmount + billTax - billDiscount;
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          // Removed border
                        ),
                        elevation: 0,
                        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(

                              height: 230,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      snapshot.data![index].billNo.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(color: Color(0xFFD5282A), Icons.access_time), // Red Clock icon
                                            const SizedBox(width: 8),
                                            Text(snapshot.data![index].billDate.toString(), style: TextStyle(color: Colors.black87)), // Change to red
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(color: Color(0xFFD5282A), Icons.table_chart),
                                            const SizedBox(width: 8), // Space between icon and text
                                            Text('Table: ${snapshot.data![index].tableNumber}', style: TextStyle(color: Colors.black87)), // Change to red
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Amount: ${finalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Color(0xFFD5282A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),


                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, 0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                side: const BorderSide(
                                                  color: Color(0xBBA90000),
                                                  width: 0.1,
                                                ),
                                              ),
                                              fixedSize: Size(screenWidth > screenHeight ? 120 : 110, screenWidth > screenHeight ? 40 : 30),
                                              backgroundColor: const Color(0xFFD5282A),
                                            ),
                                            onPressed: () {
                                              _showSettleBillDrawer(context, snapshot.data![index].billNo.toString(), finalAmount);
                                            },
                                            child: Center(
                                              child: const Text(
                                                'Settle Bill',
                                                style: TextStyle(
                                                  fontFamily: 'HammersmithOne',
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

/////////////////////////////////////////
                                        const SizedBox(height: 20),
                                        Transform.translate(
                                          offset: Offset(0, -15),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                side: const BorderSide(
                                                  color: Color(0xBB45B100),
                                                  width: 0.1,
                                                ),
                                              ),
                                              fixedSize: Size(
                                                screenWidth > screenHeight ? 120 : 110,
                                                screenWidth > screenHeight ? 20 : 10,
                                              ),
                                              backgroundColor: const Color(0xFF42A5F5),
                                            ),
                                            onPressed: () async {
                                              final billNo = snapshot.data![index].billNo.toString();
                                              final selectedOption = await showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors.white,

                                                    title: const Text(
                                                      'Modify Bill',
                                                      style: TextStyle(
                                                        fontFamily: 'HammersmithOne',
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            title: Container(
                                                              alignment: Alignment.center,
                                                              padding: EdgeInsets.all(8.0),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,  // Set the background color to white
                                                                border: Border.all(color: Color(0xFFD5282A)),
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                              child: const Text(
                                                                'NSC',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Color(0xFFD5282A),  // Text color is still red
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              Navigator.pop(context); // Close dialog first
                                                              try {
                                                                await updateBillWithTax(billNo); // Call function to toggle NSC
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('NSC ${GLOBALNSC == "Y" ? "Applied" : "Removed"} successfully')),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Failed to update NSC status')),
                                                                );
                                                              }
                                                            },

                                                          )

                                                          ,

                                                          const Divider(),
                                                          ListTile(
                                                            title: Container(
                                                              width: 200,  // Set a fixed width (adjust as necessary)
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),  // Reduced padding to minimize space
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                border: Border.all(color: Color(0xFFD5282A)),
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                              child: const Text(
                                                                'Update Discount',
                                                                style: TextStyle(
                                                                  fontSize: 14,  // Decreased font size
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Color(0xFFD5282A),
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.pop(context, 'Discount');
                                                            },
                                                          )

                                                          ,

                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );

                                              if (selectedOption == 'Tax') {
                                                try {
                                                  await updateBillWithTax(billNo);

                                                  await Future.delayed(Duration(milliseconds: 500));

                                                  final updatedBillData = await fetchBillDetails(billNo);

                                                  await executeReprintLogic(updatedBillData);

                                                  await showSuccessDialog(context, billNo);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to update Bill $billNo tax')),
                                                  );
                                                }
                                              }
                                              else if (selectedOption == 'Discount') {
                                                final discountPercent = await _showDiscountDialog(context);

                                                if (discountPercent != null) {
                                                  try {
                                                    await updateBillWithDiscount(billNo, discountPercent);
                                                    await showSuccessDialog(context, billNo);
                                                    await executeReprintLogic(snapshot.data![index]);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to update Bill $billNo')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            child: const Text(
                                              'Modify Bill',
                                              style: TextStyle(
                                                fontFamily: 'HammersmithOne',
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),





                                        const SizedBox(height: 5),

                                        /*  Transform.translate(
                                          offset: Offset(0, -15),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                side: const BorderSide(
                                                  color: Color(0xBB45B100),
                                                  width: 0.1,
                                                ),
                                              ),
                                              fixedSize: Size(screenWidth > screenHeight ? 120 : 110, screenWidth > screenHeight ? 20 : 10),
                                              backgroundColor: const Color(0xBB4CAF50),
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

                                                testBILL(snapshot.data![index].billNo.toString(), allbillitems, allbillmodifers, snapshot.data![index].tableNumber.toString(), grandtotal.toDouble(), discountpercentage, discount, discountremark, 1);

                                                Navigator.pushNamed(context, '/reciptview', arguments: routeArguments);
                                              } catch (e) {
                                                print("Error loading data: $e");
                                              }
                                            },
                                            child: const Text(
                                              'Re-print',
                                              style: TextStyle(
                                                fontFamily: 'HammersmithOne',
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 5),*/
                                        Transform.translate(
                                          offset: Offset(0, -15),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                side: const BorderSide(
                                                  color: Color(0xBB45B100),
                                                  width: 0.1,
                                                ),
                                              ),
                                              fixedSize: Size(screenWidth > screenHeight ? 120 : 110, screenWidth > screenHeight ? 20 : 10),
                                              backgroundColor: const Color(0xBBFF5722),
                                            ),
                                            onPressed: () async {
                                              final billNo = snapshot.data![index].billNo.toString();

                                              try {
                                                DuplicatePrint = 'N';

                                                var tableNumber = snapshot.data![index].tableNumber.toString();
                                                List<dynamic> results = await Future.wait([
                                                  fetchKotItems(tableNumber),
                                                  fetchModifiers(tableNumber),
                                                  fetchBillDetails(snapshot.data![index].billNo.toString()),
                                                ]);

                                                allbilltaxes.clear();
                                                double temptaxsum = 0.0;

                                                // Process the taxes as before
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
                                                  'DNT': posdate,
                                                };

                                                Map<String, dynamic> routeArguments = {
                                                  'billItems': allbillitems,
                                                  'billModifiers': allbillmodifers,
                                                  'billinfo': billinfo,
                                                };

                                                testBILL(snapshot.data![index].billNo.toString(), allbillitems, allbillmodifers, snapshot.data![index].tableNumber.toString(), grandtotal.toDouble(), discountpercentage, discount, discountremark, 1);

                                                String cancelResponse = await cancelBill(billNo);

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: Colors.white.withOpacity(0.7),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Icon(
                                                            cancelResponse.contains('successfully') ? Icons.check_circle : Icons.error,
                                                            size: 48.0,
                                                            color: cancelResponse.contains('successfully') ? Colors.green : Colors.red,
                                                          ),
                                                          const SizedBox(height: 16.0),
                                                          Text(
                                                            cancelResponse, // Show the message from cancelBill
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Colors.blue.shade800,
                                                              fontSize: 18.0,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );

                                                await Future.delayed(const Duration(seconds: 3), () {
                                                  Navigator.of(context).pop();

                                                  if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const MainMenuDesk()),
                                                    );
                                                  } else {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const MainMenu()),
                                                    );
                                                  }
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to cancel Bill $billNo: $e')),
                                                );
                                              }
                                            },
                                            child: const Text(
                                              'Cancel Bill',
                                              style: TextStyle(
                                                fontFamily: 'HammersmithOne',
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),


                                        const SizedBox(height: 5),





                                        Transform.translate(
                                          offset: Offset(0, -15),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                  side: const BorderSide(
                                                    color: Color(0xBB45B100),
                                                    width: 0.1,
                                                  ),
                                                ),
                                                fixedSize: Size(screenWidth > screenHeight ? 120 : 110, screenWidth > screenHeight ? 20 : 10),

                                                backgroundColor: const Color(0xFFFFC107)
                                            ),
                                            onPressed: () async {
                                              var tableNumber = snapshot.data![index].tableNumber.toString();

                                              try {
                                                List<dynamic> results = await Future.wait([
                                                  fetchKotItems(tableNumber),
                                                  fetchModifiers(tableNumber),
                                                  fetchBillDetails(snapshot.data![index].billNo.toString()),
                                                ]);

                                                allbilltaxes.clear();
                                                double temptaxsum = 0.0;

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
                                                  // 'DNT': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()).toString(),
                                                  'DNT': posdate,
                                                };

                                                Map<String, dynamic> routeArguments = {
                                                  'billItems': allbillitems,
                                                  'billModifiers': allbillmodifers,
                                                  'billinfo': billinfo,
                                                };

                                                testBILL(snapshot.data![index].billNo.toString(), allbillitems, allbillmodifers, snapshot.data![index].tableNumber.toString(), grandtotal.toDouble(), discountpercentage, discount, discountremark, 1);

                                                Navigator.pushNamed(context, '/reciptview', arguments: routeArguments);
                                              } catch (e) {
                                                print("Error loading data: $e");
                                              }
                                            },
                                            child: const Text(
                                              'View Bill',
                                              style: TextStyle(
                                                fontFamily: 'HammersmithOne',
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            Divider(color: Colors.black26, thickness: 1),
                          ],
                        ),
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
    );



  }

  void closeWindowAndPrintReceipt(String transactionData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();

          if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
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
                'Transaction Successful\nPrinting Receipt...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    printReceipt(transactionData);
  }

  Future<void> showSuccessDialog(BuildContext context, String billNo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                'No.DN$billNo\nUpdated Successfully',
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
  }
  Future<void> executeReprintLogic(dynamic billData) async {
    DuplicatePrint = 'Y';

    var tableNumber = billData.tableNumber.toString();

    try {
      // Fetch the necessary data
      List<dynamic> results = await Future.wait([
        fetchKotItems(tableNumber),
        fetchModifiers(tableNumber),
        fetchBillDetails(billData.billNo.toString()),
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
          double taxable = (pec / 100.00) * (billamount > 0.0 ? billamount : subtotal);


          if (!(tax.taxName == "Service Charge" && taxable == 0.00)) {
            allbilltaxes.add(LocalTax(tax.taxCode, tax.taxName, tax.taxPercent, taxable));
          }
        }
      }


      sumoftax = temptaxsum;
      grandtotal = subtotal + sumoftax - discount;

      // Collect bill info
      Map<String, String> billinfo = {
        'name': "pratk",
        'Total': "$grandtotal",
        'BillNo': billData.billNo.toString(),
        'waiter': "$username",
        'discount': "$discount",
        'discountper': "$discountpercentage",
        'discountremark': "$discountremark",
        'custname': "$custname",
        'custmobile': "$custmobile",
        'custgst': "$custgst",
        'user': "$username",
        'DNT': posdate,
      };

      Map<String, dynamic> routeArguments = {
        'billItems': allbillitems,
        'billModifiers': allbillmodifers,
        'billinfo': billinfo,
      };

      testBILL(
        billData.billNo.toString(),
        allbillitems,
        allbillmodifers,
        billData.tableNumber.toString(),
        grandtotal.toDouble(),
        discountpercentage,
        discount,
        discountremark,
        1,
      );

      Navigator.pushNamed(context, '/reciptview', arguments: routeArguments);
    } catch (e) {
      print("Error loading data: $e");
    }
  }

}


Future<double?> _showDiscountDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  double? discountPercent;

  return showDialog<double>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Discount Percentage'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Discount Percentage',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final enteredValue = double.tryParse(controller.text);
              if (enteredValue != null) {
                discountPercent = enteredValue;
                Navigator.of(context).pop(discountPercent);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


void postData(BuildContext context, List<BillItem> items, List<SelectedProductModifier> modifiers, Map<String, String> data) async {
  final url = Uri.parse('${apiUrl}order/settle');
  final body = json.encode({
    'items': items.map((item) => item.toJson()).toList(),
    'modifiers': modifiers.map((modifier) => modifier.toJson()).toList(),
    'data': data,
  });

  Logger.d("POST URL: $url");
  Logger.d("POST Body: $body");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    Logger.d("Response Status Code: ${response.statusCode}");
    Logger.d("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      ToastUtils.showNormalToast("Data posted successfully");
      Logger.d("Data posted successfully: ${response.body}");
    } else {

      ToastUtils.showErrorToast("Failed to post data: ${response.body}");
      Logger.e("Failed to post data: ${response.body}");
    }
  } catch (error) {
    ToastUtils.showErrorToast("Error posting data: $error");
    Logger.e("Error posting data: $error");
  }
}




class SettleBillDrawer extends StatelessWidget {
  final String billId;
  final double amount;
  final Function(String, double) performTransaction;

  final Map<String, String> settlementModeMap = {
    'Multi settlement': 'Multi settlement',
    'Cash': 'Cash',
    'UPI QR': 'UPI QR',
    'Card': 'Card',
    'Credit': 'Credit',
    'Pay': 'Pay',
  };

  SettleBillDrawer({super.key, required this.billId, required this.amount, required this.performTransaction});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenWidth > screenHeight ? 760 : 330,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
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
          const SizedBox(height: 4.0),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(1.0),
              shrinkWrap: true,
              childAspectRatio: screenWidth > screenHeight ? 1.4 : 1.0,
              children: settlementModeMap.keys.map((title) {
                return GridItem(
                  title: title,
                  icon: Image.asset(
                    'assets/images/${title.toLowerCase()}.png',
                    height: 50.0,
                    width: 50.0,
                    fit: BoxFit.contain,
                  ),
                  billId: billId,
                  amount: amount,
                  settlementModeMap: settlementModeMap,
                  performTransaction: performTransaction,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
class GridItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final String billId;
  final double amount;
  final Map<String, String> settlementModeMap;
  final Function(String, double) performTransaction;

  const GridItem({
    super.key,
    required this.title,
    required this.icon,
    required this.billId,
    required this.amount,
    required this.settlementModeMap,
    required this.performTransaction,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () async {
        final String settlementMode = settlementModeMap[title] ?? title; // Fallback to title if no mapping exists

        // Perform the transaction and wait for it to complete
        bool transactionSuccessful = await performTransaction(settlementMode, amount) ?? false;

        // Proceed with updating the settlement mode only if the transaction is successful
        if (transactionSuccessful) {
          final String url2 = '${apiUrl}bill/updatesettle/$billId?settlementModeName=$settlementMode&DB=$CLIENTCODE';

          final headers = {
            'Content-Type': 'application/json',
          };


          try {
            final response = await http.get(
              Uri.parse(url2),
              headers: headers,
            );

            if (response.statusCode == 200) {
              print('GET request successful');
              print('Response data: ${response.body}');

              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  Future.delayed(const Duration(seconds: 3), () {
                    Navigator.of(context).pop();

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
                          'Bill No.$billId\nSettled Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              print('GET request failed with status: ${response.statusCode}');
              print('Response data: ${response.body}');
            }
          } catch (e) {
            print('Error sending GET request: $e');
          }
        }
      },
      child: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Color(0xFFF6F6F6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 1.0),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}