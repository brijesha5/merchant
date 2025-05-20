import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'SidePanel.dart';
import 'main.dart';
import 'package:merchant/TotalSalesReport.dart';
import 'package:merchant/TotalSalesReport.dart';

class Dashboard extends ConsumerStatefulWidget {
  final Map<String, String> dbToBrandMap;

  const Dashboard({super.key, required this.dbToBrandMap});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  String? selectedBrand;
  DateTimeRange? selectedDateRange;
  String get selectedDate => selectedDateRange != null
      ? "${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} to ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}"
      : DateFormat('dd-MM-yyyy').format(DateTime.now());
  Map<String, dynamic> apiResponses = {};
  Map<String, TotalSalesReport> totalSalesResponses = {};
  bool isLoading = false;
  String chartType = "Bar Chart"; // or "Line Chart"
  Key chartKey = UniqueKey();

  final String syncText = "Order synced 7 Mins ago & POS synced 2 Mins ago.";


  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    selectedDateRange = DateTimeRange(start: today, end: today);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTotalSales();
    });
  }

  List<Map<String, dynamic>> get summaryTabs {
    // Helper to format amount and orders
    String formatAmount(double value) => "₹ ${value.toStringAsFixed(2)}";
    String formatOrders(int value) => "$value Order${value == 1 ? "" : "s"}";

    if (selectedBrand == null || selectedBrand == "All") {
      // Aggregate for all outlets
      double totalSales = 0, dineIn = 0, takeAway = 0, delivery = 0;
      int totalOrders = 0, dineOrders = 0, takeAwayOrders = 0, deliveryOrders = 0;

      for (final report in totalSalesResponses.values) {
        totalSales   += double.tryParse(report.getField("grandTotal", fallback: "0.00")) ?? 0;
        dineIn       += double.tryParse(report.getField("dineInSales", fallback: "0.00")) ?? 0;
        takeAway     += double.tryParse(report.getField("takeAwaySales", fallback: "0.00")) ?? 0;
        delivery     += double.tryParse(report.getField("homeDeliverySales", fallback: "0.00")) ?? 0;

        // Example: if you have these orders fields in your API/model, use them.
        totalOrders      += int.tryParse(report.getField("totalOrders", fallback: "0")) ?? 0;
        dineOrders       += int.tryParse(report.getField("dineInOrders", fallback: "0")) ?? 0;
        takeAwayOrders   += int.tryParse(report.getField("takeAwayOrders", fallback: "0")) ?? 0;
        deliveryOrders   += int.tryParse(report.getField("homeDeliveryOrders", fallback: "0")) ?? 0;
      }

      return [
        {
          "title": "Total Sales",
          "amount": formatAmount(totalSales),
          "orders": formatOrders(totalOrders),
          "icon": Icons.local_activity,
          "iconColor": Color(0xFFFCA2A2),
        },
        {
          "title": "Dine In",
          "amount": formatAmount(dineIn),
          "orders": formatOrders(dineOrders),
          "icon": Icons.restaurant,
          "iconColor": Color(0xFF93E5F9),
        },
        {
          "title": "TAKE AWAY",
          "amount": formatAmount(takeAway),
          "orders": formatOrders(takeAwayOrders),
          "icon": Icons.local_drink,
          "iconColor": Color(0xFFEEE6FF),
        },
        {
          "title": "Delivery",
          "amount": formatAmount(delivery),
          "orders": formatOrders(deliveryOrders),
          "icon": Icons.delivery_dining,
          "iconColor": Color(0xFFFFE6B9),
        },
      ];
    } else {
      // Single outlet
      final entry = widget.dbToBrandMap.entries.firstWhere(
            (e) => e.value == selectedBrand,
        orElse: () => MapEntry('', ''),
      );
      final dbKey = entry.key.isNotEmpty ? entry.key : null;
      final report = dbKey != null ? totalSalesResponses[dbKey] : null;

      String safeAmount(String? value) => "₹ ${(value != null && value.isNotEmpty) ? value : "0.00"}";
      String safeOrders(String? value) {
        final num = int.tryParse(value ?? "0") ?? 0;
        return "$num Order${num == 1 ? "" : "s"}";
      }

      return [
        {
          "title": "Total Sales",
          "amount": safeAmount(report?.getField("grandTotal")),
          "orders": safeOrders(report?.getField("totalOrders")),
          "icon": Icons.local_activity,
          "iconColor": Color(0xFFFCA2A2),
        },
        {
          "title": "Dine In",
          "amount": safeAmount(report?.getField("dineInSales")),
          "orders": safeOrders(report?.getField("dineInOrders")),
          "icon": Icons.restaurant,
          "iconColor": Color(0xFF93E5F9),
        },
        {
          "title": "TAKE AWAY",
          "amount": safeAmount(report?.getField("takeAwaySales")),
          "orders": safeOrders(report?.getField("takeAwayOrders")),
          "icon": Icons.local_drink,
          "iconColor": Color(0xFFEEE6FF),
        },
        {
          "title": "Delivery",
          "amount": safeAmount(report?.getField("homeDeliverySales")),
          "orders": safeOrders(report?.getField("homeDeliveryOrders")),
          "icon": Icons.delivery_dining,
          "iconColor": Color(0xFFFFE6B9),
        },
      ];
    }
  }

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

  List<Map<String, dynamic>> get paymentBifurcation {
    // Get the correct TotalSalesReport based on selectedBrand
    TotalSalesReport? report;
    if (selectedBrand == null || selectedBrand == "All") {
      report = totalSalesResponses.values.isNotEmpty ? totalSalesResponses.values.first : null;
    } else {
      // FIX: Use a dummy MapEntry for orElse, then check .key
      final entry = widget.dbToBrandMap.entries.firstWhere(
            (e) => e.value == selectedBrand,
        orElse: () => MapEntry('', ''),
      );
      final dbKey = entry.key.isNotEmpty ? entry.key : null;
      report = dbKey != null ? totalSalesResponses[dbKey] : null;
    }

    String safeAmount(String? value) => "₹ ${(value != null && value.isNotEmpty) ? value : "0.00"}";

    return [
      {
        "color": Colors.amber,
        "label": "Cash",
        "value": safeAmount(report?.getField("cashSales")),
      },
      {
        "color": Colors.cyan,
        "label": "Card",
        "value": safeAmount(report?.getField("cardSales")),
      },
      {
        "color": Color(0xFF4886FF),
        "label": "UPI",
        "value": safeAmount(report?.getField("upiSales")),
      },
      {
        "color": Colors.green,
        "label": "Other",
        "value": safeAmount(report?.getField("othersSales")),
      },
    ];
  }
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

    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTotalSales() async {
    setState(() {
      isLoading = true;
      totalSalesResponses = {};
    });

    final config = await Config.loadFromAsset();
    String startDate = DateFormat('dd-MM-yyyy').format(selectedDateRange!.start);
    String endDate = DateFormat('dd-MM-yyyy').format(selectedDateRange!.end);

    List<String> dbs;
    if (selectedBrand == null || selectedBrand == "All") {
      dbs = widget.dbToBrandMap.keys.toList();
    } else {
      dbs = widget.dbToBrandMap.entries
          .where((entry) => entry.value == selectedBrand)
          .map((entry) => entry.key)
          .toList();
    }

    // <<<----  ONLY CALL THE MAIN API LOGIC ---->>>
    totalSalesResponses = await UserData.fetchTotalSalesForDbs(
      config,
      dbs,
      startDate,
      endDate,
    );

    setState(() {
      isLoading = false;
    });
  }

  String getField(String key, {String fallback = "0.00"}) {
    // For ALL: only one merged response (key = 'ALL'), else per DB
    if (selectedBrand == null || selectedBrand == "All") {
      if (totalSalesResponses.isEmpty) return fallback;
      final report = totalSalesResponses.entries.isNotEmpty ? totalSalesResponses.entries.first.value : null;
      if (report == null) return fallback;
      return report.getField(key, fallback: fallback);
    } else {
      // get only selected DB's value
      final dbKey = widget.dbToBrandMap.entries.firstWhere((e) => e.value == selectedBrand).key;
      final report = totalSalesResponses[dbKey];
      if (report == null) return fallback;
      return report.getField(key, fallback: fallback);
    }
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
                      onChanged: (value) async {
                        setState(() {
                          selectedBrand = value;
                        });
                        final startDate = selectedDateRange != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)
                            : DateFormat('dd-MM-yyyy').format(DateTime.now());
                        final endDate = selectedDateRange != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)
                            : DateFormat('dd-MM-yyyy').format(DateTime.now());
                        await fetchTotalSales();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  label: Text(selectedDate, style: const TextStyle(color: Colors.black87)),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: selectedDateRange,
                      firstDate: DateTime(2021),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDateRange = picked;
                      });
                      await fetchTotalSales(

                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Fetch Sales"),
                  onPressed: () async {
                    final startDate = selectedDateRange != null
                        ? DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)
                        : DateFormat('dd-MM-yyyy').format(DateTime.now());
                    final endDate = selectedDateRange != null
                        ? DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)
                        : DateFormat('dd-MM-yyyy').format(DateTime.now());
                    await fetchTotalSales();                  },
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
                        child: buildSummaryTabs(isMobile),
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
                                      onPressed: () {},
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
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, box) {
                                    double totalWidth = min(320.0, box.maxWidth - 20);
                                    double barHeight = isMobile ? 24 : 28;

                                    // Parse values from paymentBifurcation
                                    List<double> values = paymentBifurcation
                                        .map((p) => double.tryParse(p["value"].toString().replaceAll("₹", "").replaceAll(",", "").trim()) ?? 0)
                                        .toList();
                                    double total = values.fold(0.0, (a, b) => a + b);

                                    // Calculate widths
                                    List<double> widths = total > 0
                                        ? values.map((v) => totalWidth * (v / total)).toList()
                                        : List.filled(values.length, totalWidth / values.length);

                                    // Optional: show % value over the biggest section (UPI in your case)
                                    int maxIdx = values.indexOf(values.reduce(max));
                                    String percentText = total > 0 ? "100%" : "";

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
                                              children: List.generate(paymentBifurcation.length, (i) {
                                                return Container(
                                                  width: widths[i],
                                                  height: barHeight,
                                                  decoration: BoxDecoration(
                                                    color: paymentBifurcation[i]["color"],
                                                    borderRadius: BorderRadius.horizontal(
                                                      left: i == 0 ? Radius.circular(barHeight / 2) : Radius.zero,
                                                      right: i == paymentBifurcation.length - 1 ? Radius.circular(barHeight / 2) : Radius.zero,
                                                    ),
                                                  ),
                                                  child: (i == maxIdx && total > 0)
                                                      ? Center(
                                                    child: Text(
                                                      percentText,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                      : null,
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
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
                        // Use stats.length, not _stats.length!
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final stat = stats[index];
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
                                      Icon(stat["icon"], color: stat["iconColor"], size: isMobile ? 20 : 24),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    stat["amount"]!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Remove description if not used in your getter
                                  // const SizedBox(height: 5),
                                  // Text(
                                  //   stat["description"]!,
                                  //   style: TextStyle(
                                  //     fontSize: isMobile ? 10 : 12,
                                  //     color: Colors.grey,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    if (selectedBrand == null || selectedBrand == "All") ...[
                      const SizedBox(height: 20),
                      _buildOutletwiseStatisticsTable(context, isMobile: isMobile),
                    ],
                    const SizedBox(height: 20),
                    // Example: Show total sales API response
                    if (totalSalesResponses.isNotEmpty)
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total Sales API Result", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              for (final entry in totalSalesResponses.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text("${entry.key}: ${entry.value.totalSales}"),
                                ),
                            ],
                          ),
                        ),
                      ),
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

  Widget buildSummaryTabs(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          child: Column(
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
    );
  }

  List<Map<String, dynamic>> get stats => [
    {
      "title": "Total Salessssss",
      "amount": "₹ ${getField("grandTotal", fallback: "0.00")}",
      "orders": "Occupied: ${getField("occupiedTableCount", fallback: "0")}",
      "icon": Icons.bar_chart,
      "iconColor": const Color(0xFFFCA2A2),
    },
    {
      "title": "Dine In",
      "amount": "₹ ${getField("dineInSales", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.restaurant,
      "iconColor": const Color(0xFF93E5F9),
    },
    {
      "title": "TAKE AWAY",
      "amount": "₹ ${getField("takeAwaySales", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.local_drink,
      "iconColor": const Color(0xFFEEE6FF),
    },
    {
      "title": "Delivery",
      "amount": "₹ ${getField("homeDeliverySales", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.delivery_dining,
      "iconColor": const Color(0xFFFFE6B9),
    },
    {
      "title": "Online",
      "amount": "₹ ${getField("onlineSales", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.shopping_cart,
      "iconColor": Colors.blue[100],
    },
    {
      "title": "Net Sales",
      "amount": "₹ ${getField("netTotal", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.show_chart,
      "iconColor": Colors.orange[100],
    },
    {
      "title": "Discounts",
      "amount": "₹ ${getField("billDiscount", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.discount,
      "iconColor": Colors.green[100],
    },
    {
      "title": "Taxes",
      "amount": "₹ ${getField("billTax", fallback: "0.00")}",
      "orders": "",
      "icon": Icons.account_balance,
      "iconColor": Colors.purple[100],
    },
  ];
  Widget _legendDot(Color color) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildOutletwiseStatisticsTable(BuildContext context, {required bool isMobile}) {
    // Build a list from dbToBrandMap and totalSalesResponses, one entry for each outlet
    final outlets = <Map<String, String>>[];

    // Determine the "Total" row (all outlets merged)
    String totalOrders = getField("occupiedTableCount", fallback: "0");
    String totalSales = getField("grandTotal", fallback: "0.00");
    String totalNetSales = getField("netTotal", fallback: "0.00");
    String totalTax = getField("billTax", fallback: "0.00");
    String totalDiscount = getField("billDiscount", fallback: "0.00");

    outlets.add({
      "Outlet Name": "Total",
      "Orders": totalOrders,
      "Sales": totalSales,
      "Net Sales": totalNetSales,
      "Tax": totalTax,
      "Discount": totalDiscount,
    });

    print("Total Sales (All Outlets): $totalSales");

    // Individual outlets
    widget.dbToBrandMap.forEach((dbKey, outletName) {
      final report = totalSalesResponses[dbKey];
      final outletOrders = report?.getField("occupiedTableCount", fallback: "0") ?? "0";
      final outletSales = report?.getField("grandTotal", fallback: "0.00") ?? "0.00";
      final outletNetSales = report?.getField("netTotal", fallback: "0.00") ?? "0.00";
      final outletTax = report?.getField("billTax", fallback: "0.00") ?? "0.00";
      final outletDiscount = report?.getField("billDiscount", fallback: "0.00") ?? "0.00";

      outlets.add({
        "Outlet Name": outletName,
        "Orders": outletOrders,
        "Sales": outletSales,
        "Net Sales": outletNetSales,
        "Tax": outletTax,
        "Discount": outletDiscount,
      });

      print("Sales for $outletName: $outletSales");
    });

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
                  label: Text(
                    key,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 14,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ))
                    .toList(),
                rows: outlets
                    .map(
                      (outlet) => DataRow(
                    cells: outlet.values
                        .map(
                          (value) => DataCell(
                        SizedBox(
                          width: isMobile ? 90 : 135,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: isMobile ? 10 : 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )
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
  }}

// Dummy chart widgets for code completeness.
class ChartBarData {
  final String label;
  final int dineIn;
  final int takeAway;
  final int delivery;
  ChartBarData(this.label, this.dineIn, this.takeAway, this.delivery);
}
class ChartLineData {
  final String label;
  final List<int> values;
  ChartLineData(this.label, this.values);
}
class _SalesBarChartWidget extends StatelessWidget {
  final List<ChartBarData> data;
  const _SalesBarChartWidget({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Container(height: 120, color: Colors.transparent, child: Center(child: Text("Bar Chart Placeholder")));
}
class _SalesLineChartWidget extends StatelessWidget {
  final List<ChartLineData> data;
  const _SalesLineChartWidget({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Container(height: 120, color: Colors.transparent, child: Center(child: Text("Line Chart Placeholder")));
}
