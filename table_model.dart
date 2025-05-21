import 'dart:convert';

List<TableSeat> tableSeatFromMap(String str) => List<TableSeat>.from(
    json.decode(str).map((x) => TableSeat.fromMap(x)));

String tableSeatToMap(List<TableSeat> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TableSeat {

  String tableName;
  String status;
  int id;
  String area;
  int? pax;

  TableSeat({

    required this.tableName,
    required this.status,
    required this.area,
    required this.id,
    this.pax, // Pax can now be null
  });

  // Factory method to create a TableSeat from a map, handling pax as nullable
  factory TableSeat.fromMap(Map<String, dynamic> json) => TableSeat(

    tableName: json["tableName"],
    status: json["status"],
    area: json['area'],
    id: json["id"],
    pax: json["pax"] != null ? (json["pax"] is double ? json["pax"].toInt() : json["pax"]) : null, // Handle conversion if pax is double
  );

  Map<String, dynamic> toMap() => {

    "tableName": tableName,
    "status": status,
    "id": id,
    "area": area,
    "pax": pax,  // Pax can now be null, so we include it as-is
  };
}
