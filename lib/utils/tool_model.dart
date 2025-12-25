import 'dart:convert';

class Tool1 {
  final int id;
  final String customerCode;
  final String serialNumber;
  final String toolName;
  final List<int> torque;
  final List<int> pressure;

  Tool1({
    required this.id,
    required this.customerCode,
    required this.serialNumber,
    required this.toolName,
    required this.torque,
    required this.pressure,
  });

  factory Tool1.fromJson(Map<String, dynamic> json) {
    List<int> parseList(dynamic value) {
      if (value is String) {
        // API liefert String, z.B. "[100,200,300]"
        return (jsonDecode(value) as List<dynamic>).map((e) => e as int).toList();
      } else if (value is List) {
        // lokal gespeichert, schon List
        return value.map((e) => e as int).toList();
      } else {
        return [];
      }
    }

    return Tool1(
      id: int.parse(json['id'].toString()),
      customerCode: json['customer_code'],
      serialNumber: json['serial_number'],
      toolName: json['tool_name'],
      torque: parseList(json['torque']),
      pressure: parseList(json['pressure']),
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_code': customerCode,
    'serial_number': serialNumber,
    'tool_name': toolName,
    'torque': torque,
    'pressure': pressure,
  };
}

