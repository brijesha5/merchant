import 'package:meta/meta.dart';
import 'dart:convert';

List<OrderModifier> orderModifierFromMap(String str) => List<OrderModifier>.from(json.decode(str).map((x) => OrderModifier.fromMap(x)));

String orderModifierToMap(List<OrderModifier> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class KotId {
  final String kotId;
  final String tableNumber;
  final int quantity;
  final String orderTime;
  final String? notes;
  final String status;

  KotId({
    required this.kotId,
    required this.tableNumber,
    required this.quantity,
    required this.orderTime,
    this.notes,
    required this.status,
  });

  factory KotId.fromMap(Map<String, dynamic> json) => KotId(
    kotId: json["kotId"],
    tableNumber: json["tableNumber"],
    quantity: json["quantity"],
    orderTime: json["orderTime"],
    notes: json["notes"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "kotId": kotId,
    "tableNumber": tableNumber,
    "quantity": quantity,
    "orderTime": orderTime,
    "notes": notes,
    "status": status,
  };
}

class OrderModifier {
  final int orderId;
  final KotId kotId;
  final String productCode;

  final String name;
  final int quantity;
  final String pricePerUnit;
  final dynamic totalPrice;

  OrderModifier({
    required this.orderId,
    required this.kotId,
    required this.productCode,

    required this.name,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  OrderModifier copyWith({
    int? orderId,
    KotId? kotId,
    String? productCode,

    String? name,
    int? quantity,
    String? pricePerUnit,
    dynamic totalPrice,
  }) =>
      OrderModifier(
        orderId: orderId ?? this.orderId,
        kotId: kotId ?? this.kotId,
        productCode: productCode ?? this.productCode,

        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        totalPrice: totalPrice ?? this.totalPrice,
      );

  factory OrderModifier.fromMap(Map<String, dynamic> json) => OrderModifier(
    orderId: json["orderId"],
    kotId: KotId.fromMap(json["kotId"]), // Parsing the nested KotId object
    productCode: json["productCode"],

    name: json["name"],
    quantity: json["quantity"],
    pricePerUnit: json["pricePerUnit"],
    totalPrice: json["totalPrice"],
  );

  Map<String, dynamic> toMap() => {
    "orderId": orderId,
    "kotId": kotId.toMap(), // Converting KotId to map
    "productCode": productCode,

    "name": name,
    "quantity": quantity,
    "pricePerUnit": pricePerUnit,
    "totalPrice": totalPrice,
  };
}
