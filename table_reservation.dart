import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sample/main_menu.dart';
import 'package:flutter_sample/product_model.dart';
import 'package:flutter_sample/table_model.dart';
import 'package:http/http.dart' as http;

import 'FireConstants.dart';
import 'category_model.dart';


Future<List<Product>> fetchPost() async {
  final response = await http.get(Uri.parse('${apiUrl}product/getAll?DB='+CLIENTCODE));



  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load Product');
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
  // Add more colors as needed
];

class TableReservation extends StatelessWidget {
  const TableReservation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyStaggeredGridView();
  }
}

class MyStaggeredGridView extends StatelessWidget {
  const MyStaggeredGridView({super.key});



Future<void> _reservetable( Map<String, String> tbbStrings)
async {




  final String url2 = '${apiUrl}table/update/${tbbStrings['id']!}'+'?DB='+CLIENTCODE;

  final Map<String, dynamic> data2 = {

    "tableName": tbbStrings['name'],
    "status": "Reserved",
    "id": tbbStrings['id'],
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



}



  void _showReservationDialog(BuildContext context, Map<String, String> tbStrings) {
    TextEditingController guestNameController = TextEditingController();
    TextEditingController mobileNoController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reserving ${tbStrings['name']!}' ,   style: const TextStyle(

            color: Color(0xffff8e32),

          ),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: guestNameController,
                  decoration: const InputDecoration(labelText: 'Guest Name'),
                ),
                TextField(
                  controller: mobileNoController,
                  decoration: const InputDecoration(labelText: 'Mobile No'),
                  keyboardType: TextInputType.phone,
                ),
                ListTile(
                  title: Text(selectedDateTime.toString().split(' ')[0]),
                  subtitle: const Text('Reservation Date'),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDateTime = picked;
                      // Update the UI to reflect the selected date
                      // You may want to use a state management solution here
                    }
                  },
                ),
                ListTile(
                  title: Text(selectedDateTime.toString().split(' ')[1].substring(0, 5)),
                  subtitle: const Text('Reservation Time'),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (picked != null) {
                      selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        picked.hour,
                        picked.minute,
                      );
                      // Update the UI to reflect the selected time
                      // You may want to use a state management solution here
                    }
                  },
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Implement the reservation logic here
                // You can access the entered data using the controllers
                Navigator.of(context).pop();

                _reservetable(tbStrings);
                // Close the dialog
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: const Text(
                'Reserve',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }







  void _handleCardTap(BuildContext context, int index,String status,String name,String Id) {

    Map<String, String> myStrings = {
      'name': name,
      'status': status,
      'id': Id,

    };
    if(status == "Occupied")
      {

     //   Navigator.pushNamed(context, '/busytablescreen');




      //  Navigator.pushNamed(context, '/busytablescreen', arguments: myStrings);

      }

    else if(status == "Reserved")
      {


      }

    else
      {

        _showReservationDialog(context,myStrings);
      //  Navigator.pushNamed(context, '/itemlist', arguments: myStrings);

      }
 /*   switch (index) {
      case 0:
        Navigator.pushNamed(context, '/itemlist');
        print('Tapped on Item 0');
        break;
      case 1:
        print('Tapped on Item 1');
        break;
      default:
        print('Tapped on Item $index');
        break;
    }*/
  }





  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingValue = screenWidth <= 540 ? 14 : 20.0;
    double dynamiCardHeight = screenWidth <= 540 ? 0.9 : 0.67;
    futurePost = fetchPost();
    futureCategory = fetchCategory();


    return  Scaffold(
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 0.0,
                  top: 40.0,
                  right: 0.0,
                  bottom: 0.0,
                ),
                child: Text(
                  'Reservation',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xffff8e32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child:FutureBuilder<List<TableSeat>>(
            future: futureTable,
            builder: (context, snapshot) {
            if (snapshot.hasData) {









              return StaggeredGridView.countBuilder(
                crossAxisCount: screenWidth > screenHeight ? 4 : 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {

                  /*  final table = tables[index];
                    final isTableFree = table.status == 'free';*/


                  return GestureDetector(
                    onTap: () {
                      _handleCardTap(context, index,snapshot.data![index].status.toString(),snapshot.data![index].tableName.toString(),snapshot.data![index].id.toString());
                    },
                    child: Card(
                      //   color: isTableFree ? Colors.green : Colors.redAccent,
                      //       color:  Colors.green.shade300,
                      elevation: 2.0,
                      shape: const RoundedRectangleBorder(

                        borderRadius: BorderRadius.zero,
                      ),
                      child: Stack(
                        children: [



                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors
                                    .white),


                                iconSize: 28.0,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),





                          SizedBox(
                            width: double.infinity,
                            height: index.isEven ? 100 : 150,


                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [


                                // Colored Indicator


                                /*  Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    'assets/images/' + allMenuIcons[index] + '.svg',
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              ),*/
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      snapshot.data![index].tableName.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xffff8e32), // Set text color to blue
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),





                              ],
                            ),
                          ),



                          // Colored indicator circle


                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: snapshot.data![index].status.toString() == "Occupied" ? const OccupiedLabel() : snapshot.data![index].status.toString() == "Reserved" ? const ReservedLabel():const FreeLabel(),
                            ),
                          ),

                        ],
                      ),





                    ),
                  );
                },
                staggeredTileBuilder: (int index) {

                  return StaggeredTile.count(1, dynamiCardHeight);

                },
              );

    } else {
    return const Center(child: CircularProgressIndicator());
    }


}
              ),




















            ),
          ],
        ),
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
      child: const Text(
        'FREE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: const Text(
        'OCCUPIED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
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
      child: const Text(
        'RESERVED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}