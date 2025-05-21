import 'dart:convert';

List<CanceledOrder> canceledOrderFromMap(String str) =>
    List<CanceledOrder>.from(json.decode(str).map((x) => CanceledOrder.fromMap(x)));

String canceledOrderToMap(List<CanceledOrder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class CanceledOrder {
  String orderId;
  int restaurantId;
  String restaurantName;
  String externalOrderId;
  String orderFrom;
  DateTime orderDateTime;
  double netAmount;
  double grossAmount;
  String paymentMode;
  String orderType;
  String orderInstructions;
  double cgst;
  double sgst;
  double cgstPercent;
  double sgstPercent;
  double orderPackaging;
  double orderPackagingCgst;
  double orderPackagingSgst;
  double discount;
  double deliveryCharge;
  String status;
  String billNo;
  String kotId;
  List<CanceledOrderItem> items;
  List<dynamic> onlineOrderItemVariantList;
  List<CanceledOrderAddon> onlineOrderItemAddonList;
  CustomerDetail? customerDetail;

  CanceledOrder({
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.externalOrderId,
    required this.orderFrom,
    required this.orderDateTime,
    required this.netAmount,
    required this.grossAmount,
    required this.paymentMode,
    required this.orderType,
    required this.orderInstructions,
    required this.cgst,
    required this.sgst,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.orderPackaging,
    required this.orderPackagingCgst,
    required this.orderPackagingSgst,
    required this.discount,
    required this.deliveryCharge,
    required this.status,
    required this.billNo,
    required this.kotId,
    required this.items,
    required this.onlineOrderItemVariantList,
    required this.onlineOrderItemAddonList,
    this.customerDetail,
  });

  factory CanceledOrder.fromMap(Map<String, dynamic> json) {
    List<CanceledOrderItem> items = json["onlineOrderItemList"] != null
        ? List<CanceledOrderItem>.from(json["onlineOrderItemList"].map((x) => CanceledOrderItem.fromMap(x)))
        : [];


    return CanceledOrder(
      orderId: json["orderId"] ?? "N/A",
      restaurantId: json["restaurantId"] ?? 0,
      restaurantName: json["restaurantName"] ?? "Unknown",
      externalOrderId: json["externalOrderId"] ?? "Unknown",
      orderFrom: json["orderFrom"] ?? "Unknown",
      orderDateTime: DateTime.tryParse(json["orderDateTime"] ?? "") ?? DateTime.now(),
      netAmount: (json["netAmount"] ?? 0.0).toDouble(),
      grossAmount: (json["grossAmount"] ?? 0.0).toDouble(),
      paymentMode: json["paymentMode"] ?? "Unknown",
      orderType: json["orderType"] ?? "Unknown",
      orderInstructions: json["orderInstructions"] ?? "",
      cgst: (json["cgst"] ?? 0.0).toDouble(),
      sgst: (json["sgst"] ?? 0.0).toDouble(),
      cgstPercent: (json["cgstPercent"] ?? 0.0).toDouble(),
      sgstPercent: (json["sgstPercent"] ?? 0.0).toDouble(),
      orderPackaging: (json["orderPackaging"] ?? 0.0).toDouble(),
      orderPackagingCgst: (json["orderPackagingCgst"] ?? 0.0).toDouble(),
      orderPackagingSgst: (json["orderPackagingSgst"] ?? 0.0).toDouble(),
      discount: (json["discount"] ?? 0.0).toDouble(),
      deliveryCharge: (json["deliveryCharge"] ?? 0.0).toDouble(),
      status: json["status"] ?? "canceled",
      billNo: json["billno"] ?? "Unknown",
      kotId: json["kotId"] ?? "Unknown",
      items: items,
      onlineOrderItemVariantList: json["onlineOrderItemVariantList"] != null
          ? List<dynamic>.from(json["onlineOrderItemVariantList"])
          : [],
      onlineOrderItemAddonList: [],
      customerDetail: (json["customerDetail"] != null && json["customerDetail"] is Map)
          ? CustomerDetail.fromMap(json["customerDetail"])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    "online_order_id": orderId,
    "restaurant_id": restaurantId,
    "restaurant_name": restaurantName,
    "external_order_id": externalOrderId,
    "order_from": orderFrom,
    "order_date_time": orderDateTime.toIso8601String(),
    "net_amount": netAmount,
    "gross_amount": grossAmount,
    "payment_mode": paymentMode,
    "order_type": orderType,
    "order_instructions": orderInstructions,
    "cgst": cgst,
    "sgst": sgst,
    "cgst_percent": cgstPercent,
    "sgst_percent": sgstPercent,
    "order_packaging": orderPackaging,
    "order_packaging_cgst": orderPackagingCgst,
    "order_packaging_sgst": orderPackagingSgst,
    "discount": discount,
    "delivery_charge": deliveryCharge,
    "status": status,
    "billno": billNo,
    "kot_id": kotId,
    "onlineOrderItemList": List<dynamic>.from(items.map((x) => x.toMap())),
    "onlineOrderItemVariantList": List<dynamic>.from(onlineOrderItemVariantList.map((x) => x)),
    "onlineOrderItemAddonList": List<dynamic>.from(onlineOrderItemAddonList.map((x) => x.toMap())),
    "customerDetail": customerDetail?.toMap(),
  };
}

class CanceledOrderItem {
  String weraItemId;
  String itemName;
  int itemId;
  double itemUnitPrice;
  double subtotal;
  double discount;
  int itemQuantity;
  double cgst;
  double sgst;
  double cgstPercent;
  double sgstPercent;
  int packaging;
  double packagingCgst;
  double packagingSgst;
  double packagingCgstPercent;
  double packagingSgstPercent;
  List<CanceledOrderAddon> onlineOrderItemAddonList;

  CanceledOrderItem({
    required this.weraItemId,
    required this.itemId,
    required this.itemName,
    required this.itemUnitPrice,
    required this.subtotal,
    required this.discount,
    required this.itemQuantity,
    required this.cgst,
    required this.sgst,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.packaging,
    required this.packagingCgst,
    required this.packagingSgst,
    required this.packagingCgstPercent,
    required this.packagingSgstPercent,
    required this.onlineOrderItemAddonList,
  });

  factory CanceledOrderItem.fromMap(Map<String, dynamic> json) => CanceledOrderItem(
    weraItemId: json["weraItemId"] ?? "",
    itemId: json["itemId"] ?? json["item_id"] ?? 0,
    itemName: json["itemName"] ?? json["item_name"] ?? "Unknown Item",
    itemUnitPrice: (json["itemUnitPrice"] ?? json["item_unit_price"] ?? 0.0).toDouble(),
    subtotal: (json["subtotal"] ?? 0.0).toDouble(),
    discount: (json["discount"] ?? json["item_discount"] ?? 0.0).toDouble(),
    itemQuantity: json["itemQuantity"] ?? json["item_quantity"] ?? 1,
    cgst: (json["cgst"] ?? json["item_cgst"] ?? 0.0).toDouble(),
    sgst: (json["sgst"] ?? json["item_sgst"] ?? 0.0).toDouble(),
    cgstPercent: (json["cgstPercent"] ?? json["item_cgst_percent"] ?? 0.0).toDouble(),
    sgstPercent: (json["sgstPercent"] ?? json["item_sgst_percent"] ?? 0.0).toDouble(),
    packaging: json["packaging"] ?? 0,
    packagingCgst: (json["packagingCgst"] ?? json["packaging_cgst"] ?? 0.0).toDouble(),
    packagingSgst: (json["packagingSgst"] ?? json["packaging_sgst"] ?? 0.0).toDouble(),
    packagingCgstPercent: (json["packagingCgstPercent"] ?? json["packaging_cgst_percent"] ?? 0.0).toDouble(),
    packagingSgstPercent: (json["packagingSgstPercent"] ?? json["packaging_sgst_percent"] ?? 0.0).toDouble(),
    onlineOrderItemAddonList: json["onlineOrderItemAddonList"] != null
        ? List<CanceledOrderAddon>.from(json["onlineOrderItemAddonList"].map((x) => CanceledOrderAddon.fromMap(x)))
        : [],
  );

  Map<String, dynamic> toMap() => {
    "weraItemId": weraItemId,
    "itemId": itemId,
    "itemName": itemName,
    "itemUnitPrice": itemUnitPrice,
    "subtotal": subtotal,
    "discount": discount,
    "itemQuantity": itemQuantity,
    "cgst": cgst,
    "sgst": sgst,
    "cgstPercent": cgstPercent,
    "sgstPercent": sgstPercent,
    "packaging": packaging,
    "packagingCgst": packagingCgst,
    "packagingSgst": packagingSgst,
    "packagingCgstPercent": packagingCgstPercent,
    "packagingSgstPercent": packagingSgstPercent,
    "onlineOrderItemAddonList": List<dynamic>.from(onlineOrderItemAddonList.map((x) => x.toMap())),

  };
}

class CanceledOrderAddon {
  String addonId;
  String weraAddonId;
  String addonName;
  double addonPrice;
  double cgst;
  double sgst;
  double cgstPercent;
  double sgstPercent;
  double discountedPrice;

  CanceledOrderAddon({
    required this.addonId,
    required this.weraAddonId,
    required this.addonName,
    required this.addonPrice,
    required this.cgst,
    required this.sgst,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.discountedPrice,
  });

  factory CanceledOrderAddon.fromMap(Map<String, dynamic> json) => CanceledOrderAddon(
    addonId: json["addonId"] ?? "N/A",
    weraAddonId: json["weraAddonId"] ?? "N/A",
    addonName: json["addonName"] ?? "Unknown",
    addonPrice: (json["addonPrice"] ?? 0.0).toDouble(),
    cgst: (json["cgst"] ?? 0.0).toDouble(),
    sgst: (json["sgst"] ?? 0.0).toDouble(),
    cgstPercent: (json["cgstPercent"] ?? 0.0).toDouble(),
    sgstPercent: (json["sgstPercent"] ?? 0.0).toDouble(),
    discountedPrice: (json["discountedPrice"] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "addonId": addonId,
    "weraAddonId": weraAddonId,
    "addonName": addonName,
    "addonPrice": addonPrice,
    "cgst": cgst,
    "sgst": sgst,
    "cgstPercent": cgstPercent,
    "sgstPercent": sgstPercent,
    "discountedPrice": discountedPrice,
  };
}
class CustomerDetail {
  int id;
  String custname;
  String? orderInstructions;
  String deliveryArea;
  String phoneNumber;

  CustomerDetail({
    required this.id,
    required this.custname,
    this.orderInstructions,
    required this.deliveryArea,
    required this.phoneNumber,
  });

  factory CustomerDetail.fromMap(Map<String, dynamic> json) => CustomerDetail(
    id: json["id"] ?? 0,
    custname: json["custname"] ?? "Unknown",
    orderInstructions: json["orderInstructions"],
    deliveryArea: json["deliveryArea"] ?? "",
    phoneNumber: json["phoneNumber"] ?? "N/A",
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "custname": custname,
    "orderInstructions": orderInstructions,
    "deliveryArea": deliveryArea,
    "phoneNumber": phoneNumber,
  };
}

