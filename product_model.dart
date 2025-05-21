
import 'dart:convert';

List<Product> productFromMap(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromMap(x)));

String productToMap(List<Product> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Product {
  int productCode;
  String productName;
  String productImage;
  ProductType productType;
  int categoryCode;
  String productDescription;
  String costcenterCode;
  String dietary;

  Product({
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.productType,
    required this.categoryCode,
    required this.productDescription,
    required this.costcenterCode,
    required this.dietary,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    productCode: json["productCode"],
    productName: json["productName"],
    productImage: json["productImage"],
    productType: productTypeValues.map[json["productType"]]!,
    categoryCode: json["categoryCode"],
    productDescription: json["productDescription"],
    costcenterCode: json["costcenterCode"],
    dietary: json["dietary"],
  );

  Map<String, dynamic> toMap() => {
    "productCode": productCode,
    "productName": productName,
    "productImage": productImage,
    "productType": productTypeValues.reverse[productType],
    "categoryCode": categoryCode,
    "productDescription": productDescription,
    "costcenterCode": costcenterCode,
    "dietary": dietary,
  };
}

enum ProductType {
  EMPTY,
  FOOD
}

final productTypeValues = EnumValues({
  "": ProductType.EMPTY,
  "food": ProductType.FOOD,
  "beverage": ProductType.FOOD,
  "liquor": ProductType.FOOD,
  "other": ProductType.FOOD,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
