import 'dart:convert';

List<Pricing> pricingFromMap(String str) =>
    List<Pricing>.from(json.decode(str).map((x) => Pricing.fromMap(x)));

String pricingToMap(List<Pricing> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Pricing {
  int id;
  bool status;
  String itemName;
  String itemCode;
  int price;
  String area;

  Pricing({
    required this.id,
    required this.status,
    required this.itemName,
    required this.itemCode,
    required this.price,
    required this.area,
  });

  factory Pricing.fromMap(Map<String, dynamic> json) => Pricing(
    id: json["id"],
    status: json["status"].toString().toLowerCase() == "true",
    itemName: json["itemName"],
    itemCode: json["itemcode"],
    price: json["price"],
    area: json["area"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "status": status.toString(),
    "itemName": itemName,
    "itemcode": itemCode,
    "price": price,
    "area": area,
  };
}
