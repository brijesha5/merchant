class TotalSalesReport {
  final String occupiedTables;
  final String onlineSales;
  final String billDiscount;
  final String endDate;
  final String counterTotal;
  final String netSales;
  final String totalSales;
  final String roundOffTotal;
  final String onlineOrders;
  final String homeDeliveryChargeTotal;
  final String totalKotEntries;
  final String homeDeliveryTotal;
  final String billTimes;
  final String cashSales;
  final String billTax;
  final String dineTotal;
  final String takeAwayTotal;
  final String startDate;

  TotalSalesReport({
    required this.occupiedTables,
    required this.onlineSales,
    required this.billDiscount,
    required this.endDate,
    required this.counterTotal,
    required this.netSales,
    required this.totalSales,
    required this.roundOffTotal,
    required this.onlineOrders,
    required this.homeDeliveryChargeTotal,
    required this.totalKotEntries,
    required this.homeDeliveryTotal,
    required this.billTimes,
    required this.cashSales,
    required this.billTax,
    required this.dineTotal,
    required this.takeAwayTotal,
    required this.startDate,
  });

  factory TotalSalesReport.fromJson(Map<String, dynamic> json) {
    return TotalSalesReport(
      occupiedTables: json['occupiedTables']?.toString() ?? "",
      onlineSales: json['onlineSales']?.toString() ?? "",
      billDiscount: json['billDiscount']?.toString() ?? "",
      endDate: json['endDate']?.toString() ?? "",
      counterTotal: json['counterTotal']?.toString() ?? "",
      netSales: json['netSales']?.toString() ?? "",
      totalSales: json['totalSales']?.toString() ?? "",
      roundOffTotal: json['roundOffTotal']?.toString() ?? "",
      onlineOrders: json['onlineOrders']?.toString() ?? "",
      homeDeliveryChargeTotal: json['homeDeliveryChargeTotal']?.toString() ?? "",
      totalKotEntries: json['totalKotEntries']?.toString() ?? "",
      homeDeliveryTotal: json['homeDeliveryTotal']?.toString() ?? "",
      billTimes: json['billTimes']?.toString() ?? "",
      cashSales: json['cashSales']?.toString() ?? "",
      billTax: json['billTax']?.toString() ?? "",
      dineTotal: json['dineTotal']?.toString() ?? "",
      takeAwayTotal: json['takeAwayTotal']?.toString() ?? "",
      startDate: json['startDate']?.toString() ?? "",
    );
  }
}