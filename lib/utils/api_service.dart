import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tool_model.dart';


class ApiService {
  static const baseUrl = 'https://www.stephandahlmann.com/tool_api';

  static Future<List<Tool1>> getTools(String customerCode) async {
    final url = Uri.parse('$baseUrl/get_tools.php?customerCode=$customerCode');
    final res = await http.get(url);

    if (res.statusCode != 200) throw Exception('API Fehler');

    final data = jsonDecode(res.body);
    if (data['status'] != 'ok') throw Exception(data['error'] ?? 'Unbekannter Fehler');

    return (data['tools'] as List)
        .map((json) => Tool1.fromJson(json))
        .toList();
  }
}

