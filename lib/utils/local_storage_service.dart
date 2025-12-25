import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tool_model.dart';

class LocalStorageService {
  static const _keyTools = 'tools';

  static Future<void> saveTools(List<Tool1> tools) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tools.map((e) => e.toJson()).toList());
    await prefs.setString(_keyTools, jsonStr); // überschreibt alte Tools
  }

  static Future<List<Tool1>> loadTools() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTools);
    if (jsonStr == null) return [];
    final data = jsonDecode(jsonStr) as List;
    return data.map((e) => Tool1.fromJson(e)).toList();
  }

  static Future<void> clearTools() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTools);
  }
}
