import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torquedoc/globals.dart';

class FieldSettings extends ChangeNotifier {
  // Pflichtfelder
  bool requireName = false;
  bool requireProject = true;
  bool requireSerialPump = false;
  bool requireSerialTool = false;
  bool requireSerialHose = false;

  // Modus
  bool automatik = true;

  //Export
  bool csv=true;
  bool pdf=true;
  // Sprache
  String language = 'de';

  FieldSettings() {
    loadFromPrefs();
  }

  // Setter für Felder
  void setField(String field, bool value) {
    switch (field) {
      case 'requireName':
        requireName = value;
        break;
      case 'requireProject':
        requireProject = value;
        break;
      case 'requireSerialPump':
        requireSerialPump = value;
        break;
      case 'requireSerialTool':
        requireSerialTool = value;
        break;
      case 'requireSerialHose':
        requireSerialHose = value;
        break;
    }
    notifyListeners();
    _saveBool(field, value);
  }

  // Modus setzen
  void setAutomatik(bool value) {
    automatik = value;
    Automatik=value;
    notifyListeners();
    _saveBool('automatik', value);
  }

  void setPDF(bool value) {
    pdf = value;
    ISPDF=value;
    notifyListeners();
    _saveBool('ispdf', value);
  }
  void setCSV(bool value) {
    csv = value;
    ISCSV=value;
    notifyListeners();
    _saveBool('iscsv', value);
  }

  // Sprache setzen
  void setLanguage(String lang) {
    language = lang;
    notifyListeners();
    _saveString('language', lang);
  }

  // 🔹 SharedPreferences speichern
  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 🔹 SharedPreferences laden
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    requireName = prefs.getBool('requireName') ?? false;
    requireProject = prefs.getBool('requireProject') ?? false;
    requireSerialPump = prefs.getBool('requireSerialPump') ?? false;
    requireSerialTool = prefs.getBool('requireSerialTool') ?? false;
    requireSerialHose = prefs.getBool('requireSerialHose') ?? false;
    automatik = prefs.getBool('automatik') ?? true;
    pdf = prefs.getBool('ispdf') ?? true;
    csv = prefs.getBool('iscsv') ?? true;
    automatik = prefs.getBool('automatik') ?? true;
    language = prefs.getString('language') ?? 'de';
    notifyListeners();
  }
}
