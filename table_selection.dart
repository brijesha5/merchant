import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sample/main_menu.dart';
import 'package:flutter_sample/product_model.dart';
import 'package:flutter_sample/table_model.dart';
import 'package:http/http.dart' as http;

import 'FireConstants.dart';
import 'category_model.dart';
import 'main.dart';
import 'main_menu_desk.dart';


Future<List<Product>> fetchPost() async {
  final response = await http.get(Uri.parse('${apiUrl}product/getAll?DB='+CLIENTCODE));



  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
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
late Future<List<Product>> futurePost;
late Future<List<Category>> futureCategory;
List<Color> ribbonColors = [
  Colors.redAccent,
  Colors.blue,
  Colors.green,
];

class TableSelection extends StatelessWidget {
  const TableSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyStaggeredGridView();
  }
}

class MyStaggeredGridView extends StatelessWidget {
  const MyStaggeredGridView({super.key});
  final String LastClickedModule = '';
  void _handleCardTap(BuildContext context, int index, String status, String name, String Id,String area, int? pax) {
    Map<String, String> myStrings = {
      'name': name,
      'status': status,
      'id': Id,

      'area': area,
      'pax': (pax?.toString() ?? '1'),
    };

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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: waiterController,
                  decoration: InputDecoration(
                    labelText: 'Waiter Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    await _showWaiterNameDialog(context, waiterController);
                  },
                ),
              ],
            ),
            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),

              TextButton(
                onPressed: () {

                  String pax = paxController.text.trim();
                  String waiterName = waiterController.text.trim();

                  myStrings['pax'] = pax;
                  myStrings['waiterName'] = waiterName;

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
              width: double.maxFinite,
              height: 300,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: waiterNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      waiterController.text = waiterNames[index];
                      Navigator.pop(context);
                    },
                    child: Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey[500]!, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          waiterNames[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching waiter names')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    double paddingValue = screenWidth <= 540 ? 14 : 12.0;
    double dynamiCardHeight = screenWidth <= 540 ? 0.9 : 0.67;
    futurePost = fetchPost();
    futureCategory = fetchCategory();


    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 90.0,
            color: Color(0xFFD5282A),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 20.8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 28.0,
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 60, top: 20.8),
                        child: Text(
                          'Table Selection',
                          style: TextStyle(
                            fontFamily: 'HammersmithOne',
                            fontSize: screenWidth > screenHeight ? 50 : (screenWidth > 600 ? 50 : 22),
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
          ),

          Container(
            width: double.infinity,
            height: 60.39,
            color: Colors.grey[200],
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 90.0,
                      height: 37.8,
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
                            margin: const EdgeInsets.only(left: 6.0, right: 4.0),
                            width: 15.0,
                            height: 15.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFD5282A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Occupied',
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
                    SizedBox(width: 4.0),
                    Container(
                      width: 90.0,
                      height: 37.8,
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
                    SizedBox(width: 4.0),
                    Container(
                      width: 95.0,
                      height: 37.8,
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
                    SizedBox(width: 4.0),
                    Container(
                      width: 90.0,
                      height: 37.8,
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
                  ],
                )

            ),
          ),


          Expanded(
            child: FutureBuilder<List<TableSeat>>(
              future: Platform.isWindows ? futureTableWindows : futureTable,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<TableSeat> tables = snapshot.data!;


                  Map<String, List<TableSeat>> areaGroups = {};
                  for (var table in tables) {
                    if (!areaGroups.containsKey(table.area)) {
                      areaGroups[table.area] = [];
                    }
                    areaGroups[table.area]!.add(table);
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
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.6),
                            child: StaggeredGridView.countBuilder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: screenWidth > screenHeight ? 5 : 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              itemCount: tables.length,
                              itemBuilder: (context, index) {
                                var table = tables[index];
                                return GestureDetector(
                                  onTap: () {
                                    _handleCardTap(
                                      context,
                                      index,
                                      table.status,
                                      table.tableName,
                                      table.id.toString(),
                                      table.area,
                                      table.pax,
                                    );
                                  },
                                  child: Card(
                                    color: table.status == "Occupied"
                                        ? const Color(0xFFFFF5F4)
                                        : table.status == "Free"
                                        ? const Color(0xFFFFFF)
                                        : table.status == "Reserved"
                                        ? const Color(0xFFF9FFF3)
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
                                          height: 100,
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
                                );
                              },
                              staggeredTileBuilder: (int index) {
                                return StaggeredTile.count(1, 1);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.6),
                            child: Divider(color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    );
                  });

                  return ListView(
                    children: areaWidgets,
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
          ,
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
            color: Color(0xBBA90000),
            width: 0.1,
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



