import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FireConstants.dart';
import 'main_menu.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_sample/table_model.dart';



class TableReservationNew extends StatefulWidget {
  const TableReservationNew({Key? key});



  @override
  _TableReservationNewState createState() => _TableReservationNewState();
}

class _TableReservationNewState extends State<TableReservationNew> {
  final TextEditingController guestNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController paxCountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedOption; // Variable to store the selected option


  final List<DropdownMenuItem<String>> dropdownOptions = [];





  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  iconSize: 28.0,
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Table Reservation',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 35.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(

                              children: [
                                const SizedBox(height: 20.0),
                                DropdownButtonFormField<String>(
                                  value: _selectedOption,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedOption = newValue;
                                    });
                                    futurePost = fetchPost();
                                    futureCategory = fetchCategory();
                                    futureTable = fetchTable();
                                  },
                                  items: dropdownOptions,
                                  decoration: InputDecoration(
                                    labelText: 'Select Area',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                ),



                                const SizedBox(height: 20.0),
                                TextFormField(


                                  controller: guestNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Guest Name',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.person, color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.redAccent,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only alphabetical characters
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a Guest Name';
                                    }
                                    // You can add more validation logic here if needed
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.email, color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.redAccent,
                                  inputFormatters: [
                                    // No need for input formatters here
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email';
                                    }
                                    // Regular expression to match email format
                                    // This regex allows for a broad range of valid email formats
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                TextFormField(
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.phone, color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.redAccent,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10), // Limit input to 10 characters
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only numeric values
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a phone number';
                                    }
                                    // You can add more validation logic here if needed
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),














                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 20.0),
                                DropdownButtonFormField<String>(
                                  value: _selectedOption,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedOption = newValue;
                                    });
                                    futurePost = fetchPost();
                                    futureCategory = fetchCategory();
                                    futureTable = fetchTable();
                                  },
                                  items: dropdownOptions,
                                  decoration: InputDecoration(
                                    labelText: 'Select Table',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20.0),
                                TextFormField(
                                  controller: paxCountController,
                                  decoration: InputDecoration(
                                    labelText: 'Pax Count',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.people, color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.shade900,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.redAccent,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    LengthLimitingTextInputFormatter(3), // Allow only numeric values
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a pax count';
                                    }
                                    // You can add more validation logic here if needed
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      labelStyle: const TextStyle(color: Colors.white),
                                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                                      filled: true,
                                      fillColor: Colors.grey.shade900,
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.redAccent),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          "${_selectedDate.toLocal()}".split(' ')[0],
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                InkWell(
                                  onTap: () => _selectTime(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Time',
                                      labelStyle: const TextStyle(color: Colors.white),
                                      prefixIcon: const Icon(Icons.access_time, color: Colors.white),
                                      filled: true,
                                      fillColor: Colors.grey.shade900,
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.redAccent),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          _selectedTime.format(context),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: Platform.isAndroid || Platform.isIOS ? 0 : 400),
                        child: SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () {
                              _bookTable(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text(
                              'Book Table',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),






                      if (Platform.isMacOS || Platform.isWindows || Platform.isAndroid)
                        Align(
                          alignment: Platform.isAndroid ? Alignment.bottomCenter : Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/upcomingresscreen');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text(

                                'View Upcoming Reserves',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),


                      const SizedBox(height: 20.0),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: Platform.isAndroid || Platform.isIOS ? 0 : 400),
                        child: SizedBox(
                          width: 160,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/table_selection');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text(
                              'Customer Master',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      /*
                      const SizedBox(height: 40.0),*/
                    ],
                  ),
                ),
              ),

              if (Platform.isWindows || Platform.isMacOS) const SizedBox(width: 20.0),
              if (Platform.isWindows || Platform.isMacOS)
                Expanded(
                  child: Container(
                    child: Image.asset(
                      'assets/images/glasstable.jpg',
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bookTable(BuildContext context) async {
    String guestName = guestNameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String paxCount = paxCountController.text;

    // Check if any of the fields is empty
    if (guestName.isEmpty || email.isEmpty || phone.isEmpty || paxCount.isEmpty || _selectedOption == null) {
      // Show an error dialog if any of the fields is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill all the Details.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method if any field is empty
    }

    // Validate email format
    if (!email.contains('@')) {
      // Show an error dialog if email format is invalid
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a valid email address.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method if email format is invalid
    }

    // Validate phone number length
    if (phone.length < 10) {
      // Show an error dialog if phone number is invalid
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a valid phone number.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method if phone number is invalid
    }

    // Convert selected date and time to the required format
    String date = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
    String time = "${_selectedTime.hour}:${_selectedTime.minute}";

    // Construct request body
    Map<String, dynamic> requestBody = {
      "resNo": "RES088",
      "table_id": 10,
      "guestName": guestName,
      "guestContact": phone,
      "paxCount": paxCount,
      "resDate": date,
      "res_Time": time,
      "selectedOption": _selectedOption,
    };

    final response = await http.post(
      Uri.parse('${apiUrl}reservation/create?DB=$CLIENTCODE'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      // Show success dialog if reservation is successful
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainMenu(),
              ),
            );
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
                  'Reserved Successfully',
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
      // Show error dialog if reservation fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
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
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Failed to Reserve Table',
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
}
