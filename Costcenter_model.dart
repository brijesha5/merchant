// To parse this JSON data, do
//
//     final costcenter = costcenterFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Costcenter> costcenterFromMap(String str) => List<Costcenter>.from(json.decode(str).map((x) => Costcenter.fromMap(x)));

String costcenterToMap(List<Costcenter> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Costcenter {
  final String name;
  final int id;
  final String code;
  final String printername;
  final String printerip1;
  final String printerip2;
  final String printerip3;

  Costcenter({
    required this.name,
    required this.id,
    required this.code,
    required this.printername,
    required this.printerip1,
    required this.printerip2,
    required this.printerip3
  });

  Costcenter copyWith({
    String? name,
    int? id,
    String? code,
    String? printername,
    String? printerip,
  }) =>
      Costcenter(
        name: name ?? this.name,
        id: id ?? this.id,
        code: code ?? this.code,
        printername: printername ?? this.printername,
        printerip1: printerip1 ?? this.printerip1,
        printerip2: printerip2 ?? this.printerip2,
        printerip3: printerip3 ?? this.printerip3,
      );

  factory Costcenter.fromMap(Map<String, dynamic> json) => Costcenter(
    name: json["name"],
    id: json["id"],
    code: json["code"],
    printername: json["printername"],
    printerip1: json["printerip1"],
    printerip2: json["printerip2"],
    printerip3: json["printerip3"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "id": id,
    "code": code,
    "printername": printername,
    "printerip1": printerip1,
    "printerip2": printerip2,
    "printerip3": printerip3,
  };
}
