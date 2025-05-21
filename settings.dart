import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';

import 'Costcenter_model.dart';
import 'main_menu.dart';


void main() {
  runApp(const SettingsScreen());
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _printerType = 'network';




  final TextEditingController controller = TextEditingController();



  final TextEditingController _networkPrinterIpController =
  TextEditingController();
  final TextEditingController _bluetoothPrinterNameController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidthmy = MediaQuery.of(context).size.width;
    double screenHeightmy = MediaQuery.of(context).size.height;





    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: null, // Set the app bar to null to remove it
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50.0, bottom: 13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.redAccent),
                              iconSize: 28.0,
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: screenWidthmy > screenHeightmy
                                      ? 50
                                      : (screenWidthmy > 600 ? 50 : 22),
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xF0F0F0), // Light grey background
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _printerType = 'network'; // Update selected printer type
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Net Printer',
                                  style: TextStyle(
                                    color: _printerType == 'network' ? Color(0xFFD5282A) : Colors.grey, // Red if selected, grey if not
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Underline with red color for selected
                                if (_printerType == 'network')
                                  Container(
                                    height: 2,
                                    color: Color(0xFFD5282A), // Red underline for selected option
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _printerType = 'bluetooth'; // Update selected printer type
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  'BT Printer',
                                  style: TextStyle(
                                    color: _printerType == 'bluetooth' ? Color(0xFFD5282A) : Colors.grey, // Red if selected, grey if not
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Underline with red color for selected
                                if (_printerType == 'bluetooth')
                                  Container(
                                    height: 2,
                                    color: Color(0xFFD5282A), // Red underline for selected option
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),



                  // Conditional rendering based on _printerType
                  _printerType == 'network'
                      ? NetworkPrinterSettings(
                      controller: _networkPrinterIpController)
                      : BluetoothPrinterSettings(
                      controller: _bluetoothPrinterNameController),
                ],
              ),
            ],
          ),
        ),


        ),

    );
  }
}

class NetworkPrinterSettings extends StatelessWidget {
  final TextEditingController controller;

  const NetworkPrinterSettings({super.key, required this.controller});


  Future<void> printTicket(List<int> ticket,String ip,BuildContext ctx) async {

    final GlobalKey<State> progressKey = GlobalKey<State>();

    Future<void> showProgressDialog() async {
      await showDialog(
        context: ctx,
        barrierDismissible: false, // prevent user from dismissing dialog
        builder: (BuildContext context) {
          return Dialog(
            key: progressKey,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16.0),
                  Text("Connecting to Printer..."),
                ],
              ),
            ),
          );
        },
      );
    }


    try {
      // Show progress indicator
      showProgressDialog();

      final printer = PrinterNetworkManager(ip);
      PosPrintResult connect = await printer.connect();

      // Dismiss progress dialog after connect completes
      Navigator.of(ctx, rootNavigator: true).pop();

      if (connect == PosPrintResult.success) {
        PosPrintResult printing = await printer.printTicket(ticket);

        displayMessagesuccess("Printed Successfully", ctx);
        printer.disconnect();
      } else {
        // Show error message if connection fails
        displayMessage("Failed to Connect to Printer", ctx);
      }
    } catch (e) {
      // Handle any exceptions
      print("Error: $e");
      // Ensure the progress dialog is dismissed when an error occurs
      Navigator.of(ctx, rootNavigator: true).pop();
      // Optionally, display an error message
      displayMessage("An error occurred", ctx);
    }




  }


  Future<void> testTicket(BuildContext ctx) async {
    try {
      print("🖨 Initializing Mosambee Printer...");

      // Try initializing Mosambee printer
      await FlutterMosambeeAar.initialise("9920593222", "3241")
          .catchError((error) {
        print("❌ ERROR Initializing Printer: $error");
        displayMessage("Mosambee Initialization Failed: $error", ctx);
        return;
      });

      FlutterMosambeeAar.setInternalUi(false);

      print("🔍 Checking Printer State...");
      int? state = await FlutterMosambeeAar.getPrinterState();
      print("🖨 Printer State: $state");

      if (state == null) {
        print("⚠ Failed to get printer state!");
        displayMessage("Could not get printer state!", ctx);
        return;
      } else if (state == 4) {
        print("⚠ Printer is NOT connected!");
        displayMessage("Bluetooth Printer Not Connected!", ctx);
        return;
      } else {
        print(" Printer is connected!");
      }

      // Sample Receipt JSON
      String jsonObject = jsonEncode({
        "type": "Test Print",
        "message": "Bluetooth Print Successful!",
        "amount": "100.00",
        "transactionId": "TEST123"
      });

      print(" Sending Print Command...");
      await FlutterMosambeeAar.printReceipt(jsonObject, 0, false, true);
      print("Print command sent successfully.");

      displayMessagesuccess("Test Print Sent to Bluetooth Printer", ctx);
    } catch (e) {
      print(" ERROR: $e");
      displayMessage("Printing Failed: $e", ctx);
    }
  }





  @override
  Widget build(BuildContext context) {
    double screenWidthmy = MediaQuery.of(context).size.width;
    double screenHeightmy = MediaQuery.of(context).size.height;


    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Printer IP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5), // Rounded corners with radius 5
                        borderSide: BorderSide(color: Color(0xFFD5282A)), // Red border
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () {
                    testTicket(context); // No need for an IP parameter
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFD5282A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  child: const Text('Test Print'),
                ),


              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Printer Model',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), // Rounded corners with radius 5
                  borderSide: BorderSide(color: Color(0xFFD5282A)), // Red border
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'model1', child: Text('Model 1')),
                DropdownMenuItem(value: 'model2', child: Text('Model 2')),
                // Add more items as needed
              ],
              onChanged: (value) {},
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                'Printer Binding',
                style: TextStyle(
                  fontSize: screenWidthmy > screenHeightmy
                      ? 50
                      : (screenWidthmy > 600 ? 50 : 22),
                  color: Color(0xFFD5282A), // Red text color (hex)
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: FutureBuilder<List<Costcenter>>(
                future: futureCostcenters,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No cost centers found'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Costcenter costcenter = snapshot.data![index];
                        return Column(
                          children: [
                            // Card with white background and no grey color
                            Card(
                              color: Colors.white, // Set the card background to white
                              margin: EdgeInsets.symmetric(vertical: 4.0), // Vertical spacing between cards
                              child: ListTile(
                                title: Text(costcenter.name),
                                subtitle: Text('IP: ${costcenter.printerip1}'),
                              ),
                            ),
                            // Divider after each card
                            Divider(
                              color: Colors.black12, // Light black divider
                              thickness: 1, // Thickness of the divider
                              indent: 16, // Indentation from the left side
                              endIndent: 16, // Indentation from the right side
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),

        ],
      ),
    );



  }

  void displayMessage(String msg,BuildContext ctx) {

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        final backgroundColor = Colors.white.withOpacity(0.7);
        return AlertDialog(
          backgroundColor: backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.print_disabled_sharp,
                size: 48.0,
                color: Colors.red,
              ),
              const SizedBox(height: 16.0),
              Text(
                msg,
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




  void displayMessagesuccess(String msg,BuildContext ctx) {

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        final backgroundColor = Colors.white.withOpacity(0.7);
        return AlertDialog(
          backgroundColor: backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.print,
                size: 48.0,
                color: Colors.green,
              ),
              const SizedBox(height: 16.0),
              Text(
                msg,
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

class BluetoothPrinterSettings extends StatelessWidget {
  final TextEditingController controller;

  const BluetoothPrinterSettings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {



    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Printer IP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    // Implement your test print functionality here
                    String printerIP = controller.text.trim();
                    // testTicket("Network Printer", printerIP, context); // Uncomment to test print
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Adjust padding to match size
                    decoration: BoxDecoration(
                      color: Color(0xFFD5282A), // Red background color
                      borderRadius: BorderRadius.circular(5), // Rounded corners with 5px radius
                    ),
                    child: Center(
                      child: Text(
                        'Test Print',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Printer Model',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'model1', child: Text('Model 1')),
                DropdownMenuItem(value: 'model2', child: Text('Model 2')),
                // Add more items as needed
              ],
              onChanged: (value) {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Costcenter>>(
                future: futureCostcenters,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No cost centers found'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Costcenter costcenter = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            title: Text(costcenter.name),
                            subtitle: Text('IP: ${costcenter.printerip1}'),
                          ),
                        );

                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );




  }


}
