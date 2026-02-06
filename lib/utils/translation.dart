import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations extends ChangeNotifier {
  Translations({String? initialLanguage}) {
    if (initialLanguage != null) _currentLanguage = initialLanguage;
  }

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  /// Gibt den Text zurück
  String text(String key) {
    return _localizedValues[_currentLanguage]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  /// Gibt Text mit Platzhaltern zurück
  String textArgs(String key, Map<String, dynamic> args) {
    String result = text(key);
    args.forEach((k, v) {
      result = result.replaceAll('{$k}', v.toString());
    });
    return result;
  }

  /// Sprache wechseln und speichern
  Future<void> setLocale(String languageCode) async {
    if (_localizedValues.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners(); // UI aktualisieren

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
    }
  }

  /// Gespeicherte Sprache laden
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode') ?? 'en';
    _currentLanguage = savedLang;
    notifyListeners(); // UI aktualisieren
  }
  final Map<String, Map<String, String>> _localizedValues = {
    'de': {
      'automatik1':'Bitte Anzahl der Schrauben eingeben',
      'automatik2':'Anzahl Schrauben',
      'automatik3':'Bestätigen',
      'automatik4':'Der Schraubvorgang wurde vom Nutzer abgebrochen',
      'automatik5':'Schraubvorgang nach dem ersten Hub aufgrund der Festigkeitsprüfung abgebrochen',
      'automatik6':'Vorgang abgebrochen, Schraube ist fest',
      'automatik7':'Die Schraube war beim Start Lose',
      'automatik8':'Vorgang abgebrochen, Schraube ist nicht fest',
      'automatik9':'Die Schraube war beim Start nicht Lose',
      'automatik10':'Alle Schrauben angezogen, bitte zurück zum Hauptmenü',
      'automatik11':'WARNUNG: Istdruck nicht in Toleranz, bitte erneut Anziehen oder Toleranz prüfen',
      'automatik12':'Verschrauben läuft...',
      'automatik13':'Bereit zum Verschrauben...',
      'automatik14':'Solldruck: {value} {unit}',
      'automatik15': 'Schraube {value} von {unit}',
      'automatik16':'Es ist ein Fehler mit der Bluetooth Kommunikation aufgetreten,\n bitte bestätigen',
      'automatik17':'Es ist ein Fehler an der Pumpe aufgetreten,\n hier klicken um Bluetooth neu zu verbinden',

      'bt1':'Gerät verbunden!',
      'bt2':'Fehler!',
      'bt3':'Gerät auswählen',

      'ch1':'Weiter mit Druckeingabe',
      'ch2':'Weiter mit Werkzeugauswahl',

      'home1':'Name',
      'home2':'Bitte den Namen eingeben',
      'home3':'Projektnummer',
      'home4':'Bitte die Projektnummer eingeben',
      'home5':'Maximal 15 Zeichen erlaubt',
      'home6':'Nur Buchstaben & Zahlen erlaubt',
      'home7':'Toleranz',
      'home8':'Bitte die Toleranz eingeben',
      'home9':'Seriennummer Pumpe',
      'home10':'Bitte die Seriennummer der Pumpe eingeben',
      'home11':'Seriennummer Schlauch',
      'home12':'Bitte die Seriennummer des Schlauchs eingeben',
      'home13':'Seriennummer Werkzeug',
      'home14':'Bitte die Seriennummer des Werkzeugs eingeben',
      'home15':'Werkzeug',
      'home16':'Bitte die Werkzeugbeschreibung eingeben',


      'kal1':'Zum Kalibrieren Werkzeug von der Schraube lösen und Start gedrückt halten.\n Die Pumpe fährt den Druck langsam an und fügt drei Kontrollhübe durch',

      'man1':'Zum Starten der Pumpe und Ausfahren des Zylinders den START-Taste drücken\nZum Einfahren des Zylinders START-Taste loslasse\nZum Stoppen der Pumpe STOP-Taste drücken',

      'menu1':'Automatikmodus',
      'menu2':'Manuelles verschrauben',
      'menu3':'Zurück zur Druckauswahl',

      'pres1':'Druckeingabe 100 Bar - 680 bar',
      'pres2':'Druckeingabe 2176 PSI - 9427 PSI',
      'pres3':'Bitte geben Sie den Druck ein',
      'pres4':'Solldruck muss zwischen 100 und 680 bar liegen',
      'pres5':'Solldruck muss zwischen 2716 und 9427 PSI liegen',

      'set1':'Sprache auswählen',
      'set2':'Modus',
      'set3':'Automatikmodus',
      'set4':'Sicherheitsmodus',
      'set5':'Pflichtfelder',
      'set6':'Name',
      'set7':'Seriennummer Werkzeug',
      'set8':'Seriennummer Schlauch',
      'set9':'Werkzeuge in Datenbank einpflegen',
      'set10':'Druckeinheit auswählen',
      'set11':'Impressum',
      'set12':'Datenschutz',
      'set13':'Drehmomenteinheit auswählen',
      'set14':'Export-Format',

      'tools1':'Kundencode muss 10-stellig sein!',
      'tools2':'Fehler beim Laden der Tools',
      'tools3':'Drehmoment (Nm)',
      'tools4':'Bitte gültiges Drehmoment eingeben',
      'tools5':'Fehler: Drehmoment außerhalb des Bereichs ({minTorque}-{maxTorque} Nm)',
      'tools6':'Fehler: interpolierter Druckwert {value} bar außerhalb des Bereichs (100-680 bar)',
      'tools7':'Interpolierter Druck: {value} bar',
      'tools8':'Kundencode',
      'tools9':'10-stelliger Kundencode',
      'tools10':'Importieren',

      'upl1':'Bitte alle Felder korrekt ausfüllen',
      'upl2':'Bitte nur ganze Zahlen eingeben',
      'upl3':'Bitte mindestens eine Zeile ausfüllen',
      'upl4':'Tool erfolgreich hochgeladen!',
      'upl5':'Kundencode',
      'upl6':'10-stelliger Kundencode',
      'upl7':'Werkzeugname',
      'upl8':'Seriennummer',
      'upl9':'Druck / Drehmoment',
      'upl10':'Druck [{Value}]',
      'upl11':'Drehmoment [{Value}]',
      'upl12':'Am hochladen...',
      'upl13':'Hochladen',

      'temp1':'Verbunden',
      'temp2':'Nicht verbunden',

      'pdf1':'Nr.',
      'pdf2':'Solldruck [{Value}]',
      'pdf3':'Istdruck [Value]',
      'pdf4':'Solldrehmoment [Nm]',
      'pdf5':'Istdrehmoment [Nm]',
      'pdf6':'Datum',
      'pdf7':'Messwerte',

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
      'zurueck':'Zurück',
      'weiter':'Weiter',
    },
    'en': {
      'automatik1': 'Please enter the number of bolts',
      'automatik2': 'Number of bolts',
      'automatik3': 'Confirm',
      'automatik4': 'The bolting process was aborted by the user',
      'automatik5': 'Bolting process aborted after the first stroke due to strength check',
      'automatik6': 'Process aborted, bolt is tight',
      'automatik7': 'The bolt was loose at start',
      'automatik8': 'Process aborted, bolt is not tight',
      'automatik9': 'The bolt was not loose at start',
      'automatik10': 'All bolts tightened, please return to the main menu',
      'automatik11': 'WARNING: Actual pressure out of tolerance, please retighten or check tolerance',
      'automatik12': 'Bolting in progress...',
      'automatik13': 'Ready for bolting...',
      'automatik14': 'Target pressure: {value} {unit}',
      'automatik15': 'Bolt {value} of {unit}',
      'automatik16':  'An error has occurred with Bluetooth communication.\n Please confirm.',
      'automatik17':'An error has occurred with the pump\n click here to reconnect Bluetooth.',

      'bt1': 'Device connected!',
      'bt2': 'Error!',
      'bt3': 'Select device',

      'ch1': 'Continue with pressure input',
      'ch2': 'Continue with tool selection',

      'home1': 'Name',
      'home2': 'Please enter the name',
      'home3': 'Project number',
      'home4': 'Please enter the project number',
      'home5': 'Maximum of 15 characters allowed',
      'home6': 'Letters and numbers only',
      'home7': 'Tolerance',
      'home8': 'Please enter the tolerance',
      'home9': 'Pump serial number',
      'home10': 'Please enter the pump\'s serial number',
      'home11': 'Hose serial number',
      'home12': 'Please enter the hose serial number',
      'home13': 'Tool serial number',
      'home14': 'Please enter the tool serial number',
      'home15': 'Tool description',
      'home16': 'Please enter the tool description',

      'kal1':
      'To calibrate, detach the tool from the bolt and hold the START button.\n'
          'The pump will slowly increase pressure and perform three control strokes.',

      'man1':
      'To start the pump and extend the cylinder, press the START button.\n'
          'To retract the cylinder, release the START button.\n'
          'To stop the pump, press the STOP button.',

      'menu1': 'Automatic mode',
      'menu2': 'Manual bolting',
      'menu3': 'Back to pressure selection',

      'pres1': 'Pressure input 100 bar - 680 bar',
      'pres2': 'Pressure input 2176 PSI - 9427 PSI',
      'pres3': 'Please enter the pressure',
      'pres4': 'Target pressure must be between 100 and 680 bar',
      'pres5': 'Target pressure must be between 2716 and 9427 PSI',

      'set1': 'Select language',
      'set2': 'Mode',
      'set3': 'Automatic mode',
      'set4': 'Safety mode',
      'set5': 'Required fields',
      'set6': 'Name',
      'set7': 'Tool serial number',
      'set8': 'Hose serial number',
      'set9': 'Add tools to database',
      'set10':'Select pressure unit',
      'set11':'Legal Notices',
      'set12':'Privacy Notices',
      'set13':'Select pressure torque',
      'set14':'Export format',

      'tools1': 'Customer code must be 10 digits!',
      'tools2': 'Error loading tools',
      'tools3': 'Torque ',
      'tools4': 'Please enter a valid torque value',
      'tools5': 'Error: Torque out of range ({minTorque}-{maxTorque} Nm)',
      'tools6': 'Error: Interpolated pressure value {value} bar out of range (100-680 bar)',
      'tools7': 'Interpolated pressure: {value} bar',
      'tools8': 'Customer code',
      'tools9': '10-digit customer code',
      'tools10': 'Import',

      'upl1': 'Please fill in all fields correctly',
      'upl2': 'Please enter whole numbers only',
      'upl3': 'Please fill in at least one row',
      'upl4': 'Tool successfully uploaded!',
      'upl5': 'Customer code',
      'upl6': '10-digit customer code',
      'upl7': 'Tool name',
      'upl8': 'Serial number',
      'upl9': 'Pressure / Torque',
      'upl10': 'Pressure {Value}',
      'upl11': 'Torque {Value}',
      'upl12': 'Uploading...',
      'upl13': 'Upload',

      'temp1':'Connected',
      'temp2':'Not connected',

      'pdf1':'No.',
      'pdf2':'Target pressure [{Value}]',
      'pdf3':'Actual pressure [{Value}]',
      'pdf4':'Target torque [{Value}]',
      'pdf5':'Actual torque [{Value}]',
      'pdf6':'Date',
      'pdf7':'Measurements',


      'name': 'Name',
      'project': 'Project number',
      'tolerance': 'Tolerance',
      'serial_pump': 'Pump serial number',
      'serial_tool': 'Tool serial number',
      'serial_hose': 'Hose serial number',
      'tool': 'Tool',
      'name_insert': 'Enter name',
      'project_insert': 'Enter project number',
      'tolerance_insert': 'Enter tolerance ±',
      'serial_pump_insert': 'Enter pump serial number',
      'serial_tool_insert': 'Enter tool serial number',
      'serial_hose_insert': 'Enter hose serial number',
      'tool_insert': 'Enter Tool description',
      'continue': 'Continue',
      'save_back': 'Save & Back',
      'language': 'Select language',
      'mode': 'Mode',
      'automatic': 'Automatic',
      'safety': 'Safety mode',
      'connected': 'Connected',
      'not_connected': 'Not connected',
      'zurueck': 'Back',
      'weiter': 'Next',

    },
  };


}
