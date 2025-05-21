import 'dart:convert';

List<Category> categoryFromMap(String str) => List<Category>.from(json.decode(str).map((x) => Category.fromMap(x)));

String categoryToMap(List<Category> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Category {
  int categoryCode;
  String categoryName;

  Category({
    required this.categoryCode,
    required this.categoryName,
  });

  factory Category.fromMap(Map<String, dynamic> json) => Category(
    categoryCode: json["categoryCode"],
    categoryName: json["categoryName"],
  );

  Map<String, dynamic> toMap() => {
    "categoryCode": categoryCode,
    "categoryName": categoryName,
  };
}
