import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FireConstants.dart';
// Ensure to add this import for PDF sharing

void main() {
  runApp( Dayend());
}

class Dayend extends StatelessWidget {
   Dayend({Key? key}) : super(key: key);




   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          Navigator.of(context).pop();
        }, child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD5282B), // Custom Hex Color
          title: const Align(
            alignment: Alignment.center, // Center the title
            child: Text(
              'Day End',
              style: TextStyle(color: Colors.white),
            ),
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
        body:  DayendDataPage(),

      ),
    ),
    );
  }
}



class DayendDataPage extends StatefulWidget {
  const DayendDataPage({Key? key}) : super(key: key);

  @override
  _DayendDataPageState createState() => _DayendDataPageState();
}

class _DayendDataPageState extends State<DayendDataPage> {
   Map<String, dynamic> data = {};

  bool isLoading = true;
  String errorMessage = '';
  String previousdate ="";
 // To store the response

  @override
  void initState() {
    super.initState();

    fetchData();


    if(DayCloseRequested == 'Y')
    {
      closeday();
    }
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

  Future<void> printTicketreprint(List<int> ticket) async {
    final printer = PrinterNetworkManager('192.168.29.201');
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);

      print(printing.msg);
      printer.disconnect();





    }




  }

  Future<void> printTicket(List<int> ticket) async {
    final printer = PrinterNetworkManager('192.168.29.201');
    PosPrintResult connect = await printer.connect();
    if (connect == PosPrintResult.success) {
      PosPrintResult printing = await printer.printTicket(ticket);

      print(printing.msg);
      printer.disconnect();


      exit(0);


    }




  }

  Future<void> fetchData({String? posdate, String? previousdate}) async {
    posdate ??= DateFormat('dd-MM-yyyy').format(DateTime.now()); // Format as 'dd-MM-yyyy'
    final String finalPosdate = posdate;
    final String finalPreviousDate = previousdate ?? ''; // Default to empty if not provided

    // Build the URL
    String url = '${apiUrl}report/dayend?DB=${CLIENTCODE}&posdate=${finalPosdate}';

    if (finalPreviousDate.isNotEmpty) {
      url += '&previousdate=${finalPreviousDate}';
    }
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });
    // Make the request
    final response = await http.get(Uri.parse(url));

    print("fetching day end report response code: ${response.statusCode}");

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {

          data = json.decode(response.body);

          setState(() {


            isLoading = false;
          });

          print("dayend report body: " + data.toString());
        } catch (e) {
          setState(() {
            isLoading = false;
            errorMessage = 'Error parsing data: $e';
          });
        }
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: ${response.statusCode}';
      });
    }
  }

  Future<void> _pickDate({required String whichDate}) async {
    DateTime initialDate = DateTime.now();  // Default to current date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {

        // Format the selected date as 'dd-MM-yyyy'
        String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

        // Set posdate or previousdate based on which date is being selected
        if (whichDate == 'posdate') {
          posdate = formattedDate;

        } else {
          previousdate = formattedDate;
          // Fetch data immediately after selecting previousdate
          fetchData(posdate: posdate, previousdate: previousdate);
        }

    }
  }


  Future<void> closeday()
  async {





    final String url2 = '${apiUrl}report/closedayandshiftdata'+'?DB='+CLIENTCODE+'&posdate='+posdate;



    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url2),
        headers: headers,

      );

      if (response.statusCode == 200) {

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.remove("LoggedInUserName");
        // Request successful
        print('POST request successful');
        print('Response data: ${response.body}');



        Map<String, dynamic> jsonData = jsonDecode(response.body.toString());

        // Access the 'status' field
        String statusMessage = jsonData['status'];




        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 5), () async {

              Navigator.of(context).pop();



              if(statusMessage == "shifted")
                {
                  testTicket();
                  DayCloseRequested = 'N';

                }



            });

            // Define a semi-transparent color for the background
            final backgroundColor = Colors.white.withOpacity(0.7);





            return AlertDialog(
              backgroundColor: backgroundColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                   Icon(
                    Icons.check_circle,
                    size: 48.0, // Set the size of the icon
                    color: statusMessage == "shifted" ? Colors.green : Colors.redAccent, // Set the color of the icon
                  ),
                  const SizedBox(height: 16.0), // Add some spacing between icon and text
                  Text(
                    statusMessage,
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
        // Request failed
        print('POST request failed with status: ${response.statusCode}');
        print('Response data: ${response.body}');
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
                  const SizedBox(height: 16.0), // Add some spacing between icon and text
                  Text(
                    'Failed to Close Day',
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
    } catch (e) {
      // An error occurred
      print('Error sending POST request: $e');
    }




  }

//////reprint/////////////////////////
  Future<List<int>> testTicketReprint() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);





    List<int> bytes = [];
    String dineInAmount = data['dineinsaleamt'] ?? "0.000"; // Default to "0.000" if null
    String takeAwayAmount = data['tksalesamt'] ?? "0.000";
    String homeDeliveryAmount = data['hdsaleamt'] ?? "0.000";
    String counterSaleAmount = data['countersaleamt'] ?? "0.000";
    String onlineOrderAmount = data['onlinesaleamt'] ?? "0.000";
    double ordertype = _parseAmount(dineInAmount) +
        _parseAmount(homeDeliveryAmount) +
        _parseAmount(takeAwayAmount) +
        _parseAmount(counterSaleAmount) +
        _parseAmount(onlineOrderAmount);
    String cashSaleAmount = data['cashsaleamt'] ?? "0.000"; // Default to "0.000" if null
    String cardSaleAmount = data['cardsaleamt'] ?? "0.000";
    String upiSaleAmount = data['upisaleamt'] ?? "0.000";
    String swiggySaleAmount = data['swiggysaleamt'] ?? "0.000";
    String zomatoSaleAmount = data['zomatosaleamt'] ?? "0.000";
    double settlement = _parseAmount(cashSaleAmount) +
        _parseAmount(cardSaleAmount) +
        _parseAmount(upiSaleAmount) +
        _parseAmount(swiggySaleAmount) +
        _parseAmount(zomatoSaleAmount);


    String noOfBills = data['nofbils'] ?? "0";
    String discountAmount = data['discountamt'] ?? "0.00";
    String deliveryChargeAmount = data['deliverychargeamt'] ?? "0.00";
    String packagingChargeAmount = data['packagingchargeamt'] ?? "0.00";
    String roundOffAmount = data['roundofamt'] ?? "0.00";
    String tipAmount = data['tipamt'] ?? "0.00";  // Default to "0.000" if null
    String noOfDineInBills = data['nofdineinbills'] ?? "0";
    String noOfTakeAwayBills = data['noftakeawaybills'] ?? "0";
    String noOfHomeDeliveryBills = data['nofhdbills'] ?? "0";
    String noOfCounterBills = data['nofcounterbills'] ?? "0";
    String noOfSwiggyBills = data['nofswiggybills'] ?? "0";
    String noOfZomatoBills = data['nofzomatobills'] ?? "0";
    String noOfComplimentaryBills = data['nofcomplibills'] ?? "0";
    String nofcancelBill = data['nofcancelbill'] ?? "0";
    String cancelAmt = data['cancelamt'] ?? "0.00";
    String nofModifybills = data['nofmodifybills'] ?? "0";
    String nofDiscountedbills = data['nofdiscountedbills'] ?? "0";
    String Discountamt = data['discountamt'] ?? "0.00";
    String nofMovekot = data['nofmovekot'] ?? "0";
    String nofCancelkot = data['nofcancelkot'] ?? "0";
    String paxCount = data['paxcount'] ?? "0.00";
    String mtdNet = data['mtdnet'] ?? "0.00";
    String mtdGross = data['mtdgross'] ?? "0.00";






    String usedCardBalance = data['usedcardbalance'] ?? "0.00";  // Default to "0.000" if null
    String unusedCardBalance = data['unusedcardbalance'] ?? "0.00";
    String foodSubTotal = data['foodsubtotal'] ?? "0.00";
    String foodNetTotal = data['foodnettotal'] ?? "0.000";
    String liquorSubTotal = data['liquorsubtotal'] ?? "0.00";
    String liquorNetTotal = data['liquornettotal'] ?? "0.00";

    print("datarr while reprinting: " + data.toString());

    double totalSubTotal = (_parseAmount(foodSubTotal) + _parseAmount(liquorSubTotal));
    double Group = (_parseAmount(foodSubTotal) + _parseAmount(liquorSubTotal)) +
        (_parseAmount(foodNetTotal) + _parseAmount(liquorNetTotal));

    bytes += generator.text('Day End Report',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));



    bytes += generator.text('');
    bytes += generator.text('  Cient Code: $CLIENTCODE', styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  Brand Name: $brandName', styles: const PosStyles(bold: true,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  POS Date: '+previousdate, styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  Day Close By: $username', styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('  Order Type', styles: const PosStyles(bold: true,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Dine In',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$dineInAmount',  // Use the dineInAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Take Away',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$takeAwayAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Home Delivery',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$homeDeliveryAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Counter Sale',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$counterSaleAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Online Order',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$onlineOrderAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Gross Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: ordertype.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('Settlement Break Up',
        styles: const PosStyles(bold:true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Cash',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$cashSaleAmount',  // Use the cashSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Card',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$cardSaleAmount',  // Use the cardSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'UPI Online',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$upiSaleAmount',  // Use the upiSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Swiggy',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$swiggySaleAmount',  // Use the swiggySaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Zomato',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$zomatoSaleAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Gross Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('Statistics',
        styles: const PosStyles(bold:true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'No. Of Bills',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$noOfBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    /*  bytes += generator.row([
      PosColumn(
        text: 'Sub Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    /*   bytes += generator.row([
      PosColumn(
        text: 'Net Sale',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/


    bytes += generator.row([
      PosColumn(
        text: 'Delivery Charge',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$deliveryChargeAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Packaging Charge',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '$packagingChargeAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
/*    bytes += generator.row([
      PosColumn(
        text: 'Service Charge',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
/*    bytes += generator.row([
      PosColumn(
        text: 'CGST 2.5%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'SGST 2.5%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
/*    bytes += generator.row([
      PosColumn(
        text: 'VAT 10%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
    bytes += generator.row([
      PosColumn(
        text: 'Round Off',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$roundOffAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
/*    bytes += generator.row([
      PosColumn(
        text: 'Grand Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
    bytes += generator.row([
      PosColumn(
        text: 'Tip Amount',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$tipAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);



    ////////////////////
    bytes += generator.row([
      PosColumn(
        text: 'Dine In Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfDineInBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Take Away Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfTakeAwayBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Home Delivery Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfHomeDeliveryBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Counter Sale Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfCounterBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Swiggy Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfSwiggyBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Zomato Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfZomatoBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfComplimentaryBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Amt',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0.000' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofcancelBill',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$cancelAmt',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Modified Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofModifybills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discounted Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofDiscountedbills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discounted Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$Discountamt',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Change Settlement',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Moved KOT',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofMovekot',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled KOT',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofCancelkot',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pax Count',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$paxCount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Pax',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Used Card Balance',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$usedCardBalance',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Unused Card Balance',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$unusedCardBalance',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    /* bytes += generator.row([
      PosColumn(
        text: 'Total Tip Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0.000' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    ////////////////













    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Tax Description',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Taxable',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Tax Amt'+' ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');

    // Assuming taxNames contains the tax details in the given format
    // Assuming taxNames contains the tax details in the given format
    String taxNames = data['taxNames'] ?? "";
    double totalTaxAmount = 0.0;
// Split the taxNames string by newline to handle each tax item
    List<String> taxLines = taxNames.split('\n');

// Iterate through the tax lines and print them one by one
    for (String taxLine in taxLines) {
      // Split each tax line by the delimiter `|` to separate the tax name (with percentage) and amount
      List<String> taxParts = taxLine.split('|');
      if (taxParts.length == 2) {
        String taxName = taxParts[0].trim();  // Extract the tax name with percentage (e.g., "CGST: 2.5%")
        String taxAmount = taxParts[1].trim();  // Extract the tax amount (e.g., "Amount: 11.25")

        // Remove the colon (:) from the tax name
        taxName = taxName.split(':')[0].trim();  // Strip colon and keep tax name with percentage (e.g., "CGST 2.5%")

        // Remove the "Amount: " prefix from the tax amount
        taxAmount = taxAmount.replaceFirst('Amount: ', '').trim();  // Remove "Amount: " from the amount
        double amount = double.tryParse(taxAmount) ?? 0.0; // Handle any invalid numbers gracefully
        totalTaxAmount += amount;
        bytes += generator.row([
          PosColumn(
            text: '$taxName',  // Display the tax name with percentage (e.g., "CGST 2.5%")
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
          PosColumn(
            text: '',  // You can leave this column blank or use it for additional data if necessary
            width: 3,
            styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
          PosColumn(
            text: taxAmount,  // Display the tax amount (e.g., "11.25")
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
        ]);
      }
    }


    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Total Taxation',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '${totalTaxAmount.toStringAsFixed(3)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');





    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Group',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Net Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Gross Total'+' ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');

    bytes += generator.row([
      PosColumn(
        text: 'Food',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Liqour',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '$liquorSubTotal',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),

      PosColumn(
        text: '$liquorNetTotal',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);


    bytes += generator.text('-----------------------------------------------');


    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.text('-----------------------------------------------');




    bytes += generator.row([
      PosColumn(
        text: 'Avg Per Cover',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'MTD Gross',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);


    bytes += generator.row([
      PosColumn(
        text: 'MTD Net',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);



    bytes += generator.text('-----------------------------------------------');



// Print barcode
/*    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));*/


    bytes += generator.feed(2);
    bytes += generator.cut();


    printTicketreprint(bytes);
    return bytes;
  }
////main print for dayend////////////
  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];
    String dineInAmount = data['dineinsaleamt'] ?? "0.000"; // Default to "0.000" if null
    String takeAwayAmount = data['tksalesamt'] ?? "0.000";
    String homeDeliveryAmount = data['hdsaleamt'] ?? "0.000";
    String counterSaleAmount = data['countersaleamt'] ?? "0.000";
    String onlineOrderAmount = data['onlinesaleamt'] ?? "0.000";
    double ordertype = _parseAmount(dineInAmount) +
        _parseAmount(homeDeliveryAmount) +
        _parseAmount(takeAwayAmount) +
        _parseAmount(counterSaleAmount) +
        _parseAmount(onlineOrderAmount);
    String cashSaleAmount = data['cashsaleamt'] ?? "0.000"; // Default to "0.000" if null
    String cardSaleAmount = data['cardsaleamt'] ?? "0.000";
    String upiSaleAmount = data['upisaleamt'] ?? "0.000";
    String swiggySaleAmount = data['swiggysaleamt'] ?? "0.000";
    String zomatoSaleAmount = data['zomatosaleamt'] ?? "0.000";
    double settlement = _parseAmount(cashSaleAmount) +
        _parseAmount(cardSaleAmount) +
        _parseAmount(upiSaleAmount) +
        _parseAmount(swiggySaleAmount) +
        _parseAmount(zomatoSaleAmount);


    String noOfBills = data['nofbils'] ?? "0";
    String discountAmount = data['discountamt'] ?? "0.00";
    String deliveryChargeAmount = data['deliverychargeamt'] ?? "0.00";
    String packagingChargeAmount = data['packagingchargeamt'] ?? "0.00";
    String roundOffAmount = data['roundofamt'] ?? "0.00";
    String tipAmount = data['tipamt'] ?? "0.00";  // Default to "0.000" if null
    String noOfDineInBills = data['nofdineinbills'] ?? "0";
    String noOfTakeAwayBills = data['noftakeawaybills'] ?? "0";
    String noOfHomeDeliveryBills = data['nofhdbills'] ?? "0";
    String noOfCounterBills = data['nofcounterbills'] ?? "0";
    String noOfSwiggyBills = data['nofswiggybills'] ?? "0";
    String noOfZomatoBills = data['nofzomatobills'] ?? "0";
    String noOfComplimentaryBills = data['nofcomplibills'] ?? "0";
    String nofcancelBill = data['nofcancelbill'] ?? "0";
    String cancelAmt = data['cancelamt'] ?? "0.00";
    String nofModifybills = data['nofmodifybills'] ?? "0";
    String nofDiscountedbills = data['nofdiscountedbills'] ?? "0";
    String Discountamt = data['discountamt'] ?? "0.00";
    String nofMovekot = data['nofmovekot'] ?? "0";
    String nofCancelkot = data['nofcancelkot'] ?? "0";
    String paxCount = data['paxcount'] ?? "0.00";
    String mtdNet = data['mtdnet'] ?? "0.00";
    String mtdGross = data['mtdgross'] ?? "0.00";






    String usedCardBalance = data['usedcardbalance'] ?? "0.00";  // Default to "0.000" if null
    String unusedCardBalance = data['unusedcardbalance'] ?? "0.00";
    String foodSubTotal = data['foodsubtotal'] ?? "0.00";
    String foodNetTotal = data['foodnettotal'] ?? "0.000";
    String liquorSubTotal = data['liquorsubtotal'] ?? "0.00";
    String liquorNetTotal = data['liquornettotal'] ?? "0.00";

    bytes += generator.text('Day End Report',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
            align: PosAlign.center,
        ));



    bytes += generator.text('');
    bytes += generator.text('  Cient Code: $CLIENTCODE', styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  Brand Name: $brandName', styles: const PosStyles(bold: true,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  POS Date: $posdate', styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('  Day Close By: $username', styles: const PosStyles(bold: false,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('  Order Type', styles: const PosStyles(bold: true,    height: PosTextSize.size1,
      width: PosTextSize.size1,));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Dine In',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$dineInAmount',  // Use the dineInAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Take Away',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$takeAwayAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Home Delivery',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$homeDeliveryAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Counter Sale',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$counterSaleAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Online Order',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$onlineOrderAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Gross Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: ordertype.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('Settlement Break Up',
        styles: const PosStyles(bold:true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Cash',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$cashSaleAmount',  // Use the cashSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Card',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$cardSaleAmount',  // Use the cardSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'UPI Online',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$upiSaleAmount',  // Use the upiSaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Swiggy',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$swiggySaleAmount',  // Use the swiggySaleAmount extracted from the API response
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Zomato',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$zomatoSaleAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Gross Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.text('Statistics',
        styles: const PosStyles(bold:true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          align: PosAlign.center,
        ));
    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'No. Of Bills',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$noOfBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    /*  bytes += generator.row([
      PosColumn(
        text: 'Sub Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    /*   bytes += generator.row([
      PosColumn(
        text: 'Net Sale',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/


    bytes += generator.row([
      PosColumn(
        text: 'Delivery Charge',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$deliveryChargeAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Packaging Charge',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '$packagingChargeAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
/*    bytes += generator.row([
      PosColumn(
        text: 'Service Charge',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
/*    bytes += generator.row([
      PosColumn(
        text: 'CGST 2.5%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'SGST 2.5%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
/*    bytes += generator.row([
      PosColumn(
        text: 'VAT 10%',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
    bytes += generator.row([
      PosColumn(
        text: 'Round Off',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$roundOffAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
/*    bytes += generator.row([
      PosColumn(
        text: 'Grand Total',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '0.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/
    bytes += generator.row([
      PosColumn(
        text: 'Tip Amount',
        width: 4,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 4,

      ),
      PosColumn(
        text: '$tipAmount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);



    ////////////////////
    bytes += generator.row([
      PosColumn(
        text: 'Dine In Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfDineInBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Take Away Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfTakeAwayBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Home Delivery Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfHomeDeliveryBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Counter Sale Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfCounterBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Swiggy Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfSwiggyBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Zomato Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfZomatoBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$noOfComplimentaryBills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Amt',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0.000' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofcancelBill',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$cancelAmt',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Modified Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofModifybills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discounted Bills',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofDiscountedbills',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discounted Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$Discountamt',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Change Settlement',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Moved KOT',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofMovekot',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cancelled KOT',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$nofCancelkot',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pax Count',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$paxCount',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

/*    bytes += generator.row([
      PosColumn(
        text: 'Complimentary Pax',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    bytes += generator.row([
      PosColumn(
        text: 'Used Card Balance',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$usedCardBalance',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Unused Card Balance',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '$unusedCardBalance',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    /* bytes += generator.row([
      PosColumn(
        text: 'Total Tip Amount',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, underline: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        width: 3,
      ),
      PosColumn(
        text: '0.000' + '  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);*/

    ////////////////













    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Tax Description',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Taxable',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Tax Amt'+' ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');

    // Assuming taxNames contains the tax details in the given format
    // Assuming taxNames contains the tax details in the given format
    String taxNames = data['taxNames'] ?? "";
    double totalTaxAmount = 0.0;
// Split the taxNames string by newline to handle each tax item
    List<String> taxLines = taxNames.split('\n');

// Iterate through the tax lines and print them one by one
    for (String taxLine in taxLines) {
      // Split each tax line by the delimiter `|` to separate the tax name (with percentage) and amount
      List<String> taxParts = taxLine.split('|');
      if (taxParts.length == 2) {
        String taxName = taxParts[0].trim();  // Extract the tax name with percentage (e.g., "CGST: 2.5%")
        String taxAmount = taxParts[1].trim();  // Extract the tax amount (e.g., "Amount: 11.25")

        // Remove the colon (:) from the tax name
        taxName = taxName.split(':')[0].trim();  // Strip colon and keep tax name with percentage (e.g., "CGST 2.5%")

        // Remove the "Amount: " prefix from the tax amount
        taxAmount = taxAmount.replaceFirst('Amount: ', '').trim();  // Remove "Amount: " from the amount
        double amount = double.tryParse(taxAmount) ?? 0.0; // Handle any invalid numbers gracefully
        totalTaxAmount += amount;
        bytes += generator.row([
          PosColumn(
            text: '$taxName',  // Display the tax name with percentage (e.g., "CGST 2.5%")
            width: 5,
            styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
          PosColumn(
            text: '',  // You can leave this column blank or use it for additional data if necessary
            width: 3,
            styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
          PosColumn(
            text: taxAmount,  // Display the tax amount (e.g., "11.25")
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
          ),
        ]);
      }
    }


    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Total Taxation',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '${totalTaxAmount.toStringAsFixed(3)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');





    bytes += generator.text('-----------------------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Group',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Net Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: 'Gross Total'+' ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.text('-----------------------------------------------');

    bytes += generator.row([
      PosColumn(
        text: 'Food',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Liqour',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '$liquorSubTotal',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),

      PosColumn(
        text: '$liquorNetTotal',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);


    bytes += generator.text('-----------------------------------------------');


    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(
        text: settlement.toStringAsFixed(3),
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: true, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);

    bytes += generator.text('-----------------------------------------------');




    bytes += generator.row([
      PosColumn(
        text: 'Avg Per Cover',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'MTD Gross',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);


    bytes += generator.row([
      PosColumn(
        text: 'MTD Net',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
      PosColumn(

        width: 3,

      ),
      PosColumn(
        text: '0000.000'+'  ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right,  bold: false, height: PosTextSize.size1,
          width: PosTextSize.size1,),
      ),
    ]);



    bytes += generator.text('-----------------------------------------------');



// Print barcode
/*    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));*/


    bytes += generator.feed(2);
    bytes += generator.cut();


    printTicket(bytes);
    return bytes;
  }

  Future<String> exportToPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Day End Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Bill Date', 'Bill Total'],
                data: [
                  [data['billDate'] ?? 'N/A', data['billTotal'] ?? 'N/A'],
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/dayend_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<String> exportToExcel(BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Bill Date', 'Bill Total']);
    sheetObject.appendRow([data['billDate'] ?? 'N/A' , data['billTotal'] ?? 'N/A']);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/dayend_data.xlsx';
    final file = File(path);

    file.writeAsBytesSync(excel.encode()!);
    OpenFile.open(path);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always display the date section at the top
            _buildDateSection('', previousdate, 'previousdate'),

            // Conditional rendering based on loading/error state
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // PDF Export Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final filePath = await exportToPdf(context);
                        _showDialog(context, 'PDF File Saved', 'File saved at: $filePath');
                        await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: 'dayend_report.pdf');
                      },
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text('Export to PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red, // text color
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),

                    const SizedBox(width: 36),  // Horizontal space between buttons
                    // Excel Export Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final filePath = await exportToExcel(context);
                        _showDialog(context, 'Excel File Saved', 'File saved at: $filePath');
                      },
                      icon: const Icon(Icons.grid_on, color: Colors.white),
                      label: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, // text color
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // padding
                      ),
                    )
,
                    const SizedBox(width: 36),  // Horizontal space between buttons
                    // Reprint Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await testTicketReprint();
                        _showDialog(context, 'Re-print Done', 'Re-print Successfully');
                      },
                      icon: const Icon(Icons.grid_on, color: Colors.white),
                      label: const Text('Re-print', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26, // background color
                      ),
                    ),

                  ],
                ),
                _buildSectionDivider(),
                _buildHeader('Order Type'),
                _buildSectionDivider(),
                _buildSalesData(),
                _buildSectionDivider(),
                _buildHeader('Settlement Breakup'),
                _buildSectionDivider(),
                _buildSettlementData(),
                _buildTaxData(),
                _buildSectionDivider(),
                _buildGroupDetails(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(String label, String? date, String dateType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align content to the right
        children: [
          // Show the selected date if available
          if (date != null && date.isNotEmpty)
            Text(
              date,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

          // Calendar icon always visible to allow date change
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _pickDate(whichDate: dateType), // Open the date picker when tapped
          ),

          // Printer icon visible only if the previous date is selected and data is available
        /*  if (dateType == 'previousdate' && date != null && date.isNotEmpty)
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () async {
                if (data.isNotEmpty) {
                  // Check if there's data to print
                  List<int> ticketData = await testTicket(); // Generate ticket data
                  await printTicket(ticketData); // Print the ticket
                } else {
                  // If no data available, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No data available for printing.")),
                  );
                }
              },
            ),*/
        ],
      ),
    );
  }




  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(
        color: Colors.grey[500],
        thickness: 1,
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSalesData() {
    double grandTotal = 0.0;
    grandTotal += _parseAmount(data['dineinsaleamt']);
    grandTotal += _parseAmount(data['hdsaleamt']);
    grandTotal += _parseAmount(data['tksalesamt']);
    grandTotal += _parseAmount(data['countersaleamt']);
    grandTotal += _parseAmount(data['onlinesaleamt']);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalesRow('Dine In', data['dineinsaleamt']),
          _buildSalesRow('Home Delivery', data['hdsaleamt']),
          _buildSalesRow('Take Away', data['tksalesamt']),
          _buildSalesRow('Counter Sale', data['countersaleamt']),
          _buildSalesRow('Online Order', data['onlinesaleamt']),
          _buildSalesRow('Grand Total', grandTotal.toStringAsFixed(2), grandTotal: true),

        ],
      ),
    );
  }
  double _parseAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 0.0;
    }
    return double.tryParse(amount) ?? 0.0;
  }
  Widget _buildSettlementData() {
    double grandTotal = 0.0;
    grandTotal += _parseAmount(data['cashsaleamt']);
    grandTotal += _parseAmount(data['cardsaleamt']);
    grandTotal += _parseAmount(data['upisaleamt']);
    grandTotal += _parseAmount(data['swiggysaleamt']);
    grandTotal += _parseAmount(data['zomatosaleamt']);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalesRow('Cash Sales', data['cashsaleamt']),
          _buildSalesRow('Card Sales', data['cardsaleamt']),
          _buildSalesRow('UPI Sales', data['upisaleamt']),
          _buildSalesRow('Swiggy Sales', data['swiggysaleamt']),
          _buildSalesRow('Zomato Sales', data['zomatosaleamt']),
          _buildSalesRow('Grand Total', grandTotal.toStringAsFixed(2), grandTotal: true),

        ],
      ),
    );
  }

  Widget _buildTaxData() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider above the header
          _buildSectionDivider(),

          // Updated Heading for "Tax Name" and "Amount"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align headings on opposite ends
              children: [
                Text(
                  "Tax Description", // Updated header to "Tax Name"
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                Text(
                  "Amount", // Updated header to "Amount"
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Divider below the header
          _buildSectionDivider(),

          // Section for displaying individual tax rows
          ..._buildGroupedTaxNames(data['taxNames']),
        ],
      ),
    );
  }


  List<Widget> _buildGroupedTaxNames(String? taxNames) {
    if (taxNames == null || taxNames.isEmpty) {
      return [Text('No tax names available', style: TextStyle(fontSize: 14))];
    }

    // Split the taxNames into separate lines
    List<String> taxList = taxNames.split('\n').map((e) => e.trim()).toList();

    // Map to group taxes by their names (e.g., "CGST", "SGST", "Service Charge")
    Map<String, double> taxGroupTotals = {};

    // Process each tax entry to calculate the totals
    for (var tax in taxList) {
      var parts = tax.split('|');
      if (parts.length == 2) {
        var taxName = parts[0].trim();
        var taxAmount = parts[1].trim().replaceFirst('Amount: ', '').trim();

        double amount = double.tryParse(taxAmount) ?? 0.0;

        // Group by tax name and sum amounts
        if (taxGroupTotals.containsKey(taxName)) {
          taxGroupTotals[taxName] = taxGroupTotals[taxName]! + amount;
        } else {
          taxGroupTotals[taxName] = amount;
        }
      }
    }

    // Create widgets for each group
    List<Widget> taxWidgets = [];
    double grandTotal = 0.0;

    // Iterate over each grouped tax and display the total for each
    taxGroupTotals.forEach((taxName, totalAmount) {
      taxWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align tax description to left, amount to right
            children: [
              Expanded(
                child: Text(
                  taxName, // Tax description (e.g., CGST, SGST, Service Charge)
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis, // Prevent text overflow if too long
                ),
              ),
              Text(
                totalAmount.toStringAsFixed(2), // Display the total amount for the group
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      );

      // Add the total to the grand total
      grandTotal += totalAmount;
    });

    // Add the grand total row
    taxWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align tax description to left, amount to right
          children: [
            Text(
              "Grand Total", // Label for the grand total
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              grandTotal.toStringAsFixed(2), // Grand total of all taxes
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );

    return taxWidgets;
  }






  Widget _buildSalesRow(String label, String? value, {bool grandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Label Text (Grand Total will have font size 16)
          Text(
            label,
            style: TextStyle(
              fontSize: grandTotal ? 16 : 14,  // Grand Total label font size = 16, others = 14
              fontWeight: grandTotal ? FontWeight.bold : FontWeight.w500,  // Bold for Grand Total, normal for others
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),  // Adjust padding to fit layout
                child: Text(
                  value ?? 'N/A',
                  style: TextStyle(
                    fontSize: grandTotal ? 16 : 14,  // Grand Total value font size = 16, others = 14
                    fontWeight: grandTotal ? FontWeight.bold : FontWeight.w500,  // Bold for Grand Total, normal for others
                    color: grandTotal ? Colors.black : Colors.black54,  // Black for Grand Total, lighter for others
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row for Group, Subtotal, NetTotal (no extra divider)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Subtotal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(child: Text('NetTotal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
            ],
          ),
          const Divider(color: Colors.grey, thickness: 1),  // Divider between headers and rows

          // Food details
          _buildGroupRow('Food', data['foodsubtotal'], data['foodnettotal']),

          // Liquor details
          _buildGroupRow('Liquor', data['liquorsubtotal'], data['liquornettotal']),

          // Add extra space after Liquor
          SizedBox(height: 76),  // Adds space between Liquor section and subsequent content
        ],
      ),
    );
  }

  Widget _buildGroupRow(String group, String? subtotal, String? netTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(group, style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: Text(
              subtotal ?? '0.00',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              netTotal ?? '0.00',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}