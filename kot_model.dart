// To parse this JSON data, do
//
//     final kot = kotFromMap(jsonString);

import 'dart:convert';

List<Kot> kotFromMap(String str) => List<Kot>.from(json.decode(str).map((x) => Kot.fromMap(x)));

String kotToMap(List<Kot> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Kot {
  final String? kotId;
  final String? tableNumber;
  final int? quantity;
  final DateTime? orderTime;
  final dynamic notes;
  final dynamic status;

  Kot({
    this.kotId,
    this.tableNumber,
    this.quantity,
    this.orderTime,
    this.notes,
    this.status,
  });

  factory Kot.fromMap(Map<String, dynamic> json) => Kot(
    kotId: json["kotId"],
    tableNumber: json["tableNumber"],
    quantity: json["quantity"],
    orderTime: json["orderTime"] == null ? null : DateTime.parse(json["orderTime"]),
    notes: json["notes"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "kotId": kotId,
    "tableNumber": tableNumber,
    "quantity": quantity,
    "orderTime": orderTime?.toIso8601String(),
    "notes": notes,
    "status": status,
  };
}
