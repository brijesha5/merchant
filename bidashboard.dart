import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sample/main_menu.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_sample/product_model.dart';
import 'package:flutter_sample/table_model.dart';
import 'package:http/http.dart' as http;
import 'FireConstants.dart';
import 'category_model.dart';



class BiDashboard extends StatelessWidget {
  const BiDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return  Bi();
  }
}

class Bi extends StatefulWidget {
  @override
  _BiState createState() => _BiState();
  DateTime selectedDate = DateTime.now();

}

class _BiState extends State<Bi> {
  String totalAmount = '';
  String numberOfBills = '';
  String dineinSaleAmount = '';
  String noOfDineInBills = '';
  String takeawaySaleAmount = '';
  String noOfTakeawayBills = '';
  String deliverySaleAmount = '';
  String noOfDeliveryBills = '';
  String totalOnlineOrders = '';
  String onlineSaleAmount = '';
  String swiggySaleAmount = '';
  String zomatoSaleAmount = '';
  String swiggyPercentage = '0.00';
  String zomatoPercentage = '0.00';
  String noOfSwiggyBills = '';
  String cashSaleAmount = '';
  String cardSaleAmount = '';
  String upiSaleAmount = '';
  String noOfComplimentaryBills = '';
  String noOfCancelledBills = '';
  String nofswiggybills = '';
  String nofzomatobills = '';

  List<_ChartData> chartData = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    fetchData();
    generateRandomData();
  }


  Future<void> fetchData() async {
    final today = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(today);
    try {
      final response = await http.get(Uri.parse('${apiUrl}report/daywise?startDate=$formattedDate&endDate=$formattedDate&DB=$CLIENTCODE'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          totalAmount = 'Rs ${data[0]['billTotal']}';
          numberOfBills = '${data[0]['noOfBills']} Orders';
        });

        final dineinResponse = await http.get(Uri.parse('${apiUrl}report/dayend?posdate=$formattedDate&DB=$CLIENTCODE'));


        if (dineinResponse.statusCode == 200) {
          final Data = json.decode(dineinResponse.body);
          setState(() {
            dineinSaleAmount = 'Rs ${Data['dineinsaleamt']}';
            noOfDineInBills = Data['nofdineinbills'].toString();
            takeawaySaleAmount = 'Rs ${Data['tksalesamt']}';
            noOfTakeawayBills = Data['noftakeawaybills'].toString();
            deliverySaleAmount = Data['hdsaleamt'];
            noOfDeliveryBills = Data['nofhdbills'].toString();
            noOfComplimentaryBills = Data['nofcomplibills'].toString();
            noOfCancelledBills = Data['nofcancelbill'].toString();
            onlineSaleAmount = 'Rs ${Data['onlinesaleamt'].toString()}';
            swiggySaleAmount = 'Rs ${Data['swiggysaleamt']}';
            zomatoSaleAmount = 'Rs ${Data['zomatosaleamt']}';
            noOfSwiggyBills = Data['nofswiggybills'].toString();
            nofzomatobills = Data['nofzomatobills'].toString();
            cashSaleAmount = Data['cashsaleamt'].toString();
            cardSaleAmount = Data['cardsaleamt'].toString();
            upiSaleAmount = Data['upisaleamt'].toString();
            double onlineSales = double.parse(Data['onlinesaleamt']);
            double swiggySales = double.parse(Data['swiggysaleamt']);
            double zomatoSales = double.parse(Data['zomatosaleamt']);

            if (onlineSales > 0) {
              swiggyPercentage = ((swiggySales / onlineSales) * 100).toStringAsFixed(2);
              zomatoPercentage = ((zomatoSales / onlineSales) * 100).toStringAsFixed(2);
            } else {
              swiggyPercentage = '0';
              zomatoPercentage = '0';
            }
            int swiggyBills = int.parse(Data['nofswiggybills']);
            int zomatoBills = int.parse(Data['nofzomatobills']);
            int totalOrders = swiggyBills + zomatoBills;
            totalOnlineOrders = 'Online ($totalOrders) Orders';
          });
        } else {
          print('Failed to load dine-in data');
        }
      } else {
        print('Failed to load daywise data');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void generateRandomData() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 24; i++) {
      chartData.add(_ChartData(
        time: now.subtract(Duration(hours: 23 - i)),
        value: random.nextInt(100).toDouble(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFD5282B)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(),
            SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 70,
              color: Color(0xFFF1F1F1),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFD5282B),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFD5282B), width: 1),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 24,
                          color: Color(0xFFD5282B),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFD5282B), width: 1),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text(
                              DateFormat("d 'th' MMM").format(DateTime.now()),
                              style: TextStyle(
                                color: Color(0xFFD5282B),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFFD5282B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              totalAmount,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD5282B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              numberOfBills,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 1200,
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        interval: 1,
                        dateFormat: DateFormat.Hm(),
                        title: AxisTitle(text: 'Time'),
                        labelStyle: TextStyle(color: Colors.black),
                        maximum: DateTime.now().add(Duration(hours: 1)),
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: false,
                      ),
                      series: <CartesianSeries<_ChartData, DateTime>>[
                        SplineAreaSeries<_ChartData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data.time,
                          yValueMapper: (data, _) => data.value,
                          color: Color(0xFFE8F9E9),
                          gradient: LinearGradient(
                            colors: [Color(0xFFE8F9E9), Color(0x00E8F9E9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            color: Colors.white,
                            borderColor: Color(0xFF04C218),
                            borderWidth: 1,
                          ),
                        ),
                        SplineSeries<_ChartData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data.time,
                          yValueMapper: (data, _) => data.value,
                          color: Color(0xFF03C214),
                          width: 2,
                          markerSettings: MarkerSettings(isVisible: false),
                          splineType: SplineType.natural,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1,
                children: [
                  _buildDineInBox(dineinSaleAmount, noOfDineInBills),
                  _buildTakeawayBox(takeawaySaleAmount, noOfTakeawayBills),
                  _buildDeliveryBox(deliverySaleAmount, noOfDeliveryBills),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildRectangleBox(),
            _buildRectangle2Box(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Statistics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF606060),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.6 / 1.2,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildStatBox(
                      'Success',
                      Color(0xFFF8FFF7),
                      Color(0xFF03C212),
                      iconUrl: 'https://cdn-icons-png.flaticon.com/128/12304/12304274.png',
                      orderCount: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildStatBox(
                      'Cancelled',
                      Color(0xFFFFFBF2),
                      Color(0xFFFE9505),
                      iconUrl: 'https://cdn-icons-png.flaticon.com/128/12758/12758489.png',
                      orderCount: int.tryParse(noOfCancelledBills) ?? 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildStatBox(
                      'Complimentary',
                      Color(0xFEF9FF),
                      Color(0xFFC20EE1),
                      iconUrl: 'https://cdn-icons-png.flaticon.com/512/2438/2438118.png',
                      orderCount: int.tryParse(noOfComplimentaryBills) ?? 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildStatBox(
                      'Table Time',
                      Color(0xFFECF9FF),
                      Color(0xFF02A4E4),
                      iconUrl: 'https://cdn-icons-png.flaticon.com/256/833/833643.png',
                      orderCount: 22,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, Color bgColor, Color borderColor, {String? iconUrl, required int orderCount}) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (iconUrl != null) ...[
                  Transform.translate(
                    offset: Offset(0, 9),
                    child: Image.network(
                      iconUrl,
                      width: 30,
                      height: 30,
                      color: borderColor,
                    ),
                  ),
                  SizedBox(width: 6),
                ],
                Transform.translate(
                  offset: Offset(0, 0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Transform.translate(
              offset: Offset(-6, -6),
              child: Text(
                '$orderCount orders',
                style: TextStyle(
                  fontSize: 14,
                  color: borderColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRectangleBox() {
    double screenWidth = MediaQuery.of(context).size.width;
    double rectangleWidth = screenWidth - (2 * 20);
    double heightInPixels = 19 * 37.8;

    return Container(
      width: rectangleWidth,
      height: heightInPixels,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 40 + 400,
            child: ConcentricCircles(),
          ),

          Positioned(
            left: 16,
            top: 10,
            child: _buildOnlineOrdersDisplay(),
          ),
          Positioned(
            left: 16,
            top: 60,
            child: _buildOnlineSalesDisplay(),
          ),

          Positioned(
            left: 16,
            bottom: 400,
            child: Row(
              children: [
                Container(
                  width: 20.8,
                  height: 20.8,
                  decoration: BoxDecoration(
                    color: Color(0xFFfe9603),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '$swiggyPercentage% Swiggy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            bottom: 360,
            child: Row(
              children: [
                Container(
                  width: 20.8,
                  height: 20.8,
                  decoration: BoxDecoration(
                    color: Color(0xFFd5282a),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '$zomatoPercentage% Zomato',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 320,
            child: Row(
              children: [
                Container(
                  width: 20.8,
                  height: 20.8,
                  decoration: BoxDecoration(
                    color: Color(0xFF05C210),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'New 1',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            bottom: 280,
            child: Row(
              children: [
                Container(
                  width: 20.8,
                  height: 20.8,
                  decoration: BoxDecoration(
                    color: Color(0xFF01A5E2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'New 2',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 12,
            bottom: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://cdn.dribbble.com/users/2102703/screenshots/13943094/untitled-6_4x.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Swiggy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 100),
                            Column(
                              children: [
                                SizedBox(height: 20),
                                Text(
                                  swiggySaleAmount,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        Text(
                          '$noOfSwiggyBills Orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Container(
                  width: 7 * 41.8,
                  height: 2,
                  color: Color(0xFFD6D6D6),
                  margin: EdgeInsets.only(left: 15),
                ),
              ],
            ),
          ),
          Positioned(
            left: 25,
            bottom: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/images/ZOMATO.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Zomato',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 100),
                            Column(
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  zomatoSaleAmount,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '$nofzomatobills Orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: 7 * 41.8,
                  height: 2,
                  color: Color(0xFFD6D6D6),
                  margin: EdgeInsets.only(left: 4),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
  double calculateTotal() {
    double cashAmount = double.tryParse(cashSaleAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double cardAmount = double.tryParse(cardSaleAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double upiAmount = double.tryParse(upiSaleAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    return cashAmount + cardAmount  + upiAmount;
  }

  Widget _buildRectangle2Box() {
    double screenWidth = MediaQuery.of(context).size.width;
    double rectangleWidth = screenWidth - (2 * 20);
    double heightInPixels = 10 * 37.8;
    double innerRectangleHeight = 2 * 37.8;
    double thickLineHeight = 6.0;
    double lineWidth = 100;

    return Container(
      width: rectangleWidth,
      height: heightInPixels,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            height: innerRectangleHeight,
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: EdgeInsets.only(left: 15, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Payment Detail',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 70),
                Text(
                  'Rs ${calculateTotal().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Cash', lineWidth, thickLineHeight, Color(0xFFCA31E4), 0.4, 'Rs $cashSaleAmount'),
                _buildDivider(),
                _buildRow('Card', lineWidth, thickLineHeight, Color(0xFFFE9603), 0.6, 'Rs $cardSaleAmount'),
                _buildDivider(),
                _buildRow('Online', lineWidth, thickLineHeight, Color(0xFF01A7E3), 0.7, 'Rs $upiSaleAmount'),
                _buildDivider(),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRow(String title, double lineWidth, double lineHeight, Color color, double fillPercentage, String amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ),

        Row(
          children: [
            Container(
              width: lineWidth * fillPercentage,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
              ),
            ),
            Container(
              width: lineWidth * (1 - fillPercentage),
              height: lineHeight,
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
              ),
            ),
          ],
        ),
        SizedBox(width: 20),
        Text(
          amount,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 1),
      child: Divider(thickness: 1, color: Colors.grey[300]),
    );
  }

  Widget _buildDeliveryBox(String deliverySales, String deliveryBills) {
    return Container(
      height: 100,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFFFFBF2),
        border: Border.all(color: Color(0xFFFD9500), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery',
                  style: TextStyle(
                    color: Color(0xFFFD9500),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Delivery icon
                Container(
                  width: 32, // Icon width
                  height: 32, // Icon height
                  margin: EdgeInsets.only(top: 4, right: 6),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/128/5637/5637217.png',
                    color: Color(0xFFFD9500),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$deliveryBills Orders',
              style: TextStyle(
                color: Color(0xFFFD9500),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              deliverySales,
              style: TextStyle(
                color: Color(0xFFFD9500),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTakeawayBox(String takeawaySales, String takeawayBills) {
    return Container(
      height: 100,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFECF9FF),
        border: Border.all(color: Color(0xFF79C8E3), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Takeaway',
                  style: TextStyle(
                    color: Color(0xFF01A7E3),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(top: 5, right: 1),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/128/3272/3272689.png',
                    color: Color(0xFF01A7E3),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$takeawayBills Orders',
              style: TextStyle(
                color: Color(0xFF01A7E3),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              takeawaySales,
              style: TextStyle(
                color: Color(0xFF01A7E3),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDineInBox(String dineinSales, String dineInBills) {
    return Container(
      height: 100,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFFEF9FF),
        border: Border.all(color: Color(0xFFBDA4D7), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dine-In',
                  style: TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  width: 32,
                  height: 32,
                  margin: EdgeInsets.only(top: 4, right: 6),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/128/3567/3567197.png',
                    color: Color(0xFF6A1B9A),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$dineInBills Orders',
              style: TextStyle(
                color: Color(0xFF6A1B9A),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              dineinSales,
              style: TextStyle(
                color: Color(0xFF6A1B9A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOnlineOrdersDisplay() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 220, top: 15),
        child: Text(
          totalOnlineOrders.replaceAll('(', '').replaceAll(')', ''),
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
  Widget _buildOnlineSalesDisplay() {
    return Padding(
      padding: const EdgeInsets.only(right: 170, top: 10),
      child: Text(
        onlineSaleAmount,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ChartData {
  final DateTime time;
  final double value;

  _ChartData({required this.time, required this.value});
}
class ConcentricCircles extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {'color': Color(0xFFfe9603), 'percentage': 0.9},
    {'color': Color(0xFFd5282a), 'percentage': 0.8},
    {'color': Color(0xFF05c210), 'percentage': 0.7},
    {'color': Color(0xFF01a5e2), 'percentage': 0.7},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(60, 60),
      painter: CirclePainter(data),
    );
  }
}
class CirclePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  CirclePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double baseRadius = 110;
    double spacing = 1;
    double borderWidth = 15;
    Offset center = Offset(size.width / 2 + 53, size.height / 2 - 80);

    for (int i = 0; i < data.length; i++) {
      double radius = baseRadius - i * (30 + spacing);
      double fillPercentage = data[i]['percentage'];
      Paint fillPaint = Paint()
        ..color = data[i]['color']
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          1.5 * pi, fillPercentage * 2 * pi, true, fillPaint);

      Paint greyPaint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          1.5 * pi + fillPercentage * 2 * pi,
          (1 - fillPercentage) * 2 * pi, true, greyPaint);

      Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          1.5 * pi, 2 * pi, false, borderPaint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment(-0.5, 0),
            child: Image.asset(
              'assets/images/reddpos.png',
              width: 40,
              height: 40,
            ),
          ),
          SizedBox(width: 70),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFD5282B), width: 1),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text(
                  'All Outlet',
                  style: TextStyle(color: Color(0xFFD5282B), fontSize: 16),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFD5282B),
                ),
              ],
            ),
          ),
          Spacer(),
          SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
            child: Icon(
              Icons.notifications,
              size: 40,
              color: Color(0xFFD5282B),
            ),
          ),
        ],
      ),
    );
  }
}



