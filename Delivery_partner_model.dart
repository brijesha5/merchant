
import 'dart:convert';

List<DeliveryPartner> deliveryPartnerFromMap(String str) => List<DeliveryPartner>.from(json.decode(str).map((x) => DeliveryPartner.fromMap(x)));

String deliveryPartnerToMap(List<DeliveryPartner> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class DeliveryPartner {
  int deliveryPartnerCode;
  String deliveryPartnerName;
  String status;

  DeliveryPartner({
    required this.deliveryPartnerCode,
    required this.deliveryPartnerName,
    required this.status,
  });

  DeliveryPartner copyWith({
    int? deliveryPartnerCode,
    String? deliveryPartnerName,
    String? status,
  }) =>
      DeliveryPartner(
        deliveryPartnerCode: deliveryPartnerCode ?? this.deliveryPartnerCode,
        deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
        status: status ?? this.status,
      );

  factory DeliveryPartner.fromMap(Map<String, dynamic> json) => DeliveryPartner(
    deliveryPartnerCode: json["deliveryPartnerCode"],
    deliveryPartnerName: json["deliveryPartnerName"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "deliveryPartnerCode": deliveryPartnerCode,
    "deliveryPartnerName": deliveryPartnerName,
    "status": status,
  };
}
