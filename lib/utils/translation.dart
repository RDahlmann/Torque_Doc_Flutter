import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations extends ChangeNotifier {
  static final Translations _instance = Translations._internal();

  factory Translations({String? initialLanguage}) {
    if (initialLanguage != null) {
      _instance._currentLanguage = initialLanguage;
    }
    return _instance;
  }

  Translations._internal();

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  final Map<String, Map<String, String>> _localizedValues = {
    'de': {
      'name': 'Name',
      'project': 'Projektnummer',
      'tolerance': 'Toleranz',
      'serial_pump': 'Seriennummer Pumpe',
      'serial_tool': 'Seriennummer Werkzeug',
      'serial_hose': 'Seriennummer Schlauch',
      'tool': 'Werkzeug',
      'name_insert': 'Name eingeben',
      'project_insert': 'Projektnummer eingeben',
      'tolerance_insert': 'Toleranz +- eingeben',
      'serial_pump_insert': 'Seriennummer Pumpe eingeben',
      'serial_tool_insert': 'Seriennummer Werkzeug eingeben',
      'serial_hose_insert': 'Seriennummer Schlauch eingeben',
      'tool_insert': 'Werkzeug',
      'continue': 'Weiter',
      'save_back': 'Speichern & Zurück',
      'language': 'Sprache auswählen',
      'mode': 'Modus',
      'automatic': 'Automatik',
      'safety': 'Sicherheitsmodus',
      'connected': 'Verbunden',
      'not_connected': 'Nicht verbunden',
    },
    'en': {
      'name': 'Name',
      'project': 'Projectnumber',
      'tolerance': 'Tolerance',
      'serial_pump': 'Serialnumber Pump',
      'serial_tool': 'Serialnumber Tool',
      'serial_hose': 'Serialnumber Hose',
      'tool': 'Tool',
      'name_insert': 'Insert Name',
      'project_insert': 'Insert Projectnumber',
      'tolerance_insert': 'Insert Tolerance+-',
      'serial_pump_insert': 'Insert Serialnumber Pump',
      'serial_tool_insert': 'Insert Serialnumber Tool',
      'serial_hose_insert': 'Insert Serialnumber Hose',
      'tool_insert': 'Tool',
      'continue': 'Continue',
      'save_back': 'Save & Back',
      'language': 'Select Language',
      'mode': 'Mode',
      'automatic': 'Automatic',
      'safety': 'Safety Mode',
      'connected': 'Connected',
      'not_connected': 'Not Connected',
    },
  };

  // 🔹 Text abrufen
  String text(String key) {
    return _localizedValues[_currentLanguage]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // 🔹 Sprache wechseln und speichern
  Future<void> setLocale(String languageCode) async {
    if (_localizedValues.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
    }
  }

  // 🔹 Gespeicherte Sprache beim Start laden
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode') ?? 'en';
    _currentLanguage = savedLang;
  }
}
