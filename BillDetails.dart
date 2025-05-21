import 'package:meta/meta.dart';
import 'dart:convert';

BillDetails billDetailsFromMap(String str) => BillDetails.fromMap(json.decode(str));

String billDetailsToMap(BillDetails data) => json.encode(data.toMap());

class BillDetails {
  final int billId;
  final List<Bill> billItems;
  final List<Bill> billModifiers;
  final List<BillTax> billTaxes;
  final String billNo;
  final String tableNumber;
  final String customerName;
  final String customerMobile;
  final String customerGst;
  final String billDate;
  final String totalAmount;
  final String isSettle;
  final String settlementModeName;
  final dynamic settlementModeId;
  final String waiter;
  final String user;
  final String billDiscount;
  final String billDiscountPercent;
  final String billDiscountRemark;
  final String homeDeliveryCharge;
  final String billTax;
  final int pax;
  final String GrandTotal;
  final String tipamt;
  final String orderId; // online order

  BillDetails({
    required this.billId,
    required this.billItems,
    required this.billModifiers,
    required this.billTaxes,
    required this.billNo,
    required this.tableNumber,
    required this.customerName,
    required this.customerMobile,
    required this.customerGst,
    required this.billDate,
    required this.totalAmount,
    required this.isSettle,
    required this.settlementModeName,
    required this.settlementModeId,
    required this.waiter,
    required this.user,
    required this.billDiscount,
    required this.billDiscountPercent,
    required this.billDiscountRemark,
    required this.homeDeliveryCharge,
    required this.billTax,
    required this.pax,
    required this.GrandTotal,
    required this.tipamt,
    required this.orderId,
  });

  BillDetails copyWith({
    int? billId,
    List<Bill>? billItems,
    List<Bill>? billModifiers,
    List<BillTax>? billTaxes,
    String? billNo,
    String? tableNumber,
    String? customerName,
    String? customerMobile,
    String? customerGst,
    String? billDate,
    String? totalAmount,
    String? isSettle,
    String? settlementModeName,
    dynamic settlementModeId,
    String? waiter,
    String? user,
    String? billDiscount,
    String? billDiscountPercent,
    String? billDiscountRemark,
    String? homeDeliveryCharge,
    String? billTax,
    int? pax,
    String? GrandTotal,
    String? tipamt,
    String? orderId,
  }) =>
      BillDetails(
        billId: billId ?? this.billId,
        billItems: billItems ?? this.billItems,
        billModifiers: billModifiers ?? this.billModifiers,
        billTaxes: billTaxes ?? this.billTaxes,
        billNo: billNo ?? this.billNo,
        tableNumber: tableNumber ?? this.tableNumber,
        customerName: customerName ?? this.customerName,
        customerMobile: customerMobile ?? this.customerMobile,
        customerGst: customerGst ?? this.customerGst,
        billDate: billDate ?? this.billDate,
        totalAmount: totalAmount ?? this.totalAmount,
        isSettle: isSettle ?? this.isSettle,
        settlementModeName: settlementModeName ?? this.settlementModeName,
        settlementModeId: settlementModeId ?? this.settlementModeId,
        waiter: waiter ?? this.waiter,
        user: user ?? this.user,
        billDiscount: billDiscount ?? this.billDiscount,
        billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
        billDiscountRemark: billDiscountRemark ?? this.billDiscountRemark,
        homeDeliveryCharge: homeDeliveryCharge ?? this.homeDeliveryCharge,
        billTax: billTax ?? this.billTax,
        pax: pax ?? this.pax,
        GrandTotal: GrandTotal ?? this.GrandTotal,
        tipamt: tipamt ?? this.tipamt,
        orderId: orderId ?? this.orderId,
      );

  factory BillDetails.fromMap(Map<String, dynamic> json) => BillDetails(
    billId: json["billId"] ?? 0, // Default to 0 if missing
    billItems: json["billItems"] != null
        ? List<Bill>.from(json["billItems"].map((x) => Bill.fromMap(x)))
        : [],
    billModifiers: json["billModifiers"] != null
        ? List<Bill>.from(json["billModifiers"].map((x) => Bill.fromMap(x)))
        : [],
    billTaxes: json["billTaxes"] != null
        ? List<BillTax>.from(json["billTaxes"].map((x) => BillTax.fromMap(x)))
        : [],
    billNo: json["billNo"] ?? "Unknown", // Default if missing
    tableNumber: json["tableNumber"]?.toString() ?? "0", // Handle nulls gracefully
    customerName: json["customerName"] ?? "Unknown", // Default to "Unknown"
    customerMobile: json["customerMobile"] ?? "Unknown", // Default to "Unknown"
    customerGst: json["customerGst"] ?? "Unknown", // Default to "Unknown"
    billDate: json["billDate"] ?? "Unknown", // Default to "Unknown"
    totalAmount: json["totalAmount"] ?? "0.00", // Default to "0.00"
    isSettle: json["isSettle"] ?? "No", // Default to "No"
    settlementModeName: json["settlementModeName"] ?? "Unknown", // Default to "Unknown"
    settlementModeId: json["settlementModeId"] ?? "Unknown", // Default if missing
    waiter: json["waiter"] ?? "Unknown", // Default to "Unknown"
    user: json["user"] ?? "Unknown", // Default to "Unknown"
    billDiscount: json["billDiscount"] ?? "0.00", // Default to "0.00"
    billDiscountPercent: json["billDiscountPercent"]?.toString() ?? "0.0", // Default to "0.0"
    billDiscountRemark: json["billDiscountRemark"] ?? "None", // Default to "None"
    homeDeliveryCharge: json["homeDeliveryCharge"] ?? "0.00", // Default to "0.00"
    billTax: json["billTax"] ?? "0.00", // Default to "0.00"
    pax: json["pax"] ?? 1, // Default to 1
    GrandTotal: json["GrandTotal"] ?? "0.00", // Default to "0.00"
    tipamt: json["tipamt"] ?? "0.00", // Default to "0.00"
    orderId: json["orderId"] ?? "Unknown", // Default if orderId is missing
  );

  Map<String, dynamic> toMap() => {
    "billId": billId,
    "billItems": List<dynamic>.from(billItems.map((x) => x.toMap())),
    "billModifiers": List<dynamic>.from(billModifiers.map((x) => x.toMap())),
    "billTaxes": List<dynamic>.from(billTaxes.map((x) => x.toMap())),
    "billNo": billNo,
    "tableNumber": tableNumber,
    "customerName": customerName,
    "customerMobile": customerMobile,
    "customerGst": customerGst,
    "billDate": billDate,
    "totalAmount": totalAmount,
    "isSettle": isSettle,
    "settlementModeName": settlementModeName,
    "settlementModeId": settlementModeId,
    "waiter": waiter,
    "user": user,
    "billDiscount": billDiscount,
    "billDiscountPercent": billDiscountPercent,
    "billDiscountRemark": billDiscountRemark,
    "homeDeliveryCharge": homeDeliveryCharge,
    "billTax": billTax,
    "pax": pax,
    "GrandTotal": GrandTotal,
    "tipamt": tipamt,
    "orderId": orderId,
  };
}

class Bill {
  final int billItemId;
  final String productCode;
  final int quantity;
  final String pricePerUnit;

  Bill({
    required this.billItemId,
    required this.productCode,
    required this.quantity,
    required this.pricePerUnit,
  });

  factory Bill.fromMap(Map<String, dynamic> json) => Bill(
    billItemId: json["billItemId"] ?? 0, // Default to 0 if missing
    productCode: json["productCode"] ?? "Unknown", // Default to "Unknown"
    quantity: json["quantity"] ?? 0, // Default to 0 if missing
    pricePerUnit: json["pricePerUnit"] ?? "0.00", // Default to "0.00"
  );

  Map<String, dynamic> toMap() => {
    "billItemId": billItemId,
    "productCode": productCode,
    "quantity": quantity,
    "pricePerUnit": pricePerUnit,
  };
}

class BillTax {
  final int billTaxId;
  final String taxCode;
  final String taxName;
  final String taxPercent;
  final String taxAmount;

  BillTax({
    required this.billTaxId,
    required this.taxCode,
    required this.taxName,
    required this.taxPercent,
    required this.taxAmount,
  });

  factory BillTax.fromMap(Map<String, dynamic> json) => BillTax(
    billTaxId: json["billTaxId"] ?? 0, // Default to 0 if missing
    taxCode: json["taxCode"] ?? "Unknown", // Default to "Unknown"
    taxName: json["taxName"] ?? "Unknown", // Default to "Unknown"
    taxPercent: json["taxPercent"] ?? "0.00", // Default to "0.00"
    taxAmount: json["taxAmount"] ?? "0.00", // Default to "0.00"
  );

  Map<String, dynamic> toMap() => {
    "billTaxId": billTaxId,
    "taxCode": taxCode,
    "taxName": taxName,
    "taxPercent": taxPercent,
    "taxAmount": taxAmount,
  };
}
