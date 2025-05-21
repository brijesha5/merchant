// To parse this JSON data, do
//
//     final orderItem = orderItemFromMap(jsonString);

import 'dart:convert';

List<OrderItem> orderItemFromMap(String str) => List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromMap(x)));

String orderItemToMap(List<OrderItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class OrderItem {
  final int? kotId;
  final String? orderNumber;
  final String? tableNumber;
  final String? itemName;
  final int? itemCode;
  late final int? quantity;
  final DateTime? orderTime;
  final String? notes;
  late final String? status;
  double? price;
  final String? costCenterCode;
  bool isComp;
  double pricebckp;

  OrderItem({
    this.kotId,
    this.orderNumber,
    this.tableNumber,
    this.itemName,
    this.itemCode,
    this.quantity,
    this.orderTime,
    this.notes,
    this.status,
    this.price,
    this.costCenterCode,
    this.isComp = false,
    this.pricebckp = 0.0,// Default status is empty
  });

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
    kotId: json["kotId"],
    orderNumber: json["orderNumber"],
    tableNumber: json["tableNumber"],
    itemName: json["itemName"],
    itemCode: json["itemCode"],
    quantity: json["quantity"],
    orderTime: json["orderTime"] == null ? null : DateTime.parse(json["orderTime"]),
    notes: json["notes"],
    status: json["status"],
    price: json["price"],
    costCenterCode: json["costCenterCode"],
  );

  Map<String, dynamic> toMap() => {
    "kotId": kotId,
    "orderNumber": orderNumber,
    "tableNumber": tableNumber,
    "itemName": itemName,
    "itemCode": itemCode,
    "quantity": quantity,
    "orderTime": orderTime?.toIso8601String(),
    "notes": notes,
    "status": status,
    "price": price,
    "costCenterCode": costCenterCode,
  };
}