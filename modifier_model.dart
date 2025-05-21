// To parse this JSON data, do
//
//     final modifier = modifierFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Modifier> modifierFromMap(String str) => List<Modifier>.from(json.decode(str).map((x) => Modifier.fromMap(x)));

String modifierToMap(List<Modifier> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Modifier {
  final int modifierCode;
  final String modifierName;
  final String modifierType;
  final double price;
  final int productCode;

  Modifier({
    required this.modifierCode,
    required this.modifierName,
    required this.modifierType,
    required this.price,
    required this.productCode,
  });

  Modifier copyWith({
    int? modifierCode,
    String? modifierName,
    String? modifierType,
    double? price,
    int? productCode,
  }) =>
      Modifier(
        modifierCode: modifierCode ?? this.modifierCode,
        modifierName: modifierName ?? this.modifierName,
        modifierType: modifierType ?? this.modifierType,
        price: price ?? this.price,
        productCode: productCode ?? this.productCode,
      );

  factory Modifier.fromMap(Map<String, dynamic> json) => Modifier(
    modifierCode: json["modifierCode"],
    modifierName: json["modifierName"],
    modifierType: json["modifierType"],
    price: json["price"],
    productCode: json["productCode"],
  );

  Map<String, dynamic> toMap() => {
    "modifierCode": modifierCode,
    "modifierName": modifierName,
    "modifierType": modifierType,
    "price": price,
    "productCode": productCode,
  };
}
