// To parse this JSON data, do
//
//     final reservation = reservationFromMap(jsonString);

import 'dart:convert';

List<Reservation> reservationFromMap(String str) => List<Reservation>.from(json.decode(str).map((x) => Reservation.fromMap(x)));

String reservationToMap(List<Reservation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Reservation {
  int reservationId;
  String resNo;

  String guestName;
  DateTime resDate;
  String resTime;
  String guestContact;
  String selectTable;

  Reservation({
    required this.reservationId,
    required this.resNo,

    required this.guestName,
    required this.resDate,
    required this.resTime,
    required this.guestContact,
    required this.selectTable,
  });

  factory Reservation.fromMap(Map<String, dynamic> json) => Reservation(
    reservationId: json["reservationId"],
    resNo: json["resNo"],

    guestName: json["guestName"],
    resDate: DateTime.parse(json["resDate"]),
    resTime: json["res_Time"],
    guestContact: json["guestContact"],
    selectTable: json["selectTable"],
  );

  Map<String, dynamic> toMap() => {
    "reservationId": reservationId,
    "resNo": resNo,

    "guestName": guestName,
    "resDate": "${resDate.year.toString().padLeft(4, '0')}-${resDate.month.toString().padLeft(2, '0')}-${resDate.day.toString().padLeft(2, '0')}",
    "res_Time": resTime,
    "guestContact": guestContact,
    "selectTable": selectTable,
  };
}
