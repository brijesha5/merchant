import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sample/Reservation_model.dart';
import 'FireConstants.dart';

void main() {
  runApp(const UpcomingReservationScreen());
}

class UpcomingReservationScreen extends StatelessWidget {
  const UpcomingReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: null, // Set the app bar to null to remove it
        body: Stack(
          children: [
            Positioned(
              top: 20, // Adjust top position as needed
              left: 10, // Adjust left position as needed
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const ReservationList(),
          ],
        ),
      ),
    );
  }
}

class ReservationList extends StatelessWidget {
  const ReservationList({super.key});



  Future<List<Reservation>> fetchUpcomingRes() async {
    final response = await http.get(Uri.parse('${apiUrl}reservation/getAll?DB='+CLIENTCODE));



    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
      return parsed.map<Reservation>((json) => Reservation.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load Pending Reservations');
    }
  }







  void _showSettleBillDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const SettleBillDrawer(); // Your custom drawer content
      },
    );
  }


  _showBillDetails(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reservation Details',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Res No: ${reservation.resNo}'),
              Text('Res Date: ${reservation.resDate}'),
            //  Text('Table Number: ${reservation.tableId == 0 ? "TK" : reservation.tableId}'),
              Text('Guest Name: ${reservation.guestName}'),
              Text('Guest Mobile No: ${reservation.guestName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }








  @override
  Widget build(BuildContext context) {


    Future <List<Reservation> > futureUpcomingRes = fetchUpcomingRes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,


      children: [





        // Add the text widget above the ListView
        const Center(

          child: Padding(
            padding: EdgeInsets.only(top: 60.0,bottom: 10),

            child: Text(
              'Upcoming Reservations',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(


          child: FutureBuilder<List<Reservation>>(
            future: futureUpcomingRes,
            builder: (context, snapshot) {


              if (snapshot.hasData) {


                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // Add your desired action here when a card is tapped
                        // For example, you can show more details about the bill.
                        _showBillDetails(context, snapshot.data![index]);
                      },


                      child: Card(

                        elevation: 5,
                        margin: const EdgeInsets.only(left: 16,right: 16,bottom: 8),
                    child:SizedBox(
                    height: 150,

                        child: ListTile(
                          title: Text(  style: const TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,

                          ),snapshot.data![index].resNo.toString()),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(color:Colors.redAccent,Icons.access_time), // Clock icon
                                  const SizedBox(width: 8), // Space between icon and text
                                  Text(snapshot.data![index].resDate.toString()), // Bill time
                                ],
                              ),
                           //   const SizedBox(height: 4), // Space between bill time and table number
                              /*Row(
                                children: [
                                  const Icon(color:Colors.redAccent,Icons.table_chart), // Table icon
                                  const SizedBox(width: 8), // Space between icon and text
                                  Text('Table: ${snapshot.data![index].tableId == 0 ? "TK" : snapshot.data![index].tableId}'), // Table number with "Table:"
                                ],
                              ),*/
                              const SizedBox(height: 4), // Space between table number and bill amount
                              Text(
                                'Guest Name: ${snapshot.data![index].guestName}',
                                style: const TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold), // Set text color to red
                              ),


                              const SizedBox(height: 4), // Space between table number and bill amount
                              Text(
                                'Guest Mobile No: ${snapshot.data![index].guestContact}',
                                style: const TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold), // Set text color to red
                              ), /// Bill amount with "Amount:"
                            ],
                          ),
                          trailing: const Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Adjust alignment as needed
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    /*          ElevatedButton(

                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(95, 10),
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () {
                                  _showSettleBillDrawer(context);
                                  // Add your "Settle Bill" button action here
                                  // For example, you can display a dialog or perform some other action.
                                },
                                child: Text('Settle Bill'),
                              ),*/
                     /*         ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(95, 10),
                                  backgroundColor: Colors.blue, // Choose your desired color
                                ),
                                onPressed: () {
                                  // Add your action for the new button here
                                  // For example, you can display another dialog or perform some other action.
                                },
                                child: Text('Add kot'),
                              ),*/
                            ],
                          ),



                        ),

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
}








class SettleBillDrawer extends StatelessWidget {
  const SettleBillDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(

            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Settlement',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          // Remove the Expanded widget and use the GridView directly
          GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true, // Add this line to make the grid occupy only the needed space
            children: const [
              GridItem(title: 'Cash', icon: Icons.payments_outlined),
              GridItem(title: 'Multi settlement', icon: Icons.call_split),
              GridItem(title: 'National/UPI', icon: Icons.flag_circle),
              GridItem(title: 'Card', icon: Icons.payment),
              GridItem(title: 'Credit', icon: Icons.credit_score_rounded),
              GridItem(title: 'PayPal', icon: Icons.paypal),
            ],
          ),
        ],
      ),
    );
  }
}


class GridItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const GridItem({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle grid item tap here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped: $title'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Card(
        elevation: 4.0, // Add elevation for a card-like effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Customize border radius
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.redAccent,
              size: 36.0,
            ),
            const SizedBox(height: 8.0),
            Text(      style: const TextStyle(
              color: Colors.redAccent,), textAlign: TextAlign.center,title),
          ],
        ),
      ),
    );
  }
}

