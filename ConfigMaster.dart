// To parse this JSON data, do
//
//     final configMaster = configMasterFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<ConfigMaster> configMasterFromMap(String str) => List<ConfigMaster>.from(json.decode(str).map((x) => ConfigMaster.fromMap(x)));

String configMasterToMap(List<ConfigMaster> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ConfigMaster {
  final String printlanguage;
  final String brandName;
  final String licenceNo;
  final String onlineApi;
  final String bankApi;
  final String gstNo;
  final String vatNo;
  final String fssaiNo;
  final String billFooter;
  final String installDate;
  final String expireDate;
  final String userCreated;
  final String userModified;
  final String modifiedDate;
  final String daycloseDate;
  final int id;
  final String address;
  final String contactno;
  final String merchantId;
  final String emailid;

  ConfigMaster({
    required this.printlanguage,
    required this.brandName,
    required this.licenceNo,
    required this.onlineApi,
    required this.bankApi,
    required this.gstNo,
    required this.vatNo,
    required this.fssaiNo,
    required this.billFooter,
    required this.installDate,
    required this.expireDate,
    required this.userCreated,
    required this.userModified,
    required this.modifiedDate,
    required this.daycloseDate,
    required this.id,
    required this.address,
    required this.contactno,
    required this.merchantId,
    required this.emailid,
  });

  ConfigMaster copyWith({
    String? printlanguage,
    String? brandName,
    String? licenceNo,
    String? onlineApi,
    String? bankApi,
    String? gstNo,
    String? vatNo,
    String? fssaiNo,
    String? billFooter,
    String? installDate,
    String? expireDate,
    String? userCreated,
    String? userModified,
    String? modifiedDate,
    String? daycloseDate,
    int? id,
    String? address,
    String? contactno,
    String? merchantId,
    String? emailid,
  }) =>
      ConfigMaster(
        printlanguage: printlanguage ?? this.printlanguage,
        brandName: brandName ?? this.brandName,
        licenceNo: licenceNo ?? this.licenceNo,
        onlineApi: onlineApi ?? this.onlineApi,
        bankApi: bankApi ?? this.bankApi,
        gstNo: gstNo ?? this.gstNo,
        vatNo: vatNo ?? this.vatNo,
        fssaiNo: fssaiNo ?? this.fssaiNo,
        billFooter: billFooter ?? this.billFooter,
        installDate: installDate ?? this.installDate,
        expireDate: expireDate ?? this.expireDate,
        userCreated: userCreated ?? this.userCreated,
        userModified: userModified ?? this.userModified,
        modifiedDate: modifiedDate ?? this.modifiedDate,
        daycloseDate: daycloseDate ?? this.daycloseDate,
        id: id ?? this.id,
        address: address ?? this.address,
        contactno: contactno ?? this.contactno,
        merchantId: merchantId ?? this.merchantId,
        emailid: emailid ?? this.emailid,
      );

  factory ConfigMaster.fromMap(Map<String, dynamic> json) => ConfigMaster(
    printlanguage: json["printlanguage"],
    brandName: json["brandName"],
    licenceNo: json["licenceNo"],
    onlineApi: json["onlineApi"],
    bankApi: json["bankApi"],
    gstNo: json["gstNo"],
    vatNo: json["vatNo"],
    fssaiNo: json["fssaiNo"],
    billFooter: json["billFooter"],
    installDate: json["installDate"],
    expireDate: json["expireDate"],
    userCreated: json["userCreated"],
    userModified: json["userModified"],
    modifiedDate: json["modifiedDate"],
    daycloseDate: json["daycloseDate"],
    id: json["id"],
    address: json["address"],
    contactno: json["contactno"],
    merchantId: json["merchantId"],
    emailid: json["emailid"],
  );

  Map<String, dynamic> toMap() => {
    "printlanguage": printlanguage,
    "brandName": brandName,
    "licenceNo": licenceNo,
    "onlineApi": onlineApi,
    "bankApi": bankApi,
    "gstNo": gstNo,
    "vatNo": vatNo,
    "fssaiNo": fssaiNo,
    "billFooter": billFooter,
    "installDate": installDate,
    "expireDate": expireDate,
    "userCreated": userCreated,
    "userModified": userModified,
    "modifiedDate": modifiedDate,
    "daycloseDate": daycloseDate,
    "id": id,
    "address": address,
    "contactno": contactno,
    "merchantId": merchantId,
    "emailid": emailid,
  };
}
