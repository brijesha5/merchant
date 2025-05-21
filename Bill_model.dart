import 'dart:convert';

List<Bill> billFromMap(String str) => List<Bill>.from(json.decode(str).map((x) => Bill.fromMap(x)));

String billToMap(List<Bill> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Bill {
  final int? billId;
  final List<dynamic>? billItems;
  final List<dynamic>? billModifiers;
  final String? billNo;
  final String? tableNumber;
  final String? customerName;
  final String? billDate;
  final String? totalAmount;
  final String? isSettle;
  final String? settlementModeName;
  final String? billTax;
  final String? billDiscount;
  final String? orderId;///onlinrorder///

  Bill({
    this.billId,
    this.billItems,
    this.billModifiers,
    this.billNo,
    this.tableNumber,
    this.customerName,
    this.billDate,
    this.totalAmount,
    this.isSettle,
    this.settlementModeName,
    this.billTax,
    this.billDiscount,
    this.orderId,
  });

  factory Bill.fromMap(Map<String, dynamic> json) {
    return Bill(
      billId: json["billId"] != null ? int.tryParse(json["billId"].toString()) : null,
      billItems: json["billItems"] == null ? [] : List<dynamic>.from(json["billItems"]!.map((x) => x)),
      billModifiers: json["billModifiers"] == null ? [] : List<dynamic>.from(json["billModifiers"]!.map((x) => x)),
      billNo: json["billNo"],
      tableNumber: json["tableNumber"],
      customerName: json["customerName"],
      billDate: json["billDate"],
      totalAmount: json["totalAmount"],
      isSettle: json["isSettle"],
      settlementModeName: json["settlementModeName"],
      billTax: json["billTax"],
      billDiscount: json["billDiscount"],
      orderId: json["orderId"] ?? "Unknown",
    );
  }
  Map<String, dynamic> toMap() => {
    "billId": billId,
    "billItems": billItems == null ? [] : List<dynamic>.from(billItems!.map((x) => x)),
    "billModifiers": billModifiers == null ? [] : List<dynamic>.from(billModifiers!.map((x) => x)),
    "billNo": billNo,
    "tableNumber": tableNumber,
    "customerName": customerName,
    "billDate": billDate,
    "totalAmount": totalAmount,
    "isSettle": isSettle,
    "settlementModeName": settlementModeName,
    "billTax": billTax,
    "billDiscount": billDiscount,

    "orderId":orderId,
  };
}
