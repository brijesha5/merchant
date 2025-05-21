// To parse this JSON data, do
//
//     final kitchenorder = kitchenorderFromMap(jsonString);

import 'dart:convert';

List<Kitchenorder> kitchenorderFromMap(String str) => List<Kitchenorder>.from(json.decode(str).map((x) => Kitchenorder.fromMap(x)));

String kitchenorderToMap(List<Kitchenorder> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Kitchenorder {
  String kotId;
  String orderNumber;
  int tableNumber;
  String itemName;
  int quantity;
  dynamic orderTime;
  String notes;
  String status;

  Kitchenorder({
    required this.kotId,
    required this.orderNumber,
    required this.tableNumber,
    required this.itemName,
    required this.quantity,
    required this.orderTime,
    required this.notes,
    required this.status,
  });

  factory Kitchenorder.fromMap(Map<String, dynamic> json) => Kitchenorder(
    kotId: json["kotId"],
    orderNumber: json["orderNumber"],
    tableNumber: json["tableNumber"],
    itemName: json["itemName"],
    quantity: json["quantity"],
    orderTime: json["orderTime"],
    notes: json["notes"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "kotId": kotId,
    "orderNumber": orderNumber,
    "tableNumber": tableNumber,
    "itemName": itemName,
    "quantity": quantity,
    "orderTime": orderTime,
    "notes": notes,
    "status": status,
  };
}
