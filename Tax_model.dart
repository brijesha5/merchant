// To parse this JSON data, do
//
//     final tax = taxFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Tax> taxFromMap(String str) => List<Tax>.from(json.decode(str).map((x) => Tax.fromMap(x)));

String taxToMap(List<Tax> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Tax {
  final String taxCode;
  final String taxName;
  final String taxPercent;
  final String isApplicableonDinein;
  final String isApplicableonTakeaway;
  final String isApplicableonHomedelivery;
  final String isApplicableOnlineorder;
  final String isApplicableCountersale;
  final int id;

  Tax({
    required this.taxCode,
    required this.taxName,
    required this.taxPercent,
    required this.isApplicableonDinein,
    required this.isApplicableonTakeaway,
    required this.isApplicableonHomedelivery,
    required this.isApplicableOnlineorder,
    required this.isApplicableCountersale,
    required this.id,
  });

  Tax copyWith({
    String? taxCode,
    String? taxName,
    String? taxPercent,
    String? isApplicableonDinein,
    String? isApplicableonTakeaway,
    String? isApplicableonHomedelivery,
    String? isApplicableOnlineorder,
    String? isApplicableCountersale,
    int? id,
  }) =>
      Tax(
        taxCode: taxCode ?? this.taxCode,
        taxName: taxName ?? this.taxName,
        taxPercent: taxPercent ?? this.taxPercent,
        isApplicableonDinein: isApplicableonDinein ?? this.isApplicableonDinein,
        isApplicableonTakeaway: isApplicableonTakeaway ?? this.isApplicableonTakeaway,
        isApplicableonHomedelivery: isApplicableonHomedelivery ?? this.isApplicableonHomedelivery,
        isApplicableOnlineorder: isApplicableOnlineorder ?? this.isApplicableOnlineorder,
        isApplicableCountersale: isApplicableCountersale ?? this.isApplicableCountersale,
        id: id ?? this.id,
      );

  factory Tax.fromMap(Map<String, dynamic> json) => Tax(
    taxCode: json["taxCode"],
    taxName: json["taxName"],
    taxPercent: json["taxPercent"],
    isApplicableonDinein: json["isApplicableonDinein"],
    isApplicableonTakeaway: json["isApplicableonTakeaway"],
    isApplicableonHomedelivery: json["isApplicableonHomedelivery"],
    isApplicableOnlineorder: json["isApplicableOnlineorder"],
    isApplicableCountersale: json["isApplicableCountersale"],
    id: json["id"],
  );

  Map<String, dynamic> toMap() => {
    "taxCode": taxCode,
    "taxName": taxName,
    "taxPercent": taxPercent,
    "isApplicableonDinein": isApplicableonDinein,
    "isApplicableonTakeaway": isApplicableonTakeaway,
    "isApplicableonHomedelivery": isApplicableonHomedelivery,
    "isApplicableOnlineorder": isApplicableOnlineorder,
    "isApplicableCountersale": isApplicableCountersale,
    "id": id,
  };
}
