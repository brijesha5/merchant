import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sample/Delivery_partner_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sample/main_menu.dart';
import 'package:flutter_sample/product_model.dart';
import 'package:flutter_sample/table_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Costcenter_model.dart';
import 'FireConstants.dart';
import 'category_model.dart';
import 'day_end_report.dart';
import 'package:flutter_sample/Online_order_model.dart';
import 'main.dart';
import 'main_menu_desk.dart';
import 'modifier_model.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:audioplayers/audioplayers.dart';

List<String> allMenuItems = [
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

late Future<List<TableSeat>> futureTableWindows;

Future<List<Product>> fetchPost() async {
  final response = await http.get(Uri.parse('${apiUrl}product/getAll?DB='+CLIENTCODE));


  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
  }
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
void _handleCardTapside(BuildContext context, int index) {
  switch (index) {

    case 0:
      Lastclickedmodule = 'Take Away';
      print('Tapped on Item 2');
      Navigator.pushNamed(context, '/itemlist', arguments: takeawayStrings);
      break;
    case 1:
      Lastclickedmodule = 'Home Delivery';
      print('Tapped on Item 3');
      _showHomeDeliveryPopup(context);
      break;
    case 2:
      Lastclickedmodule = 'Counter';
      print('Tapped on Item 4');
      Navigator.pushNamed(context, '/itemlist', arguments: counterStrings);
      break;
    case 3:
      Lastclickedmodule = 'Dine';
      print('Tapped on Item 4');
      Navigator.pushNamed(context, '/pendingbillsscreen');
      break;
    case 4: // Online Order
      print('Tapped on Online Order');
      Navigator.pushNamed(context, '/onlineorderslist', arguments: homedeliveryStrings);
      break;

    case 5:
      print('Tapped on Item 6');
      Navigator.pushNamed(context, '/bidashboard');
      break;
    case 6:
      print('Tapped on Item 7');
      Navigator.pushNamed(context, '/settledbillsscreen');
      break;
    case 7:
      print('Tapped on Item 8');
      Navigator.pushNamed(context, '/tablereservationnew');
      break;
    case 8:
      print('Tapped on Item 10');
      //  Navigator.pushNamed(context, '/reportSelection');
      break;
    case 9:
      print('Tapped on Item 10');
      Navigator.pushNamed(context, '/reportSelection');
      break;
    default:
      break;
  }
}
class Order {

  final int price;

  Order({

    required this.price,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(

      price: json['price'],
    );
  }
}

Future<List<Category>> fetchCategory() async {
  final responsecategory = await http.get(Uri.parse('${apiUrl}category/getAll?DB='+CLIENTCODE));

  if (responsecategory.statusCode == 200) {
    final parsed = json.decode(responsecategory.body).cast<Map<String, dynamic>>();
    return parsed.map<Category>((json) => Category.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Ctegory');
  }
}

late Future<List<Product>> futurePostWindows;
late Future<List<Category>> futureCategoryWindows;
late Future<List<Modifier>> futureModifierWindows;
late Future<List<Costcenter>> futureCostcentersWindows;
List<Color> ribbonColors = [
  Colors.redAccent,
  Colors.blue,
  Colors.green,
];

class MainMenuDesk extends StatelessWidget {
  const MainMenuDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return  MyStaggeredGridView();
  }
}

class MyStaggeredGridView extends StatelessWidget {
   MyStaggeredGridView({super.key});


  // Function to launch Skype (or other VoIP app) with the phone number
  _launchPhoneDialer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _handleCardTap(BuildContext context, int index, String status, String name, String Id, String area, int? pax) {
    // Create a map of strings to pass to the next screen

    Lastclickedmodule = 'Dine';
    Map<String, String> myStrings = {
      'name': name,
      'status': status,
      'id': Id,
      'area': area,
      'pax': (pax?.toString() ?? '1'), // Convert pax to String (use '0' if null)
    };

    // Handle navigation based on the table's status
    if (status == "Occupied") {
      Navigator.pushNamed(context, '/busytablescreen', arguments: myStrings);
    } else if (status == "Reserved") {

    } else {

      TextEditingController paxController = TextEditingController();
      TextEditingController waiterController = TextEditingController();

      if (pax != null) {
        paxController.text = pax.toString();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: paxController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Pax',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: waiterController,
                  decoration: InputDecoration(
                    labelText: 'Waiter Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  readOnly: true, // Make it read-only since the user will select from a grid
                  onTap: () async {

                    await _showWaiterNameDialog(context, waiterController);
                  },
                ),
              ],
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  // Close the dialog without doing anything
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              // Done Button
              TextButton(
                onPressed: () {
                  // Get the input values from the controllers
                  selectedPax = int.tryParse(paxController.text.trim()) ?? 1; // Convert to int, default to 1
                  String waiterName = waiterController.text.trim();
                  selectedwaitername = waiterController.text.trim();

                  // Add the additional fields to the map
                  myStrings['pax'] = pax?.toString() ?? '1';
                  myStrings['waiterName'] = waiterName; // Store the selected waiter name

                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/itemlist', arguments: myStrings);
                },
                child: Text('Done'),
              ),
            ],
          );

        },
      );
    }
  }

   Future<List<Costcenter>> fetchCostcentersWindows() async {
     try {
       final response = await http.get(Uri.parse('${apiUrl}costcenter/getAll?DB=$CLIENTCODE'));



       if (response.statusCode == 200) {
         final jsonData = json.decode(response.body);

         if (jsonData is List) {
           print("Response is a List with ${jsonData.length} items.");
           return jsonData.map<Costcenter>((json) => Costcenter.fromMap(json)).toList();
         } else if (jsonData is Map<String, dynamic>) {
           print("Response is a single object, wrapping in a list.");
           return [Costcenter.fromMap(jsonData)];
         } else {
           throw Exception("Unexpected JSON format");
         }
       } else {
         throw Exception("API Error: ${response.statusCode}");
       }
     } catch (e, stackTrace) {
       print("Exception: $e");
       print("StackTrace: $stackTrace");
       throw Exception('Failed to load Product');
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

  Future<List<String>> _fetchWaiterNames() async {

    final response = await http.get(Uri.parse('${apiUrl}waiter/getAll?DB=$CLIENTCODE'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<String>((item) => item['waiterName'] as String).toList();
    } else {
      throw Exception('Failed to load waiter names');
    }
  }
  Future<void> _showWaiterNameDialog(BuildContext context, TextEditingController waiterController) async {
    try {
      List<String> waiterNames = await _fetchWaiterNames();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Waiter'),
            content: Container(
              width: 550,
              height: 300, // Adjust height for the grid
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 3 columns in the grid
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: waiterNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Update the waiter name field and close the dialog
                      waiterController.text = waiterNames[index];
                      Navigator.pop(context);
                    },
                    child: Card(
                      color: Colors.grey[200], // Light green background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey[500]!, width: 0.5), // Dark green border
                      ),
                      child: Center(
                        child: Text(
                          waiterNames[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700], // Dark green text color
                            fontWeight: FontWeight.bold, // Make the text bold for better readability
                            fontSize: 15, // Larger font size for better legibility
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Handle any errors (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching waiter names')));
    }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Future<List<DeliveryPartner>> fetchDeliveryPartner() async {
      final responsedeliverypartner = await http.get(Uri.parse('${apiUrl}deliverypartner/getAll?DB='+CLIENTCODE));
      if (responsedeliverypartner.statusCode == 200) {
        final parsed = json.decode(responsedeliverypartner.body).cast<Map<String, dynamic>>();
        return parsed.map<DeliveryPartner>((json) => DeliveryPartner.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load Delivery Partner');
      }
    }



    Future<List<TableSeat>> fetchTableWindows() async {
      final response = await http.get(Uri.parse('${apiUrl}table/getAll?DB='+CLIENTCODE));
      print('Responcecode${response.statusCode}');
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
        return parsed.map<TableSeat>((json) => TableSeat.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load Product');
      }
    }



    double paddingValue = screenWidth <= 540 ? 14 : 12.0;
    double dynamiCardHeight = screenWidth <= 540 ? 0.9 : 0.67;
    futurePostWindows = fetchPost();
    futureCategoryWindows = fetchCategory();
    futureModifierWindows = fetchModifier();
    futureCostcentersWindows = fetchCostcentersWindows();

    futureTableWindows = fetchTableWindows();
    Future<List<DeliveryPartner>> futureDeliveryPartner = fetchDeliveryPartner();
    late Future<List<OnlineOrder>> futureOnlineOrder;

    List<OnlineOrder> OnlineOrders = [];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 60.0,
            color: Colors.white,

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 0.8), // Add left padding for more space to the left
                    child:
                    Image.asset(
                      'assets/images/dposnewlogopn.png',
                      height: screenWidth > screenHeight ? 60 : 75,
                      width: screenWidth > screenHeight ? 120 : 125,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40, top: 10.8), // Add left padding for more space to the left
                        child: Text(
                          brandName,
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenWidth > screenHeight ? 25 : (screenWidth > 600 ? 25 : 22),
                            color: Color(0xFFD5282A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,





                    child: Padding(
                      padding: const EdgeInsets.only(right: 25, top: 0.8), // Add right padding for more space
                      child: Row(
                        children: [

                          SizedBox(width: 8),  // Add some space between the icon and the text
                          Text(
                            posdate,  // The dynamic posdate text you want to display
                            style: TextStyle(
                              fontFamily: 'HammersmithOne',
                              fontSize: screenWidth > screenHeight ? 25 : 16,  // Larger font for wide screens
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
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


          Align(
            alignment: Alignment.centerRight,  // Align the container to the right
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),  // You can keep your padding
              height: 60.39,
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // First Container: Occupied
                    Container(
                      width: 90.0,
                      height: 27.8,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF5F4),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xFFD5282A),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 5.0, right: 4.0),  // Reduced margin
                            width: 12.0,  // Smaller circle size
                            height: 12.0,  // Smaller circle size
                            decoration: BoxDecoration(
                              color: Color(0xFFD5282A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 3.0), // Reduced space between the circle and text
                          Expanded(
                            child: Text(
                              'Occupied',
                              style: TextStyle(
                                fontSize: 14.0,  // Reduced font size
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),

                    ),
                    SizedBox(width: 20.0), // Space between the containers (20px)

                    // Second Container: Free
                    Container(
                      width: 90.0,
                      height: 27.8,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFFF),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xFFBDBDBD),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                            width: 15.0,
                            height: 15.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Free',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.0), // Space between the containers (20px)

                    // Third Container: Reserved
                    Container(
                      width: 95.0,
                      height: 27.8,
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FFF3),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xFF24C92F),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                            width: 15.0,
                            height: 15.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF24C92F),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Reserved',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.0), // Space between the containers (20px)

                    // Fourth Container: Billed
                    Container(
                      width: 90.0,
                      height: 27.8,
                      decoration: BoxDecoration(
                        color: Color(0xBBD6F6FA),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xFF42A5F5),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                            width: 15.0,
                            height: 15.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF42A5F5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Billed',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.0), // Space between the containers (20px)

                    // DayClose button (with transform for vertical alignment)
                    Transform.translate(
                      offset: Offset(0, -20), // Keep the DayClose button in the same position
                      child: Padding(
                        padding: const EdgeInsets.only(left: 500, top: 0),
                        child: GestureDetector(
                          onTap: () {
                            showDaycloseDialog(context); // Your function to show a dialog
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                color: Color(0xFFD5282B),
                                size: 22.0, // Icon size
                              ),
                              SizedBox(width: 8), // Space between the icon and text
                              Text(
                                'DayClose',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFFD5282B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.0), // Space after the DayClose button if needed
                  ],
                ),
              ),
            ),
          )


          ,
          Row(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Column(
                children: [

                  Container(

                      height: 450.0,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xFFFFFFFF),
                          width: 0,
                        ),
                      ),// specify a fixed height here
                      child:ListView.builder(
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _handleCardTapside(context, index);
                            },
                            child: Card(
                              elevation: 0.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 1),
                                          Expanded(
                                            child: Text(
                                              "> " +    allMenuItems[index],
                                              style: TextStyle(
                                                fontFamily: 'HammersmithOne',
                                                fontSize: screenWidth > screenHeight ? 15 : 15,
                                                color: Color(0xFF686868),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 0.0),
                    child:GestureDetector(
                      onTap: () {
                        _launchPhoneDialer('9920593888');
                      },
                      child: Text(
                        "Call for support",
                        style: TextStyle(
                          fontFamily: 'HammersmithOne',
                          fontSize: screenWidth > screenHeight ? 15 : 16,
                          color: Color(0xFFD5282A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),


                  ),





                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, right: 50.0,left: 30), // Adjust right padding as needed
                    child:Container(
                      width: 130.0, // Adjust the width based on the content (icon + text)
                      height: 40.0, // Container height
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
                      child: TextButton(
                        onPressed: () async {
                          showLogoutDialog(context);
                          // Implement your logout logic here
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Remove padding to keep it tight around content
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the content
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.white, // White color for the icon itself
                              size: 24.0, // Icon size
                            ),
                            SizedBox(width: 8.0), // Add some spacing between the icon and text
                            Text(
                              'Logout', // Text to display next to the icon
                              style: TextStyle(
                                color: Colors.white, // White color for the text
                                fontSize: 16.0, // Text size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                ],
              ),





              Expanded(
                child: FutureBuilder<List<TableSeat>>(
                  future: futureTableWindows,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, List<TableSeat>> areaGroups = {};
                      for (var table in snapshot.data!) {
                        if (table.area != 'Online') {  // Exclude the "Online" area
                          if (!areaGroups.containsKey(table.area)) {
                            areaGroups[table.area] = [];
                          }
                          areaGroups[table.area]!.add(table);
                        }
                      }

                      List<Widget> areaWidgets = [];
                      areaGroups.forEach((area, tables) {
                        areaWidgets.add(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9.6),
                                child: Text(
                                  '$area',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF747474),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.6),
                                child: StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: screenWidth > screenHeight ? 10 : 3,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                  itemCount: tables.length,
                                  itemBuilder: (context, index) {
                                    var table = tables[index];
                                    return GestureDetector(
                                      onTap: () {
                                        GLOBALNSC = 'N';

                                        _handleCardTap(
                                          context,
                                          index,
                                          table.status,
                                          table.tableName,
                                          table.id.toString(),
                                          table.area,
                                          table.pax, // Make sure the area is passed here
                                        );
                                      },
                                      child: Card(
                                        color: table.status == "Occupied"
                                            ? const Color(0xFFFFF5F4)
                                            : table.status == "Free"
                                            ? const Color(0xFFFFFF)
                                            : table.status == "Reserved"
                                            ? const Color(0xFFF9FFF3)
                                            : table.status == "Billed"
                                            ? const Color(0xBBD6F6FA)
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
                                                ? const Color(0xFF676767)
                                                : table.status == "Billed"
                                                ? const Color(0xFF42A5F5)
                                                : Color(0xFF747474)!,
                                            width: 0.7,
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
                                                          : table.status == "Billed"
                                                          ? const Color(0xFF42A5F5)
                                                          : Color(0xFF747474),
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
                                                          : table.status == "Billed"
                                                          ? const Color(0xFF42A5F5)
                                                          : Color(0xFF747474),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  staggeredTileBuilder: (int index) {
                                    return StaggeredTile.count(1, 1);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      });

                      return Container(
                        color: Color(0xFFF6F6F6),
                        height: 536.0, // specify a fixed height here
                        child: ListView(
                          children: areaWidgets,
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )


            ],
          ),







        ],
      ),
    );



  }
}

class FreeLabel extends StatelessWidget {
  const FreeLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child:  Text(
        'FREE',
        style: TextStyle(
          color: Colors.white,
          fontSize: Platform.isAndroid ? 12.0 :  24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OccupiedLabel extends StatelessWidget {
  const OccupiedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(top:  BorderSide(
            color: Color(0xBBA90000), // Change this color to whatever you want for the border
            width: 0.1, // Adjust the width as needed
          ),),
          shape: BoxShape.rectangle

      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child:  Text(
        'OCCUPIED',
        style: TextStyle(
          color: Colors.white,
          fontSize:Platform.isAndroid ?  12.0 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReservedLabel extends StatelessWidget {
  const ReservedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child:  Text(
        'RESERVED',
        style: TextStyle(
          color: Colors.white,
          fontSize: Platform.isAndroid ?  12.0 : 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BilledLabel extends StatelessWidget {
  const BilledLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child:  Text(
        'BILLED',
        style: TextStyle(
          color: Colors.white,
          fontSize: Platform.isAndroid ?  12.0 : 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
Future<List<DeliveryPartner>> futureDeliveryPartner = fetchDeliveryPartner();



final AudioPlayer _audioPlayer = AudioPlayer();

