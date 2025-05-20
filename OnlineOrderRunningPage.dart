import 'package:flutter/material.dart';
import 'SidePanel.dart';

// --- BAR CHART WIDGET ---
class SimpleBarChart extends StatelessWidget {
  final bool isMobile;
  const SimpleBarChart({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Example data for the last 5 days for Zomato, Swiggy, Magicpin
    final List<String> days = ["14-May", "15-May", "16-May", "17-May", "18-May"];
    final List<int> zomato = [0, 0, 8, 12, 7];
    final List<int> swiggy = [0, 0, 6, 9, 3];
    final List<int> magicpin = [0, 0, 0, 0, 0];

    // Calculate max value for bar scaling
    final maxY = [
      ...zomato,
      ...swiggy,
      ...magicpin,
    ].reduce((a, b) => a > b ? a : b);

    final double barWidth = isMobile ? 10 : 18;
    final double groupWidth = barWidth * 3 + (isMobile ? 7 : 12);

    return Container(
      height: isMobile ? 140 : 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.only(
        left: isMobile ? 8 : 22,
        right: isMobile ? 8 : 22,
        top: isMobile ? 6 : 18,
        bottom: isMobile ? 12 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight - (isMobile ? 20 : 40);
                return CustomPaint(
                  size: Size(constraints.maxWidth, chartHeight),
                  painter: _BarChartPainter(
                    days: days,
                    zomato: zomato,
                    swiggy: swiggy,
                    magicpin: magicpin,
                    barWidth: barWidth,
                    groupWidth: groupWidth,
                    maxY: maxY > 0 ? maxY.toDouble() : 1,
                    isMobile: isMobile,
                  ),
                );
              },
            ),
          ),
          // X Axis labels
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 2 : 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 13,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Legend
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 4 : 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(color: const Color(0xFFC8102E)), // Zomato red
                SizedBox(width: isMobile ? 2 : 7),
                Text("Zomato", style: TextStyle(fontSize: isMobile ? 10 : 13)),
                SizedBox(width: isMobile ? 14 : 22),
                _legendDot(color: const Color(0xFFFF8C1A)), // Swiggy orange
                SizedBox(width: isMobile ? 2 : 7),
                Text("Swiggy", style: TextStyle(fontSize: isMobile ? 10 : 13)),
                SizedBox(width: isMobile ? 14 : 22),
                _legendDot(color: const Color(0xFF4A90E2)), // Magicpin blue
                SizedBox(width: isMobile ? 2 : 7),
                Text("Magicpin", style: TextStyle(fontSize: isMobile ? 10 : 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot({required Color color}) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> days;
  final List<int> zomato, swiggy, magicpin;
  final double barWidth, groupWidth, maxY;
  final bool isMobile;

  _BarChartPainter({
    required this.days,
    required this.zomato,
    required this.swiggy,
    required this.magicpin,
    required this.barWidth,
    required this.groupWidth,
    required this.maxY,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height;
    final Paint axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;

    // Draw horizontal axis (bottom)
    canvas.drawLine(
      Offset(0, chartHeight - 1),
      Offset(size.width, chartHeight - 1),
      axisPaint,
    );

    // Draw horizontal grid lines (2 for 3 ticks)
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    for (int i = 1; i <= 2; i++) {
      final y = chartHeight - (chartHeight * i / 3);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final double leftPad = isMobile ? 2 : 8;
    final barSpacing = isMobile ? 6.0 : 11.0;
    final groupSpace = (size.width - groupWidth * days.length) / (days.length + 1);

    double x = groupSpace / 2;

    for (int i = 0; i < days.length; i++) {
      // Zomato (red)
      _drawBar(
        canvas,
        x + leftPad,
        chartHeight,
        barWidth,
        zomato[i],
        maxY,
        const Color(0xFFC8102E),
      );
      // Swiggy (orange)
      _drawBar(
        canvas,
        x + barWidth + barSpacing + leftPad,
        chartHeight,
        barWidth,
        swiggy[i],
        maxY,
        const Color(0xFFFF8C1A),
      );
      // Magicpin (blue)
      _drawBar(
        canvas,
        x + 2 * (barWidth + barSpacing) + leftPad,
        chartHeight,
        barWidth,
        magicpin[i],
        maxY,
        const Color(0xFF4A90E2),
      );

      x += groupWidth + groupSpace;
    }
  }

  void _drawBar(Canvas canvas, double x, double chartHeight, double width, int value, double maxY, Color color) {
    final barHeight = (value / maxY) * (chartHeight - (isMobile ? 16 : 32));
    final rect = Rect.fromLTWH(
      x,
      chartHeight - barHeight - 1,
      width,
      barHeight,
    );
    final paint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), paint);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}

// --- MAIN PAGE ---
class OnlineOrderRunningPage extends StatefulWidget {
  final Map<String, String> dbToBrandMap;

  const OnlineOrderRunningPage({super.key, required this.dbToBrandMap});

  @override
  State<OnlineOrderRunningPage> createState() => _OnlineOrderRunningPageState();
}

class _OnlineOrderRunningPageState extends State<OnlineOrderRunningPage>
    with SingleTickerProviderStateMixin {
  String? selectedBrand = "All";
  String? selectedRestaurant;
  String? selectedRecordType = "Last 2 days records";
  String? selectedStatus = "All";
  final TextEditingController orderNoController = TextEditingController();

  late TabController _tabController;
  bool showChart = false; // Chart/table toggle

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.dbToBrandMap.isNotEmpty) {
      selectedRestaurant = widget.dbToBrandMap.entries.first.key +
          " - " +
          widget.dbToBrandMap.entries.first.value;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandNames = widget.dbToBrandMap.values.toSet();
    final restaurantList = widget.dbToBrandMap.entries
        .map((e) => "${e.key} - ${e.value}")
        .toList();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;

    return SidePanel(
      dbToBrandMap: widget.dbToBrandMap,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                SizedBox(width: isMobile ? 8 : 16),
                Image.asset(
                  'assets/images/reddpos.png',
                  height: isMobile ? 30 : 40,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 80,
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
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: isMobile ? 12 : 56),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 4 : 8,
                      ),
                    ),
                    icon: const Icon(Icons.help_outline, size: 18, color: Colors.black87),
                    label: Text(
                      "Aggregator Help Center",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : isTablet ? 16 : 24,
                    vertical: isMobile ? 10 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      elevation: 0,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: isMobile ? 6 : 8,
                                left: isMobile ? 5 : 10,
                                bottom: isMobile ? 4 : 6),
                            child: Text(
                              "Online Orders Activity",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 15 : 18,
                                  color: Colors.black),
                            ),
                          ),
                          // Channel tabs as TabBar
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            indicatorColor: const Color(0xFFD5282B),
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 13 : 15,
                            ),
                            tabs: [
                              _tabIconLabel(Icons.grid_view_rounded, "All"),
                              _tabImageLabel("assets/images/zomato.png", "Zomato"),
                              _tabImageLabel("assets/images/swiggy.png", "Swiggy"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 12 : 18,
                            horizontal: isMobile ? 8 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chart header row
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => setState(() => showChart = !showChart),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 6 : 10,
                                        vertical: isMobile ? 2 : 5),
                                    child: Row(
                                      children: [
                                        Icon(Icons.show_chart,
                                            color: const Color(0xFF3498F3),
                                            size: isMobile ? 22 : 30),
                                        SizedBox(width: isMobile ? 4 : 8),
                                        Text(
                                          "Last 5 Days Orders",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isMobile ? 13 : 17,
                                              color: Colors.black),
                                        ),
                                        SizedBox(width: isMobile ? 2 : 5),
                                        Text(
                                          showChart ? "(Hide Chart)" : "(View Chart)",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: isMobile ? 11 : 13,
                                              color: Colors.grey),
                                        ),
                                        Icon(
                                            showChart
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (showChart)
                              Padding(
                                padding: EdgeInsets.only(top: isMobile ? 8 : 16, bottom: isMobile ? 8 : 16),
                                child: SimpleBarChart(isMobile: isMobile),
                              ),
                            // Filter row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterDropdown(
                                    context,
                                    title: "Select Restaurant",
                                    value: selectedRestaurant,
                                    items: restaurantList,
                                    onChanged: (v) => setState(() => selectedRestaurant = v),
                                    width: isMobile ? 160 : 220,
                                  ),
                                  SizedBox(width: isMobile ? 8 : 16),
                                  _filterDropdown(
                                    context,
                                    title: "Record Type",
                                    value: selectedRecordType,
                                    items: const [
                                      "Last 2 days records",
                                      "Last 5 days records",
                                      "Today"
                                    ],
                                    onChanged: (v) => setState(() => selectedRecordType = v),
                                    width: isMobile ? 120 : 180,
                                  ),
                                  SizedBox(width: isMobile ? 8 : 16),
                                  _filterDropdown(
                                    context,
                                    title: "Status",
                                    value: selectedStatus,
                                    items: const [
                                      "All",
                                      "Prepared",
                                      "Delivered"
                                    ],
                                    onChanged: (v) => setState(() => selectedStatus = v),
                                    width: isMobile ? 80 : 130,
                                  ),
                                  SizedBox(width: isMobile ? 8 : 16),
                                  _filterTextField(context, "Order No.", orderNoController, width: isMobile ? 80 : 130),
                                  SizedBox(width: isMobile ? 5 : 16),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD5282B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        "Apply",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 12 : 15),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 4 : 8),
                                  SizedBox(
                                    height: 40,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFFD5282B)),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        "Show All",
                                        style: TextStyle(
                                            color: const Color(0xFFD5282B),
                                            fontSize: isMobile ? 12 : 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // TabBarView for Table content (All/Zomato/Swiggy)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: isMobile ? 200 : 300,
                                  maxHeight: isMobile ? 400 : 800),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildOrderTable(isMobile: isMobile, channel: "All"),
                                  _buildOrderTable(isMobile: isMobile, channel: "Zomato"),
                                  _buildOrderTable(isMobile: isMobile, channel: "Swiggy"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Tab _tabIconLabel(IconData icon, String label) {
    return Tab(
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 5),
          Text(label, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Tab _tabImageLabel(String asset, String label) {
    return Tab(
      child: Row(
        children: [
          Image.asset(asset, width: 22, height: 22),
          const SizedBox(width: 5),
          Text(label, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _filterDropdown(
      BuildContext context, {
        required String title,
        required String? value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
        double width = 150,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              items: items
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(
                  r,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterTextField(BuildContext context, String title, TextEditingController controller, {double width = 120}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "",
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTable({required bool isMobile, required String channel}) {
    // For demo, using static order rows, channel is just for placeholder
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: isMobile ? 32 : 44,
          dataRowHeight: isMobile ? 40 : 60,
          horizontalMargin: 12,
          columns: [
            _tableCol("Order No.", isMobile),
            _tableCol("Outlet Name", isMobile),
            _tableCol("Order Type", isMobile),
            _tableCol("Customer", isMobile),
            _tableCol("OTP", isMobile),
            _tableCol("Date Time", isMobile),
            _tableCol("Total", isMobile),
            _tableCol("Status", isMobile),
            _tableCol("At", isMobile),
            _tableCol("Actions", isMobile),
          ],
          rows: [
            DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return const Color(0xFFE5F8E7); // Light green for success
                  }),
              cells: [
                DataCell(SizedBox(
                  width: isMobile ? 80 : 140,
                  child: Text(
                    "206544700540627\n(Online Paid)",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: isMobile ? 11 : 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                DataCell(SizedBox(
                  width: isMobile ? 100 : 180,
                  child: Text(
                    "Ebony//The Flip Bar (Ebony Fine-Dine)\n[49920]\nSwiggy",
                    style: TextStyle(fontSize: isMobile ? 10 : 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )),
                DataCell(Text("Delivery", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Text("Manoj", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Text("4619", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(SizedBox(
                  width: isMobile ? 90 : 180,
                  child: Text(
                      "Created : 18-05-2025 19:02:06\nReceived : 18-05-2025 19:02:06\nAccepted :18-05-2025 19:02:06\nUpdated : 18-05-2025 19:02:08",
                      style: TextStyle(fontSize: isMobile ? 9 : 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4
                  ),
                )),
                DataCell(Text("654.31",
                    style: TextStyle(
                        backgroundColor: const Color(0xFFDBF8D3),
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 13))),
                DataCell(Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 13,
                      vertical: isMobile ? 3 : 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Prepared",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 13),
                  ),
                )),
                DataCell(Text("0", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: isMobile ? 14 : 20),
                    Icon(Icons.history, size: isMobile ? 14 : 20),
                  ],
                )),
              ],
            ),
            DataRow(
              cells: [
                DataCell(SizedBox(
                  width: isMobile ? 80 : 140,
                  child: Text(
                    "6892390999\n(Online Paid)",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: isMobile ? 11 : 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                DataCell(SizedBox(
                  width: isMobile ? 100 : 180,
                  child: Text(
                    "Ebony//The Flip Bar [49920]",
                    style: TextStyle(fontSize: isMobile ? 10 : 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )),
                DataCell(Text("Delivery", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Text("Ankit Pahwa", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Text("4329", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(SizedBox(
                  width: isMobile ? 90 : 180,
                  child: Text(
                      "Created : 18-05-2025 14:59:45\nReceived : 18-05-2025 14:59:46",
                      style: TextStyle(fontSize: isMobile ? 9 : 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2
                  ),
                )),
                DataCell(Text("1,033.87",
                    style: TextStyle(
                        backgroundColor: const Color(0xFFDBF8D3),
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 13))),
                DataCell(Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 13,
                      vertical: isMobile ? 3 : 6),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Delivered",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 13),
                  ),
                )),
                DataCell(Text("0", style: TextStyle(fontSize: isMobile ? 10 : 13))),
                DataCell(Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: isMobile ? 14 : 20),
                    Icon(Icons.history, size: isMobile ? 14 : 20),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _tableCol(String label, bool isMobile) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}