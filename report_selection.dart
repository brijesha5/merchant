import 'package:flutter/material.dart';
import 'package:flutter_sample/day_wise_report.dart';
import 'package:flutter_sample/settlement_wise_report.dart';
import 'package:flutter_sample/tax_wise_report.dart';
import 'package:flutter_sample/time_audit_report.dart';
import 'package:flutter_sample/unsettle_report.dart';

import 'bill_kot.dart';
import 'bill_wise_report.dart';
import 'cancel_bill_report.dart';
import 'cancel_kot_report.dart';
import 'compliment_report.dart';
import 'day_end_report.dart';
import 'discount_wise_report.dart';
import 'item_consum_report.dart';
import 'item_wise_report.dart';
import 'kot_analysis_report.dart';
import 'modified_bill_report.dart';
import 'move_kot_report.dart';

void main() {
  runApp(const ReportSelection());
}

class ReportSelection extends StatelessWidget {
  const ReportSelection({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var constraints;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          Navigator.of(context).pop();
        },child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: const Color(0xFFD5282A),

          title: const Text(
            'Reports',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontFamily: 'HammersmithOne',
              fontWeight: FontWeight.bold, // Bold text
              fontSize: 30,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFFFFF),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),





          child: GridView.count(



            crossAxisCount: screenWidth > screenHeight ? 4: 2 , // Number of columns
            crossAxisSpacing: 16.0, // Horizontal spacing between items
            mainAxisSpacing: 16.0, // Vertical spacing between items
            childAspectRatio: MediaQuery.of(context).size.width > 1632 ? 1.4 : 1.5 ,
            children: [
              /// 'Day Wise Report',///
              Padding(
                padding: EdgeInsets.all(screenHeight < screenWidth ? 40 : 0), // Adjust padding based on screen size
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportsScreenNew()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868), // Main text color
                    backgroundColor: Color(0xFFFFFFFF), // White background
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E), // Border color
                        width: 0.5, // Border width
                      ),
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Day Wise Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16, // Reduce font size for smaller screens
                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight < screenWidth ? 9 : 5), // Adjust space for smaller screens
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14, // Reduce font size for smaller screens
                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

/// 'Bill Wise Report',////
              Padding(
                padding: EdgeInsets.all(screenHeight < screenWidth ? 40 : 0), // Adjust padding based on screen size
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Billwise()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bill Wise Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16, // Reduce font size for smaller screens
                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight < screenWidth ? 9 : 5),  // Adjust space for smaller screens
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14, // Reduce font size for smaller screens
                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),



/// 'Day End Report',/////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ),
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dayend()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Day End Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,
                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),
              // 'Item Wise Report',//
               Padding(
          padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ),
          child:
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Itemwise()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Color(0xFF686868),
              backgroundColor: Color(0xFFFFFFFF),
              elevation: 0,
              padding: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: Color(0xFF9E9E9E),
                  width: 0.5,
                ),
              ),
            ),
            icon: const SizedBox.shrink(),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child:  Text(
                    'Item Wise Report',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'HammersmithOne',
                      fontSize: screenHeight < screenWidth ? 20 : 16,                      color: Color(0xFF686868),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child:  Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'HammersmithOne',
                      fontSize: screenHeight < screenWidth ? 18 : 14,                      color: Color(0xFFD5282B),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFD5282B),
                      decorationThickness: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

               ),

              Padding(
                padding: EdgeInsets.all(screenHeight < screenWidth ? 40 : 0), // Adjust padding based on screen size
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CancelBillReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cancel Bill Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16, // Reduce font size for smaller screens
                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight < screenWidth ? 9 : 5),  // Adjust space for smaller screens
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14, // Reduce font size for smaller screens
                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
/// 'Cancel KOT Report',/////
              Padding(
                padding: EdgeInsets.all(screenHeight < screenWidth ? 40 : 0), // Adjust padding based on screen size
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CancelKot()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cancel KOT Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16, // Reduce font size for smaller screens
                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight < screenWidth ? 9 : 5),  // Adjust space for smaller screens
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14, // Reduce font size for smaller screens
                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ////  'Modified Bill',///
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ),
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ModifiedBill()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Modified Bill',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),
              ///  'Bill KOT',///
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ),
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BillKOTReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Bill KOT',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),

/// 'KOT Analysis',////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KotAnalysisReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'KOT Analysis',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),
              /// 'Item Consumption',///
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemConsumptionReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Item Consumption',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
              //Discount////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiscountwiseReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868), // Text color (gray)
                    backgroundColor: Color(0xFFFFFFFF), // White background
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E), // Border color (light gray)
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Discount',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868), // Text color (gray)
                          ),
                        ),
                      ),
                      const SizedBox(height: 9), // Space between the two labels
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B), // Red color for "View Details"
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B), // Underline color in red
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



              ),
              /// 'Unsettle Report',//////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UnsettledReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Unsettle Report',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),

          ///    'Move KOT',////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoveKOTReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Move KOT',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),
             //// 'Time Audit',///
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimeAuditReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Time Audit',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            /// 'Settlement',////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettlementwiseReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Settlement',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ),
             /// 'Tax',////
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaxwiseReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868),
                    backgroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E),
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon by using an empty widget
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Tax',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B),
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
          /// 'Complementary',///
              Padding(
                padding:  EdgeInsets.all( screenHeight < screenWidth ? 40 : 0 ), // Adjust the padding value as needed
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ComplimentaryReport()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF686868), // Text color (gray)
                    backgroundColor: Color(0xFFFFFFFF), // White background
                    elevation: 0,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(0xFF9E9E9E), // Border color (light gray)
                        width: 0.5,
                      ),
                    ),
                  ),
                  icon: const SizedBox.shrink(), // Remove the icon
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Complementary',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 20 : 16,                            color: Color(0xFF686868), // Text color (gray)
                          ),
                        ),
                      ),
                      const SizedBox(height: 9), // Space between the two labels
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenHeight < screenWidth ? 18 : 14,                            color: Color(0xFFD5282B), // Red color for "View Details"
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD5282B), // Underline color in red
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
