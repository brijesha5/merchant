import 'package:flutter/material.dart';
import 'SidePanel.dart';

class RunningOrderPage extends StatefulWidget {
  final Map<String, String> dbToBrandMap;

  const RunningOrderPage({super.key, required this.dbToBrandMap});

  @override
  State<RunningOrderPage> createState() => _RunningOrderPageState();
}

class _RunningOrderPageState extends State<RunningOrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedBrand;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedBrand = "All";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandNames = widget.dbToBrandMap.values.toSet();
    final screenWidth = MediaQuery.of(context).size.width;

    return SidePanel(
      dbToBrandMap: widget.dbToBrandMap,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header Row
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Image.asset(
                      'assets/images/reddpos.png',
                      height: 40,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 120,
                        maxWidth: 200,
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
                            ...brandNames.map(
                                  (brand) => DropdownMenuItem(
                                value: brand,
                                child: Text(
                                  brand,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 56),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.refresh, size: 18, color: Colors.black87),
                        label: const Text(
                          "Refresh",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () {
                          // Refresh logic here
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // TabBar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFD5282B),
                  unselectedLabelColor: Colors.black,
                  indicatorColor: const Color(0xFFD5282B),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: "Running Orders"),
                    Tab(text: "Running Tables"),
                  ],
                ),
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersTab(screenWidth),
                    _buildTablesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab(double screenWidth) {
    // Calculate responsive grid columns
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4; // desktop
    } else if (screenWidth >= 800) {
      crossAxisCount = 3; // tablet
    } else {
      crossAxisCount = 2; // phone
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticky Blue Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F8FE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("Order", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("₹ 0.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid View
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, // reduced height slightly
            children: [
              _orderCard("Dine In", 0, 0.0, subtitle: "Orders / KOTS"),
              _orderCard("Pick Up", 0, 0.0),
              _orderCard("Delivery", 0, 0.0),

            ],
          ),
        ],
      ),
    );
  }

  Widget _orderCard(String title, int orderCount, double amount, {String? subtitle}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            const Text("Orders", style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(
              "$orderCount",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text("Estimated Total", style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(
              "₹ ${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesTab() {
    return const Center(
      child: Text(
        "Running Tables",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
