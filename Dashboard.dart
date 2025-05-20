import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'SidePanel.dart';
import 'main.dart';

class Dashboard extends ConsumerStatefulWidget {
  final Map<String, String> dbToBrandMap;

  const Dashboard({super.key, required this.dbToBrandMap});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  String? selectedBrand;
  String selectedDate = DateFormat('d MMM').format(DateTime.now());
  Map<String, dynamic> apiResponses = {};
  bool isLoading = false;
  String chartType = "Bar Chart"; // or "Line Chart"
  Key chartKey = UniqueKey();

  final String syncText = "Order synced 7 Mins ago & POS synced 2 Mins ago.";
  final List<Map<String, dynamic>> summaryTabs = [
    {
      "title": "Total Sales",
      "amount": "₹ 9,559",
      "orders": "12 Orders",
      "icon": Icons.local_activity,
      "iconColor": Color(0xFFFCA2A2),
    },
    {
      "title": "Dine In",
      "amount": "₹ 0",
      "orders": "0 Order",
      "icon": Icons.restaurant,
      "iconColor": Color(0xFF93E5F9),
    },
    {
      "title": "TAKE AWAY",
      "amount": "₹ 0",
      "orders": "0 Order",
      "icon": Icons.local_drink,
      "iconColor": Color(0xFFEEE6FF),
    },
    {
      "title": "Delivery",
      "amount": "₹ 9,559",
      "orders": "12 Orders",
      "icon": Icons.delivery_dining,
      "iconColor": Color(0xFFFFE6B9),
    },
  ];

  final List<ChartBarData> barData = [
    ChartBarData("03:00am - 07:00am", 0, 0, 0),
    ChartBarData("07:00am - 11:00am", 0, 0, 0),
    ChartBarData("11:00am - 03:00pm", 0, 0, 5416),
    ChartBarData("03:00pm - 07:00pm", 0, 0, 0),
    ChartBarData("07:00pm - 11:00pm", 0, 0, 4143),
    ChartBarData("11:00pm - 03:00am", 0, 0, 0),
  ];

  final List<ChartLineData> lineData = [
    ChartLineData("03:00am - 07:00am", [0, 0, 0]),
    ChartLineData("07:00am - 11:00am", [0, 0, 0]),
    ChartLineData("11:00am - 03:00pm", [0, 0, 5416]),
    ChartLineData("03:00pm - 07:00pm", [0, 0, 0]),
    ChartLineData("07:00pm - 11:00pm", [0, 0, 4143]),
    ChartLineData("11:00pm - 03:00am", [0, 0, 0]),
  ];

  final List<Map<String, dynamic>> onlineOrderChannels = [
    {
      "icon": "assets/images/zomato.png",
      "name": "Zomato",
      "amount": "₹ 7,363",
      "orders": "9",
      "brands": "2",
      "active": true,
    },
    {
      "icon": "assets/images/swiggy.png",
      "name": "Swiggy",
      "amount": "₹ 2,196",
      "orders": "3",
      "brands": "2",
      "active": true,
    },

  ];

  final List<Map<String, dynamic>> paymentBifurcation = [
    {"color": Colors.amber, "label": "Cash", "value": "₹ 0"},
    {"color": Colors.cyan, "label": "Card", "value": "₹ 0"},
    {"color": Color(0xFF4886FF), "label": "Online", "value": "₹ 9,559"},
    {"color": Colors.green, "label": "Additional", "value": "₹ 0"},
  ];

  Future<void> fetchData({bool reset = false}) async {
    if (reset) {
      setState(() {
        apiResponses = {};
      });
    }
    setState(() {
      isLoading = true;
    });

    final config = await Config.loadFromAsset();
    final apiUrl = config.apiUrl;

    for (final dbName in widget.dbToBrandMap.keys) {
      final brandName = widget.dbToBrandMap[dbName];

      if (selectedBrand != null &&
          selectedBrand != "All" &&
          brandName != selectedBrand) {
        continue;
      }

      final url = "$apiUrl/report/daywise?DB=$dbName";
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          setState(() {
            apiResponses[dbName] = json.decode(response.body);
          });
        } else {
          setState(() {
            apiResponses[dbName] = {"error": "Status code ${response.statusCode}"};
          });
        }
      } catch (e) {
        setState(() {
          apiResponses[dbName] = {"error": e.toString()};
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandNames = widget.dbToBrandMap.values.toSet();
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isMobile = size.width < 600;

    return SidePanel(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Container(
            color: Colors.white,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/reddpos.png',
                  height: isMobile ? 32 : 40,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: isMobile ? 70 : 100,
                    maxWidth: isMobile ? 180 : 260,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedBrand,
                      hint: const Text(
                        "All Outlets",
                        style: TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: "All",
                          child: Text("All Outlets"),
                        ),
                        ...brandNames.map((brand) => DropdownMenuItem(
                          value: brand,
                          child: Text(
                            brand,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedBrand = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int gridCol = width > 1200
                  ? 4
                  : width > 900
                  ? 3
                  : width > 600
                  ? 2
                  : 1;
              final double aspect = width < 400
                  ? 1.4
                  : width < 600
                  ? 1.7
                  : 2.1;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 8 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Brand specific summary bar (show only if selectedBrand != null && selectedBrand != "All") ---
                    if (selectedBrand != null && selectedBrand != "All")
                      Padding(
                        padding: EdgeInsets.only(bottom: isMobile ? 10 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sync info and refresh+date
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 12 : 16,
                                  horizontal: isMobile ? 10 : 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Flex(
                                direction: isMobile ? Axis.vertical : Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: isMobile ? 17 : 20, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        syncText,
                                        style: TextStyle(
                                          fontSize: isMobile ? 13 : 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10, width: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: isMobile ? 36 : 38,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: Size(isMobile ? 90 : 100, 36),
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              chartKey = UniqueKey();
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('d MMM').format(DateTime.now()),
                                                style: TextStyle(
                                                  fontSize: isMobile ? 13 : 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              const Icon(Icons.refresh, size: 18, color: Colors.black54),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Summary Tabs with increased height
                            LayoutBuilder(
                              builder: (context, box) {
                                int tabCount = box.maxWidth < 400 ? 1 : box.maxWidth < 800 ? 2 : 4;
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: tabCount,
                                  crossAxisSpacing: isMobile ? 8 : 18,
                                  mainAxisSpacing: isMobile ? 8 : 18,
                                  childAspectRatio: isMobile ? 1.1 : 1.8,

                                  children: summaryTabs.map((tab) {
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 8 : 18, vertical: isMobile ? 16 : 24),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                        Expanded(
                                        child:
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(tab["title"],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: isMobile ? 13 : 17,
                                                        color: Colors.black87)),
                                                const SizedBox(height: 8),
                                                Text(tab["amount"],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: isMobile ? 19 : 22,
                                                        color: Colors.black87)),
                                                const SizedBox(height: 4),
                                                Text(tab["orders"],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: isMobile ? 12 : 14,
                                                        color: Colors.grey[700])),
                                              ],
                                            ),
                                        ),

                                            Container(
                                              decoration: BoxDecoration(
                                                color: tab["iconColor"] as Color?,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(isMobile ? 10 : 16),
                                              child: Icon(tab["icon"], color: Colors.black54, size: isMobile ? 28 : 38),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    // --- Sales Chart Section ---
                    if (selectedBrand != null && selectedBrand != "All")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 24,
                                vertical: isMobile ? 12 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Sales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const Spacer(),
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: chartType,
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                          style: TextStyle(fontSize: 15, color: Colors.black87),
                                          borderRadius: BorderRadius.circular(8),
                                          items: [
                                            DropdownMenuItem(
                                              value: "Bar Chart",
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.bar_chart, size: 18, color: Colors.black54),
                                                  SizedBox(width: 4),
                                                  Text("Bar Chart"),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "Line Chart",
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.show_chart, size: 18, color: Colors.black54),
                                                  SizedBox(width: 4),
                                                  Text("Line Chart"),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => setState(() => chartType = v!),
                                        ),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                      label: Text(selectedDate, style: const TextStyle(color: Colors.black87)),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                        side: const BorderSide(color: Color(0xFFD5282B)),
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.black54),
                                      onPressed: () {
                                        setState(() {
                                          chartKey = UniqueKey();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 7.0),
                                  child: Row(
                                    children: [
                                      _legendDot(Colors.blue),
                                      const SizedBox(width: 4),
                                      const Text("Dine In", style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 14),
                                      _legendDot(Colors.cyan[400]!),
                                      const SizedBox(width: 4),
                                      const Text("TAKE AWAY", style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 14),
                                      _legendDot(Colors.green[700]!),
                                      const SizedBox(width: 4),
                                      const Text("Delivery", style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: chartType == "Bar Chart"
                                      ? _SalesBarChartWidget(data: barData, key: chartKey)
                                      : _SalesLineChartWidget(data: lineData, key: chartKey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // --- End chart section ---

                    // --- Online Orders Channel Grid ---
                    if (selectedBrand != null && selectedBrand != "All")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 24,
                                vertical: isMobile ? 14 : 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Online Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                      label: Text(selectedDate, style: const TextStyle(color: Colors.black87)),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                        side: const BorderSide(color: Color(0xFFD5282B)),
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.black54),
                                      onPressed: () {
                                        // refresh logic
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text("Total Sales", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 17)),
                                    ),
                                    Expanded(
                                      child: Text("Total Orders", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 17)),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text("₹ 9,559", style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: Text("12", style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold)),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Channel Cards (SCROLLABLE and responsive)
                                SizedBox(
                                  height: isMobile ? 130 : 140,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: onlineOrderChannels.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final channel = onlineOrderChannels[index];
                                      return Container(
                                        width: isMobile ? 180 : 220,
                                        padding: EdgeInsets.all(isMobile ? 10 : 18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: channel["active"] ? Colors.grey[300]! : Colors.grey[200]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(channel["icon"], width: 30, height: 30),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    channel["name"],
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: isMobile ? 15 : 17,
                                                        color: Colors.black87),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(channel["amount"], style: TextStyle(fontSize: isMobile ? 17 : 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text("Orders: ${channel["orders"]}", style: TextStyle(fontSize: 12)),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text("Brands: ${channel["brands"]}", style: TextStyle(fontSize: 12)),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // --- Payment Bifurcation Section ---
                    if (selectedBrand != null && selectedBrand != "All")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 24,
                                vertical: isMobile ? 14 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Payment Bifurcation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                      label: Text(selectedDate, style: const TextStyle(color: Colors.black87)),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                        side: const BorderSide(color: Color(0xFFD5282B)),
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.black54),
                                      onPressed: () {
                                        // refresh logic
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Responsive payment bar
                                LayoutBuilder(
                                  builder: (context, box) {
                                    double totalWidth = min(320.0, box.maxWidth - 20);
                                    double barHeight = isMobile ? 24 : 28;
                                    return Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: totalWidth,
                                            height: barHeight,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(barHeight / 2),
                                              color: Colors.grey[100],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: totalWidth * 0.08,
                                                  height: barHeight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(barHeight / 2),
                                                      bottomLeft: Radius.circular(barHeight / 2),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: totalWidth * 0.08,
                                                  height: barHeight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                Container(
                                                  width: totalWidth * 0.68,
                                                  height: barHeight,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4886FF),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "100%",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: totalWidth * 0.08,
                                                  height: barHeight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(barHeight / 2),
                                                      bottomRight: Radius.circular(barHeight / 2),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Payment legends and values
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: paymentBifurcation.map((p) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: p["color"],
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              p["label"],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: isMobile ? 14 : 15,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            p["value"],
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Statistics Grid (unchanged) shown only for "All"
                    if (selectedBrand == null || selectedBrand == "All")
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCol,
                          crossAxisSpacing: isMobile ? 8 : 14,
                          mainAxisSpacing: isMobile ? 8 : 14,
                          childAspectRatio: aspect,
                        ),
                        itemCount: _stats.length,
                        itemBuilder: (context, index) {
                          final stat = _stats[index];
                          return Card(
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 8 : 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          stat["title"]!,
                                          style: TextStyle(
                                            fontSize: isMobile ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Icon(stat["icon"], color: stat["color"], size: isMobile ? 20 : 24),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    stat["value"]!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    stat["description"]!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 12,
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    // Outletwise Table: only in "All" mode
                    if (selectedBrand == null || selectedBrand == "All") ...[
                      const SizedBox(height: 20),
                      _buildOutletwiseStatisticsTable(context, isMobile: isMobile),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
      dbToBrandMap: widget.dbToBrandMap,
    );
  }

  static final List<Map<String, dynamic>> _stats = [
    {
      "title": "Total Sales",
      "value": "4,679.00",
      "description": "Total Sales of 2 outlets",
      "icon": Icons.bar_chart,
      "color": Colors.red
    },
    {
      "title": "Net Sales",
      "value": "4,678.05",
      "description": "Net Sales of 2 outlets",
      "icon": Icons.show_chart,
      "color": Colors.orange
    },
    {
      "title": "No. of Orders",
      "value": "5",
      "description": "No. of invoices generated",
      "icon": Icons.receipt,
      "color": Colors.blue
    },
    {
      "title": "Expenses",
      "value": "0.00",
      "description": "Expenses recorded",
      "icon": Icons.money_off,
      "color": Colors.purple
    },
    {
      "title": "Cash Collection",
      "value": "0.00",
      "description": "0% of sales collected via cash",
      "icon": Icons.money,
      "color": Colors.green
    },
    {
      "title": "Online Sales",
      "value": "4,679.00",
      "description": "100% of sales generated from Online",
      "icon": Icons.shopping_cart,
      "color": Colors.blue
    },
    {
      "title": "Taxes",
      "value": "0.00",
      "description": "Taxes recorded on POS",
      "icon": Icons.account_balance,
      "color": Colors.purple
    },
    {
      "title": "Discounts",
      "value": "311.99",
      "description": "6.25% of My Amount",
      "icon": Icons.discount,
      "color": Colors.green
    },
  ];

  Widget _legendDot(Color color) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildOutletwiseStatisticsTable(BuildContext context, {required bool isMobile}) {
    final outlets = [
      {
        "Outlet Name": "Total",
        "Orders": "5",
        "Sales": "4,679.00",
        "Net Sales": "4,678.05",
        "Tax": "0.00",
        "Discount": "311.99",
      },
      {
        "Outlet Name": "Aavakay - The Andhra Kitchen & Bar",
        "Orders": "0",
        "Sales": "0.00",
        "Net Sales": "0.00",
        "Tax": "0.00",
        "Discount": "0.00",
      },
      {
        "Outlet Name": "Ebony//The Flip Bar",
        "Orders": "5",
        "Sales": "4,679.00",
        "Net Sales": "4,678.05",
        "Tax": "0.00",
        "Discount": "311.99",
      },
    ];

    return Card(
      elevation: 2,
      color: Colors.white,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Outlet Wise Statistics",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isMobile ? 500 : 0,
              ),
              child: DataTable(
                columnSpacing: isMobile ? 8 : 18,
                headingRowHeight: isMobile ? 34 : 44,
                dataRowHeight: isMobile ? 34 : 48,
                columns: outlets.first.keys
                    .map((key) => DataColumn(
                  label: Text(key,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 14,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      )),
                ))
                    .toList(),
                rows: outlets
                    .map(
                      (outlet) => DataRow(
                    cells: outlet.values
                        .map((value) => DataCell(
                      SizedBox(
                        width: isMobile ? 90 : 135,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 14,
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Chart Data Models and Widgets ---

class ChartBarData {
  final String label;
  final int dineIn;
  final int takeAway;
  final int delivery;
  ChartBarData(this.label, this.dineIn, this.takeAway, this.delivery);
}

class ChartLineData {
  final String label;
  final List<int> values; // [dineIn, takeAway, delivery]
  ChartLineData(this.label, this.values);
}

class _SalesBarChartWidget extends StatelessWidget {
  final List<ChartBarData> data;
  const _SalesBarChartWidget({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    int maxVal = data.fold(0, (pv, e) => [e.dineIn, e.takeAway, e.delivery, pv].reduce((a, b) => a > b ? a : b));
    if (maxVal == 0) maxVal = 1;
    return SizedBox(
      height: isMobile ? 180 : 260,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 12 : 18, top: isMobile ? 8 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((e) {
            final deliveryHeight = (e.delivery / maxVal) * (isMobile ? 120 : 180);
            // Only delivery bars shown as per your screenshot
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    e.delivery > 0 ? "₹ ${e.delivery}" : "",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 11 : 13,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: isMobile ? 18 : 28,
                    height: deliveryHeight,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: isMobile ? 9 : 12, color: Colors.black87),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SalesLineChartWidget extends StatefulWidget {
  final List<ChartLineData> data;
  const _SalesLineChartWidget({required this.data, Key? key}) : super(key: key);

  @override
  State<_SalesLineChartWidget> createState() => _SalesLineChartWidgetState();
}

class _SalesLineChartWidgetState extends State<_SalesLineChartWidget> {
  int? tappedIndex;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final double chartHeight = isMobile ? 180 : 260;
    final double chartWidth = MediaQuery.of(context).size.width - (isMobile ? 40 : 80);

    int maxY = widget.data.expand((d) => d.values).fold(0, (pv, v) => v > pv ? v : pv);
    if (maxY < 1) maxY = 6000;
    final points = widget.data;

    double dx(int i) => (chartWidth / (points.length - 1)) * i;
    double dy(int v) => chartHeight - (v / maxY * (chartHeight - 40)) - 20;
    final linePoints = List.generate(points.length, (i) => Offset(dx(i), dy(points[i].values[2])));

    return SizedBox(
      height: chartHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 18,
            child: Column(
              children: List.generate(4, (i) {
                final y = maxY - (maxY ~/ 3) * i;
                return SizedBox(
                  height: (chartHeight - 40) / 3,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("${(y / 1000).toStringAsFixed(0)}k",
                      style: TextStyle(fontSize: isMobile ? 10 : 14, color: Colors.grey),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Chart lines and points
          Positioned(
            left: 34,
            right: 12,
            top: 0,
            bottom: 28,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                final x = details.localPosition.dx;
                final idx = ((x / (chartWidth - 46)) * (points.length - 1)).round().clamp(0, points.length - 1);
                setState(() {
                  tappedIndex = idx;
                });
              },
              child: CustomPaint(
                painter: _CurvedLineChartPainter(
                  points: linePoints.map((p) => Offset(p.dx + 20, p.dy)).toList(),
                  highlightIndex: tappedIndex,
                  highlightColor: Colors.blue,
                ),
                child: Container(),
              ),
            ),
          ),
          // X axis labels
          Positioned(
            left: 34,
            right: 12,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points.map((e) => SizedBox(
                width: 55,
                child: Text(
                  e.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 10 : 13, color: Colors.grey[800]),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
            ),
          ),
          // Highlight popup
          if (tappedIndex != null)
            Positioned(
              left: 34 + linePoints[tappedIndex!].dx - 60,
              top: linePoints[tappedIndex!].dy - 60,
              child: Material(
                elevation: 7,
                color: Colors.transparent,
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    )],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(points[tappedIndex!].label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Dine In : ₹ ${points[tappedIndex!].values[0]}"),
                      Text("TAKE AWAY : ₹ ${points[tappedIndex!].values[1]}"),
                      Text("Delivery : ₹ ${points[tappedIndex!].values[2]}"),
                      Text("Total : ₹ ${points[tappedIndex!].values.reduce((a, b) => a + b)}"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurvedLineChartPainter extends CustomPainter {
  final List<Offset> points;
  final int? highlightIndex;
  final Color highlightColor;
  _CurvedLineChartPainter({required this.points, this.highlightIndex, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Curved line with cubic bezier
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final controlPointX = (p1.dx + p2.dx) / 2;
        path.cubicTo(
          controlPointX, p1.dy,
          controlPointX, p2.dy,
          p2.dx, p2.dy,
        );
      }
      canvas.drawPath(path, paint);
    }
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, Paint()..color = Colors.white..strokeWidth=2..style=PaintingStyle.fill);
      canvas.drawCircle(points[i], 4, Paint()..color = Colors.blue);
    }
    if (highlightIndex != null) {
      canvas.drawCircle(points[highlightIndex!], 9, Paint()
        ..color = highlightColor.withOpacity(0.13)
        ..style = PaintingStyle.fill);
      canvas.drawCircle(points[highlightIndex!], 7, Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}