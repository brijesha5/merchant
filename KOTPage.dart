import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant/SidePanel.dart';

class KOTPage extends StatefulWidget {
  final Map<String, String> dbToBrandMap;
  const KOTPage({super.key, required this.dbToBrandMap});

  @override
  State<KOTPage> createState() => _KOTPageState();
}

class _KOTPageState extends State<KOTPage> {
  String? selectedBrand;
  String selectedOrderType = "All";
  String selectedStatus = "All";
  String selectedFilter = "All";
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime endDate = DateTime.now();
  final TextEditingController kotIdController = TextEditingController();
  final TextEditingController custNameController = TextEditingController();
  final TextEditingController custPhoneController = TextEditingController();
  final TextEditingController tableNoController = TextEditingController();

  final List<String> orderTypes = ["All", "Dine In", "Takeaway", "Delivery"];
  final List<String> statuses = ["All", "Used In Bill", "Open", "Cancelled"];
  final List<String> filters = ["All", "Used In Bill", "Open", "Cancelled"];

  final List<Map<String, String>> kotRecords = List.generate(15, (i) {
    final now = DateTime(2025, 5, 19, 21, 59 - i * 2);
    return {
      "KOT ID": "${15 - i}",
      "Order Type": "Delivery",
      "Customer Name": [
        "Diksha Agrawal",
        "Mahesh",
        "Tanmay Ranjan",
        "Mahima",
        "Allan J. Carvalho",
        "Aryan Kaushik",
        "Rashmi"
      ][i % 7],
      "Customer Phone": "",
      "No. Of Items": "${(i % 4) + 1}",
      "Items": [
        "Classic Chicken Tikka (Regular [6 Pcs]), Non Veg Caesars, Veg Greek",
        "Amritsari Chole (Regular [500 Gm])",
        "Brownie, Gulab Jamun (6 Pcs), Subz Biryani (Regular [650 Ml]), Veg Kadhai (Regular [500 Gm])",
        "Classic Chicken Tikka (Regular [6 Pcs])",
        "Chicken Reshmi Tikka (Dozen [12 Pcs])",
        "Chicken Burnt Chilli Garlic Rice (Regular [650 Ml]), Garlic Butter Prawns (Regular [500 Gm]), Tandoori Chicken (Half)",
        "Veg Thai Curry (Regular [6 Pcs])"
      ][i % 7],
      "Status": "Used In Bill",
      "Bill Print Date": DateFormat("dd MMM yyyy HH:mm:ss").format(now),
      "Complete Duration": "0 hr : ${21 - i} min",
      "Created": DateFormat("dd MMM yyyy HH:mm:ss").format(now),
    };
  });

  final ScrollController _tableHorizontal = ScrollController();
  final ScrollController _tableVertical = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedBrand = "All";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final isTablet = size.width >= 700 && size.width < 1100;
    final dateFormat = DateFormat('dd MMM yyyy HH:mm:ss');
    final brandNames = widget.dbToBrandMap.values.toSet();
    return SidePanel(
        dbToBrandMap: widget.dbToBrandMap,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 24, vertical: 8),
          child: Row(
            children: [
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
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                label: Text(
                  dateFormat.format(DateTime.now()),
                  style: const TextStyle(color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  side: const BorderSide(color: Color(0xFFD5282B)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: Colors.black54),
                tooltip: "Export Excel",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar and Filters with label
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20, vertical: isMobile ? 8 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "KOT",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 18 : isTablet ? 22 : 26,
                      color: Colors.black,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                // Search label
                Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black, size: 20),
                    const SizedBox(width: 6),
                    Text("Search", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 16 : isTablet ? 18 : 20)),
                  ],
                ),
                const SizedBox(height: 10),
                // Filters Row 1 (responsive wrap)
                LayoutBuilder(
                  builder: (ctx, box) {
                    double fieldPad = isMobile ? 6 : (isTablet ? 8 : 12);
                    double fieldPadV = isMobile ? 4 : 8;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _datePickerField("Start Date", startDate, (d) => setState(() => startDate = d), width: isMobile ? 175 : 210),
                          SizedBox(width: fieldPad),
                          _datePickerField("End Date", endDate, (d) => setState(() => endDate = d), width: isMobile ? 175 : 210),
                          SizedBox(width: fieldPad),
                          _inputField("Kot ID", kotIdController, width: isMobile ? 90 : 110),
                          SizedBox(width: fieldPad),
                          _inputField("Customer Name", custNameController, width: isMobile ? 120 : 160),
                          SizedBox(width: fieldPad),
                          _inputField("Customer Phone", custPhoneController, width: isMobile ? 105 : 130),
                          SizedBox(width: fieldPad),
                          _inputField("Table No.", tableNoController, width: isMobile ? 75 : 100),
                          SizedBox(width: fieldPad),
                          _dropdownField("All Order Type", orderTypes, selectedOrderType, (v) => setState(() => selectedOrderType = v!), width: isMobile ? 110 : 140),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Filters Row 2 (responsive wrap)
                LayoutBuilder(
                  builder: (ctx, box) {
                    double fieldPad = isMobile ? 8 : 16;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _dropdownField("Status", statuses, selectedStatus, (v) => setState(() => selectedStatus = v!), width: isMobile ? 90 : 120),
                          SizedBox(width: fieldPad),
                          _dropdownField("Filter", filters, selectedFilter, (v) => setState(() => selectedFilter = v!), width: isMobile ? 90 : 120),
                          SizedBox(width: fieldPad + 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 20 : 34,
                                  vertical: isMobile ? 10 : 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text("Search"),
                          ),
                          SizedBox(width: isMobile ? 6 : 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 11 : 18, vertical: isMobile ? 10 : 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text("Show All"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // DataTable
          Expanded(
            child: Stack(
              children: [
                Scrollbar(
                  controller: _tableVertical,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _tableVertical,
                    child: Scrollbar(
                      controller: _tableHorizontal,
                      thumbVisibility: true,
                      notificationPredicate: (notif) => notif.depth == 1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _tableHorizontal,
                        child: DataTable(
                          columnSpacing: isMobile ? 10 : isTablet ? 13 : 16,
                          dataRowMinHeight: isMobile ? 44 : (isTablet ? 50 : 56),
                          dataRowMaxHeight: isMobile ? 54 : (isTablet ? 60 : 72),
                          headingRowHeight: isMobile ? 40 : (isTablet ? 46 : 54),
                          columns: [
                            _dtCol("KOT ID", minWidth: isMobile ? 60 : 80),
                            _dtCol("Order Type", minWidth: isMobile ? 70 : 90),
                            _dtCol("Customer Name", minWidth: isMobile ? 100 : 130),
                            _dtCol("Customer Phone", minWidth: isMobile ? 90 : 110),
                            _dtCol("No. Of Items", minWidth: isMobile ? 60 : 90),
                            _dtCol("Items", minWidth: isMobile ? 170 : 260),
                            _dtCol("Status", minWidth: isMobile ? 60 : 90),
                            _dtCol("Bill Print Date", minWidth: isMobile ? 100 : 130),
                            _dtCol("Complete Duration", minWidth: isMobile ? 85 : 110),
                            _dtCol("Created", minWidth: isMobile ? 100 : 130),
                            _dtCol("Actions", minWidth: isMobile ? 60 : 80),
                          ],
                          rows: kotRecords.map((row) {
                            return DataRow(
                              cells: [
                                DataCell(Text(row["KOT ID"]!)),
                                DataCell(Text(row["Order Type"]!)),
                                DataCell(Text(row["Customer Name"]!)),
                                DataCell(Text(row["Customer Phone"]!)),
                                DataCell(Text(row["No. Of Items"]!)),
                                DataCell(SizedBox(
                                  width: isMobile ? 170 : 260,
                                  child: Text(
                                    row["Items"]!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                                DataCell(Text(row["Status"]!)),
                                DataCell(Text(row["Bill Print Date"]!)),
                                DataCell(Row(
                                  children: [
                                    Text(row["Complete Duration"]!),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                )),
                                DataCell(Text(row["Created"]!)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
                                    onPressed: () {},
                                    tooltip: "View KOT",
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Stuck bottom bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.redAccent.withOpacity(0.08),
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 24, vertical: isMobile ? 4 : 8),
                    child: Row(
                      children: [
                        const Text("Showing 1 to 15 of 15 records", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.info_outline, color: Colors.redAccent),
                          label: const Text("Modified KOT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.07),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
        );
  }

  DataColumn _dtCol(String label, {double minWidth = 100}) => DataColumn(
    label: SizedBox(
      width: minWidth,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _datePickerField(String label, DateTime date, Function(DateTime) onSelect, {double width = 210}) {
    return SizedBox(
      width: width,
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: DateFormat('dd MMM yyyy HH:mm:ss').format(date)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        onTap: () async {
          final res = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (res != null) {
            onSelect(DateTime(res.year, res.month, res.day, date.hour, date.minute, date.second));
          }
        },
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {double width = 120}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> options, String value, ValueChanged<String?> onChanged, {double width = 120}) {
    return SizedBox(
      width: width,
      child:DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        ),
        items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: onChanged,
      )

    );
  }
}