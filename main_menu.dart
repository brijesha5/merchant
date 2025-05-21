import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sample/Bill_model.dart';
import 'package:flutter_sample/Costcenter_model.dart';
import 'package:flutter_sample/Online_order_model.dart';
import 'package:flutter_sample/modifier_model.dart';
import 'package:flutter_sample/product_model.dart';
import 'package:flutter_sample/table_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ConfigMaster.dart';
import 'Delivery_partner_model.dart';
import 'FireConstants.dart';
import 'Tax_model.dart';
import 'category_model.dart';

import 'day_end_report.dart';
import 'main.dart';

Future<List<Product>> fetchPost() async {
  final response = await http.get(Uri.parse('${apiUrl}product/getAll?DB='+CLIENTCODE));



  if (response.statusCode == 200) {

    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
  }


}

Future<List<Customer>> fetchCustomers() async {

  try {


    final response = await http.get(Uri.parse('${apiUrl}customer/getAll?DB=$CLIENTCODE'));



    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  } catch (e) {
    throw Exception('Failed to load customers: $e');
  }
}
class Customer {
  final String customerName;
  final int contactNo;

  Customer({required this.customerName, required this.contactNo});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerName: json['customerName'],
      contactNo: int.tryParse(json['contactNo'].toString()) ?? 0,  // Parse contactNo as int
    );
  }
}
Future<List<Modifier>> fetchModifier() async {
  final response = await http.get(Uri.parse('${apiUrl}modifiers/getAll?DB='+CLIENTCODE));



  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Modifier>((json) => Modifier.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
  }
}

Future<List<Costcenter>> fetchCostcenters() async {

  final response = await http.get(Uri.parse('${apiUrl}costcenter/getAll?DB='+CLIENTCODE));



  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Costcenter>((json) => Costcenter.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
  }
}

final AudioPlayer _audioPlayer = AudioPlayer();
/*Future<List<Map<String, String>>> gettaxes() async {
  List<Map<String, String>> taxes = [];
  List<Tax> temptaxes = await futureTaxes;
  for (var tax in temptaxes) {
    Map<String, String> taxMap = {
      'taxname': tax.taxName.toString(),
      'taxpercent': tax.taxPercent.toString(),

    };
    taxes.add(taxMap);
  }

  return taxes;
}*/

Future<Map<String, dynamic>> checkliecence() async {



  return {'status': 'success', 'data': ''};

}
DateTime parseStringDate(String dateString) {
  // Use a specific date format to parse the string
  DateFormat format = DateFormat('dd-MM-yyyy');

  // Parse the string and return the DateTime object
  return format.parseStrict(dateString);
}
Map<String, dynamic> parseData(String data) {
  Map<String, dynamic> parsedMap = HashMap<String, dynamic>();

  // Remove curly braces and split the data into key-value pairs
  List<String> keyValuePairs = data.substring(1, data.length - 1).split(', ');

  // Split each key-value pair and add to the map
  for (var keyValuePair in keyValuePairs) {
    List<String> keyValue = keyValuePair.split(': ');
    String key = keyValue[0];
    dynamic value = keyValue.length > 1 ? keyValue[1] : null;

    // Add the key-value pair to the map
    parsedMap[key] = value;
  }

  return parsedMap;
}
Map<String, String> takeawayStrings = {
  'name': "takeaway",
  'status': "free",
  'id': "0",
  'tableId':'0',
  'area':'0',
};

Map<String, String> counterStrings = {
  'name': "counter",
  'status': "free",
  'id': "0",
  'tableId':'0',
  'area':'0',

};

Map<String, String> homedeliveryStrings = {
  'name': "homedelivery",
  'status': "free",
  'id': "0",
  'tableId':'0',
  'area':'0',

};
Map<String, String> onlineorderStrings = {
  'name': "onlineorder",
  'status': "free",
  'id': "0",
  'tableId':'0',
  'area':'0',

};

Map<String, String> reportStrings = {
  'name': "homedelivery",
  'status': "free",
  'id': "0",
  'tableId':'0',
  'area':'0',

};

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center( // Center the title
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFD5282A), // Set the red color
              fontSize: 25,
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          textAlign: TextAlign.center, // Center the content text
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black, // Set the Cancel text to black
                fontSize: 20, // Increase text size for Cancel button
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.remove("LoggedInUserName");

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFD5282A), // Red color for Logout
                fontSize: 20, // Increase text size for Logout button
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showDaycloseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Day Close',style: TextStyle(fontFamily: 'HammersmithOne',
          color: Colors.redAccent,
        ),),
        content: Text('Are you sure... Close current Day $posdate And Start New?',style: TextStyle(fontFamily: 'HammersmithOne'),),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Cancel',style: TextStyle(fontFamily: 'HammersmithOne'),),
          ),
          TextButton(
            onPressed: ()  {

              DayCloseRequested = 'Y';

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Dayend()),
              );

            },
            child: const Text('Day Close',style: TextStyle(fontFamily: 'HammersmithOne',
              color: Colors.redAccent,
            ),),
          ),
        ],
      );
    },
  );
}

Future<List<Category>> fetchCategory() async {
  final responsecategory = await http.get(Uri.parse('${apiUrl}category/getAll?DB='+CLIENTCODE));
  if (responsecategory.statusCode == 200) {
    final parsed = json.decode(responsecategory.body).cast<Map<String, dynamic>>();
    return parsed.map<Category>((json) => Category.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Category');
  }
}

Future<List<DeliveryPartner>> fetchDeliveryPartner() async {
  final responsedeliverypartner = await http.get(Uri.parse('${apiUrl}deliverypartner/getAll?DB='+CLIENTCODE));
  if (responsedeliverypartner.statusCode == 200) {
    final parsed = json.decode(responsedeliverypartner.body).cast<Map<String, dynamic>>();
    return parsed.map<DeliveryPartner>((json) => DeliveryPartner.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Delivery Partner');
  }
}
Future<List<TableSeat>> fetchTable() async {
  final response = await http.get(Uri.parse('${apiUrl}table/getAll?DB='+CLIENTCODE));
  print('Responcecode${response.statusCode}');
  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<TableSeat>((json) => TableSeat.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
  }
}
late Future<List<Product>> futurePost;
late Future<List<Modifier>> futureModifier;
late Future<List<Costcenter>> futureCostcenters;
late Future<List<Tax>> futureTaxes;
late Future<List<ConfigMaster>> futureConfig;
late Future<List<Category>> futureCategory;
late Future<List<DeliveryPartner>> futureDeliveryPartner;
late Future<List<OnlineOrder>> futureOnlineOrder;

List<OnlineOrder> OnlineOrders = [];
late Future<List<Map<String, String>>> taxes;
late Future<List<TableSeat>> futureTable;
late Future<List<Bill>> futurePendingBill;
late BuildContext scrncontext;
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {

    scrncontext = context;
    return MyStaggeredGridViewmain();


  }
}

class MyStaggeredGridViewmain extends StatelessWidget {

  Timer? _timer;  // Declare a Timer variable
  String playbell = 'N';
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {

    });
  }

  List<String> allMenuItems = [
    'Dine-In',
    'Takeaway',
    'Home Delivery',
    'Counter Sale',
    'Pending Bill',
    'Online Order',
    'Dashborad',
    'Settled Bill',
    'Reservation',
    'Events',
    'Reports',
  ];

  List<String> allMenuIcons = [
    'dinein',
    'takeaway',
    'homedelivery',
    'counter',
    'pendingbill',
    'onlineorder',
    'chart',
    'settlebill',
    'reserve',
    'event-2',
    'reports',

  ];
  MyStaggeredGridViewmain({super.key});

  void _handleCardTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Lastclickedmodule = 'Dine';
        futureTable = fetchTable();
        Navigator.pushNamed(context, '/tableselection');
        print('Tapped on Item 0');
        break;
      case 1:
        Lastclickedmodule = 'Take Away';
        print('Tapped on Item 2');
        Navigator.pushNamed(context, '/itemlist', arguments: takeawayStrings);
        break;
      case 2:
        Lastclickedmodule = 'Home Delivery';
        print('Tapped on Item 3');
        _showHomeDeliveryPopup(context);  // Show the popup for Home Delivery
        break;
      case 3:
        Lastclickedmodule = 'Counter';
        print('Tapped on Item 4');
        Navigator.pushNamed(context, '/itemlist', arguments: counterStrings);
        break;
      case 4:
        Lastclickedmodule = 'Dine';
        print('Tapped on Item 4');
        Navigator.pushNamed(context, '/pendingbillsscreen');
        break;
      case 5:
        print('Tapped on Item 5');
        Navigator.pushNamed(context, '/onlineorderslist', arguments: homedeliveryStrings);
        break;
      case 6:
        print('Tapped on Item 6');
        Navigator.pushNamed(context, '/bidashboard');
        break;
      case 7:
        print('Tapped on Item 7');
        Navigator.pushNamed(context, '/settledbillsscreen');
        break;
      case 8:
        print('Tapped on Item 8');
        Navigator.pushNamed(context, '/tablereservationnew');
        break;
      case 10:
        print('Tapped on Item 10');
        Navigator.pushNamed(context, '/reportSelection');
        break;
      default:
        break;
    }
  }
  void _showHomeDeliveryPopup(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();

    late Future<List<Customer>> futureCustomers;

    futureCustomers = fetchCustomers();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set the background color of the dialog to white
          title: Center(
            child: Text(
              'Home Delivery',
              style: TextStyle(
                color: Color(0xFFD5282A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return FutureBuilder<List<Customer>>(
                future: futureCustomers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No customers available'));
                  } else {
                    List<Customer> customers = snapshot.data!;
                    List<String> customerNames = customers.map((e) => e.customerName).toList();
                    List<String> contactNumbers = customers.map((e) => e.contactNo.toString()).toList();

                    // Filtering customer names and mobile numbers
                    List<String> filteredCustomerNames = customerNames
                        .where((name) => name.toLowerCase().contains(nameController.text.toLowerCase()))
                        .toList();

                    List<String> filteredContactNumbers = contactNumbers
                        .where((number) => number.contains(mobileController.text))
                        .toList();

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Customer Name input with dynamic search popup on icon click
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Search Customer Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  if (filteredCustomerNames.isNotEmpty) {
                                    _showSearchPopup(context, filteredCustomerNames, (selectedName) {
                                      setState(() {
                                        nameController.text = selectedName;
                                        // Fill mobile number automatically based on selected customer
                                        mobileController.text = customers
                                            .firstWhere((customer) => customer.customerName == selectedName)
                                            .contactNo
                                            .toString();
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 16),

                          // Mobile Number input with dynamic search popup on icon click
                          TextField(
                            controller: mobileController,
                            decoration: InputDecoration(
                              labelText: 'Search Mobile Number',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  if (filteredContactNumbers.isNotEmpty) {
                                    _showSearchPopup(context, filteredContactNumbers, (selectedNumber) {
                                      setState(() {
                                        mobileController.text = selectedNumber;
                                        // Fill customer name automatically based on selected number
                                        nameController.text = customers
                                            .firstWhere((customer) => customer.contactNo.toString() == selectedNumber)
                                            .customerName;
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          ),
          actions: <Widget>[
            // Cancel Button with grey[300] background
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700], // Text color (used to be 'primary')
              ),
              child: Text('Cancel'),
            ),
            // Done Button
            TextButton(
              onPressed: () {
                String customerName = nameController.text;
                String mobileNumber = mobileController.text;

                if (customerName.isEmpty || mobileNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select both customer and mobile number')),
                  );
                  return;
                }

                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  '/itemlist',
                  arguments: {
                    'customerName': customerName,
                    'mobileNumber': mobileNumber,
                  },
                );
              },
              child: Text(
                'Done',
                style: TextStyle(color: Color(0xFFD5282A)),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showSearchPopup(BuildContext context, List<String> items, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          content: Container(
            height: 200,
            width: 300,
            child: ListView(
              children: items.map((item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    onSelect(item); // When an item is selected, call the onSelect callback
                    Navigator.pop(context); // Close the popup
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
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

    print("DJKGF"+screenHeight.toString());
    double paddingValue = screenWidth <= 540 ? 14 : 80.0;
    double dynamiCardHeight = screenWidth <= 540 ? 0.6 : 0.67;
    futurePost = fetchPost();
    futureModifier = fetchModifier();
    futureCostcenters = fetchCostcenters();
    futureTaxes = fetchTaxmaster();
    _startTimer();
    futureCategory = fetchCategory();
    futureDeliveryPartner = fetchDeliveryPartner();
    futureTable = fetchTable();
    return WillPopScope(
        onWillPop: () async {
          bool confirmExit = await showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  content: const Text(
                    'Do you want Exit?', style: TextStyle(color: Colors.blue),),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Stay on this screen
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
          );
          return confirmExit ?? false;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: FutureBuilder<Map<String, dynamic>>(
                future: checkliecence(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while checking the license
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || snapshot.data == null ||
                      snapshot.data?['status'] == 'failed') {
                    // Handle errors or license check failure
                    return const Center(
                      child: Text('License Verification failed',style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),),
                    );
                  }
                  else if (snapshot.hasError || snapshot.data == null ||
                      snapshot.data?['status'] == 'expired') {
                    // Handle errors or license check failure
                    return const Center(
                      child: Text(textAlign: TextAlign.center,'Your License is Expired\nPlease Contact : +91 9920593888',style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent, // Set the text color to red or any other color

                      ),),
                    );
                  }

                  else {
                    return Stack(
                      children: [

                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            alignment: Alignment.topCenter,
                            height: 130,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0),
                              ),
                              color: Color(0xFFE7E7E7),
                            ),
                            child: null, /* add child content here */
                          ),
                        ),

                        Align(
                          alignment: Alignment.topRight, // Keep the position at the top-right
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                            child: Container(
                              width: 40.0, // Smaller background width
                              height: 40.0, // Smaller background height
                              decoration: BoxDecoration(
                                color: Color(0xFFD5282A), // Custom red background color
                                borderRadius: BorderRadius.circular(5.0), // Fully rounded corners
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white, // White icon color
                                ),
                                iconSize: 24.0, // Smaller icon size to fit inside the circle
                                onPressed: () async {
                                  Navigator.pushNamed(context, '/settings', arguments: reportStrings);
                                },
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0, left: 60,),
                            child:Text(
                              username,
                              style: TextStyle(
                                fontFamily: 'HammersmithOne',
                                fontSize: screenWidth > screenHeight ? 30 : 18,
                                color: const Color(0xFFD5282A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),


                        Align(
                          alignment: Alignment.topRight, // Keeps the icon at the top-right
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30.0, right: 50.0), // Adjust right padding as needed
                            child: Container(
                              width: 40.0, // Container width (adjust based on icon size)
                              height: 40.0, // Container height (adjust based on icon size)
                              decoration: BoxDecoration(
                                color: Color(0xFFD5282A), // Red background color for the container
                                borderRadius: BorderRadius.circular(5.0), // Border radius of 5
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(0, 2), // Optional shadow for elevation effect
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.white, // White color for the icon itself
                                ),
                                iconSize: 24.0, // Icon size
                                onPressed: () async {
                                  showLogoutDialog(context);
                                  // Implement your logout logic here
                                },
                              ),
                            ),
                          ),
                        ),


                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50, left: 15), // Default padding for the entire Row
                            child: GestureDetector(
                              onTap: () {
                                showDaycloseDialog(context);  // Your function to show a dialog
                              },
                              child: Stack(
                                clipBehavior: Clip.none, // Allow content to overflow the stack boundary
                                children: [
                                  // Image widget (moves upwards with negative top value)
                                  Positioned(
                                    top: screenWidth > screenHeight ? -0 : -4,  // If screen is wide, move logo upwards more
                                    left: screenWidth > screenHeight ? 0 : 5,    // Adjust logo position if screen is wide
                                    child: Image.asset(
                                      'assets/images/reddpos.png', // Path to your image
                                      width: screenWidth > screenHeight ? 50 : 38, // Larger image on wide screens
                                      height: screenWidth > screenHeight ? 50 : 38, // Larger image on wide screens
                                    ),
                                  ),

                                  // Text widget (adjust the positioning based on screen size)
                                  Positioned(
                                    left: screenWidth > screenHeight ? 46 : 46,  // Move the text further right for wide screens
                                    top: screenWidth > screenHeight ? 20 : 12,  // Move text down more on wider screens
                                    child: Text(
                                      posdate,  // The dynamic posdate text you want to display
                                      style: TextStyle(
                                        fontFamily: 'HammersmithOne',
                                        fontSize: screenWidth > screenHeight ? 30 : 16,  // Larger font for wide screens
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )




                        ,




                        Padding(

                          padding:EdgeInsets.only(left: paddingValue,right: paddingValue),



                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 0.0,
                                    top:  screenWidth > screenHeight ? 40.0:80.0,
                                    right: 0.0,
                                    bottom:  screenWidth > screenHeight ? 20.0:20.0,
                                  ),
                                  child: Text(brandName,
                                    style: TextStyle(
                                      fontSize: screenWidth > screenHeight ? 80:28,
                                      color: const Color(0xFFD20000),
                                      fontFamily: 'HammersmithOne',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: StaggeredGridView.countBuilder(
                                  crossAxisCount: screenWidth > screenHeight
                                      ? 4
                                      : 2,
                                  mainAxisSpacing: screenWidth > screenHeight ? 40.0:8.0,
                                  crossAxisSpacing: screenWidth > screenHeight ? 40.0:8.0,
                                  itemCount: 11,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _handleCardTap(context, index);
                                      },
                                      child: Card(
                                        elevation: 0.0,

                                        color: (index == 0)
                                            ? Color(0xFFF9FFF3) // Red for index 1
                                            : (index == 1)
                                            ? Color(0xFFECF9FF) // Red for index 1
                                            : (index == 2)
                                            ?Color(0xFFFFFBF2)

                                        // Green for index 2
                                            : (index == 3)
                                            ? Color(0xFFFFF5F4)
                                        // Blue for index 3
                                            : (index == 4)
                                            ? Color(0xFFFEF9FF)
                                        // Yellow for index 4
                                            : (index == 5)
                                            ? Color(0xFFF9F9F9)
                                        // Magenta for index 5
                                            : (index == 6)
                                            ? Color(0xFFD5282A)


                                        // Custom color for index 6
                                            : (index == 7)
                                            ? Color(0xBBD6F6FA) // Custom color for index 7
                                            : (index == 8)
                                            ? Color(0xFFFFF5F4)
                                        // Cyan for index 8
                                            : (index == 9)
                                            ? Color(0xBBFAF4D6) // Orange for index 9
                                            : (index == 10)
                                            ? Color(0xFFF9FFF3)
                                        // Purple for index 10
                                            : (index == 11)
                                            ? Color(0xBBD6F6FA) // Gray for index 11
                                            : Colors.transparent,
                                        shape:  RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),

                                          side: BorderSide(
                                            color: (index == 0)
                                                ? Color(0xFF24C92F)
                                            // Red for index 1
                                                : (index == 1)
                                                ? Color(0xFF1EB1E6)
                                            // Red for index 1
                                                : (index == 2)
                                                ? Color(0xFFFF9503)
                                            // Green for index 2
                                                : (index == 3)
                                                ? Color(0xFFD6282A)
                                            // Blue for index 3
                                                : (index == 4)
                                                ? Color(0xFFC626E5)
                                            // Yellow for index 4
                                                : (index == 5)
                                                ? Color(0xFF686868)
                                            // Magenta for index 5
                                                : (index == 6)
                                                ? Color(0xFFD5282A)
                                            // Custom color for index 6
                                                : (index == 7)
                                                ? Color(0xBB008AA9) // Custom color for index 7
                                                : (index == 8)
                                                ? Color(0xBBA90000) // Cyan for index 8
                                                : (index == 9)
                                                ? Color(0xBBFFA500) // Orange for index 9
                                                : (index == 10)
                                                ? Color(0xBB09A900) // Purple for index 10
                                                : (index == 11)
                                                ? Color(0xBB808080) // Gray for index 11
                                                : Colors.transparent, // Default
                                            width: 1, // Adjust border width as needed
                                          ),


                                        ),


                                        child: SizedBox(
                                          width: double.infinity,
                                          height: index.isEven ? 100 : 150,
                                          child: index == 6
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.5),
                                                  child: ColorFiltered(
                                                    colorFilter: ColorFilter.mode(
                                                      Color(0xFFFFFFFF), // Replace with the color you want
                                                      BlendMode.srcIn,
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/${allMenuIcons[index]}.png',
                                                      // Adjust icon size for wider screens
                                                      width: screenWidth > screenHeight ? 48 : 40,
                                                      height: screenWidth > screenHeight ? 48 : 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerRight, // Align text to the right
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: screenWidth > screenHeight ? 40.0 : 140.0, // Adjust padding for wide screens
                                                  ),
                                                  child: Text(
                                                    allMenuItems[index],
                                                    style: TextStyle(
                                                      fontFamily: 'HammersmithOne',
                                                      fontSize: screenWidth > screenHeight ? 20 : 18, // Adjust text size for wide screens
                                                      color: Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                              : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft, // Align text to the left
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start, // Align items to the left
                                                    children: [
                                                      // Icon
                                                      ColorFiltered(
                                                        colorFilter: ColorFilter.mode(
                                                          (index == 0)
                                                              ? Color(0xFF24C92F)
                                                              : (index == 1)
                                                              ? Color(0xFF1EB1E6)
                                                              : (index == 2)
                                                              ? Color(0xFFFF9503)
                                                              : (index == 3)
                                                              ? Color(0xFFD6282A)
                                                              : (index == 4)
                                                              ? Color(0xFFC626E5)
                                                              : (index == 5)
                                                              ? Color(0xFF6F6F6F)
                                                              : (index == 6)
                                                              ? Color(0xBB808080)
                                                              : (index == 7)
                                                              ? Color(0xBB008AA9)
                                                              : (index == 8)
                                                              ? Color(0xBBA90000)
                                                              : (index == 9)
                                                              ? Color(0xBBFFA500)
                                                              : (index == 10)
                                                              ? Color(0xBB09A900)
                                                              : (index == 11)
                                                              ? Color(0xBB808080)
                                                              : Colors.transparent,
                                                          BlendMode.srcIn,
                                                        ),
                                                        child: Image.asset(
                                                          'assets/images/${allMenuIcons[index]}.png',
                                                          width: screenWidth > screenHeight ? 40 : 32, // Adjust icon size for wide screens
                                                          height: screenWidth > screenHeight ? 40 : 32, // Adjust icon size for wide screens
                                                        ),
                                                      ),
                                                      SizedBox(width: 4), // Space between icon and text
                                                      // Text
                                                      Expanded(
                                                        child: Text(
                                                          allMenuItems[index],
                                                          style: TextStyle(
                                                            fontFamily: 'HammersmithOne',
                                                            fontSize: screenWidth > screenHeight ? 18 : 15, // Adjust text size for wide screens
                                                            color: (index == 0)
                                                                ? Color(0xFF24C92F)
                                                                : (index == 1)
                                                                ? Color(0xFF1EB1E6)
                                                                : (index == 2)
                                                                ? Color(0xFFFF9503)
                                                                : (index == 3)
                                                                ? Color(0xFFD6282A)
                                                                : (index == 4)
                                                                ? Color(0xFFC626E5)
                                                                : (index == 5)
                                                                ? Color(0xFF686868)
                                                                : (index == 6)
                                                                ? Color(0xBB808080)
                                                                : (index == 7)
                                                                ? Color(0xBB008AA9)
                                                                : (index == 8)
                                                                ? Color(0xBBA90000)
                                                                : (index == 9)
                                                                ? Color(0xBBFFA500)
                                                                : (index == 10)
                                                                ? Color(0xBB09A900)
                                                                : (index == 11)
                                                                ? Color(0xBB808080)
                                                                : Colors.transparent,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow.ellipsis, // Handle text overflow with ellipsis
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                        ,
                                      ),
                                    );
                                  },

                                  staggeredTileBuilder: (int index) {
                                    if (index == 6) {
                                      return StaggeredTile.count(
                                          screenWidth > screenHeight ? 1 : 2,
                                          screenWidth > screenHeight ? dynamiCardHeight : 0.5);
                                    } else if (index == 0) {
                                      return StaggeredTile.count(
                                          1, dynamiCardHeight);
                                    } else if (index == 2) {
                                      return StaggeredTile.count(1,
                                          screenWidth > screenHeight
                                              ? dynamiCardHeight * 3
                                              : dynamiCardHeight);

                                    } else {
                                      return StaggeredTile.count(
                                          1, dynamiCardHeight);
                                    }







                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                })));
  }


}