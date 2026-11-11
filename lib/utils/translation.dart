import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations extends ChangeNotifier {
  Translations({String? initialLanguage}) {
    if (initialLanguage != null &&
        _localizedValues.containsKey(initialLanguage)) {
      _currentLanguage = initialLanguage;
    }
  }

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  /// Übersetzten Text zurückgeben.
  String text(String key) {
    return _localizedValues[_currentLanguage]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// Übersetzten Text mit Platzhaltern zurückgeben.
  String textArgs(String key, Map<String, dynamic> args) {
    String result = text(key);

    args.forEach((name, value) {
      result = result.replaceAll('{$name}', value.toString());
    });

    return result;
  }

  /// Sprache ändern und speichern.
  Future<void> setLocale(String languageCode) async {
    if (!_localizedValues.containsKey(languageCode)) {
      return;
    }

    _currentLanguage = languageCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('languageCode', languageCode);
  }

  /// Gespeicherte Sprache laden.
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLang = prefs.getString('languageCode') ?? 'en';

    _currentLanguage = _localizedValues.containsKey(savedLang)
        ? savedLang
        : 'en';

    notifyListeners();
  }

  final Map<String, Map<String, String>> _localizedValues = {
    'de': {
      // ========================================================
      // AUTOMATIK
      // ========================================================

      'automatik1': 'Bitte Anzahl der Schrauben eingeben',
      'automatik2': 'Anzahl Schrauben',
      'automatik3': 'Bestätigen',
      'automatik4': 'Der Schraubvorgang wurde vom Nutzer abgebrochen',
      'automatik5':
      'Schraubvorgang nach dem ersten Hub aufgrund der Festigkeitsprüfung abgebrochen',
      'automatik6': 'Vorgang abgebrochen, Schraube ist fest',
      'automatik7': 'Die Schraube war beim Start lose',
      'automatik8': 'Vorgang abgebrochen, Schraube ist nicht fest',
      'automatik9': 'Die Schraube war beim Start nicht lose',
      'automatik10':
      'Alle Schrauben angezogen, bitte zurück zum Hauptmenü',
      'automatik11':
      'WARNUNG: Istdruck nicht in Toleranz, bitte erneut anziehen oder Toleranz prüfen',
      'automatik12': 'Verschrauben läuft...',
      'automatik13': 'Bereit zum Verschrauben...',
      'automatik14': 'Solldruck: {value} {unit}',
      'automatik15': 'Schraube {value} von {unit}',
      'automatik16':
      'Es ist ein Fehler mit der Bluetooth-Kommunikation aufgetreten.\nBitte bestätigen.',
      'automatik17':
      'Es ist ein Fehler an der Pumpe aufgetreten.\nHier klicken, um Bluetooth neu zu verbinden.',

      // ========================================================
      // BLUETOOTH
      // ========================================================

      'bt1': 'Gerät verbunden!',
      'bt2': 'Fehler!',
      'bt3': 'Gerät auswählen',

      'bt_title': 'Bluetooth',
      'bt_subtitle': 'Geräte suchen und verbinden',

      'bt_status': 'Verbindungsstatus',
      'bt_status_description':
      'Aktueller Zustand der Bluetooth-Verbindung',

      'bt_connected': 'Verbunden',
      'bt_scanning': 'Suche nach Geräten',
      'bt_disconnected': 'Nicht verbunden',

      'bt_select_device': 'Gerät auswählen',
      'bt_device_label': 'Gefundenes Bluetooth-Gerät',
      'bt_no_devices': 'Noch keine Geräte gefunden',
      'bt_selected_device': 'Ausgewähltes Gerät',

      'bt_scan': 'Bluetooth-Geräte suchen',
      'bt_scan_again': 'Erneut suchen',

      'bt_permission_error':
      'Bluetooth-Berechtigungen werden benötigt!',

      'bt_scan_notification_title': 'Bluetooth-Dienst',
      'bt_scan_notification_text': 'Suche nach Geräten...',

      'bt_search_hint': 'Wähle ein Gerät aus der Liste aus.',

      'bt_device_count_zero': 'Keine Geräte gefunden',
      'bt_device_count_one': '1 Gerät gefunden',
      'bt_device_count_many': '{count} Geräte gefunden',

      // ========================================================
      // AUSWAHL
      // ========================================================

      'ch1': 'Weiter mit Druckeingabe',
      'ch2': 'Weiter mit Werkzeugauswahl',

      // ========================================================
      // HOME
      // ========================================================

      'home1': 'Name',
      'home2': 'Bitte den Namen eingeben',
      'home3': 'Projektnummer',
      'home4': 'Bitte die Projektnummer eingeben',
      'home5': 'Maximal 15 Zeichen erlaubt',
      'home6': 'Nur Buchstaben und Zahlen erlaubt',
      'home7': 'Toleranz',
      'home8': 'Bitte die Toleranz eingeben',
      'home9': 'Seriennummer Pumpe',
      'home10': 'Bitte die Seriennummer der Pumpe eingeben',
      'home11': 'Seriennummer Schlauch',
      'home12': 'Bitte die Seriennummer des Schlauchs eingeben',
      'home13': 'Seriennummer Werkzeug',
      'home14': 'Bitte die Seriennummer des Werkzeugs eingeben',
      'home15': 'Werkzeug',
      'home16': 'Bitte die Werkzeugbeschreibung eingeben',

      // ========================================================
      // KALIBRIERUNG
      // ========================================================

      'kal1':
      'Zum Kalibrieren Werkzeug von der Schraube lösen und START gedrückt halten.\n'
          'Die Pumpe fährt den Druck langsam an und führt drei Kontrollhübe durch.',

      // ========================================================
      // MANUELL
      // ========================================================

      'man1':
      'Zum Starten der Pumpe und Ausfahren des Zylinders die START-Taste drücken.\n'
          'Zum Einfahren des Zylinders die START-Taste loslassen.\n'
          'Zum Stoppen der Pumpe die STOP-Taste drücken.',

      // ========================================================
      // MENÜ
      // ========================================================

      'menu1': 'Automatikmodus',
      'menu2': 'Manuelles Verschrauben',
      'menu3': 'Zurück zur Druckauswahl',

      // ========================================================
      // DRUCK
      // ========================================================

      'pres1': 'Druckeingabe 150 bar – 680 bar',
      'pres2': 'Druckeingabe 2176 PSI – 9427 PSI',
      'pres3': 'Bitte geben Sie den Druck ein',
      'pres4': 'Solldruck muss zwischen 150 und 680 bar liegen',
      'pres5': 'Solldruck muss zwischen 2716 und 9427 PSI liegen',

      // ========================================================
      // EINSTELLUNGEN
      // ========================================================

      'set1': 'Sprache auswählen',
      'set2': 'Modus',
      'set3': 'Automatikmodus',
      'set4': 'Sicherheitsmodus',
      'set5': 'Pflichtfelder',
      'set6': 'Name',
      'set7': 'Seriennummer Werkzeug',
      'set8': 'Seriennummer Schlauch',
      'set9': 'Werkzeuge in Datenbank einpflegen',
      'set10': 'Druckeinheit auswählen',
      'set11': 'Impressum',
      'set12': 'Datenschutz',
      'set13': 'Drehmomenteinheit auswählen',
      'set14': 'Export-Format',

      // ========================================================
      // WERKZEUGE
      // ========================================================

      'tools1': 'Kundencode muss 10-stellig sein!',
      'tools2': 'Fehler beim Laden der Tools',
      'tools3': 'Drehmoment (Nm)',
      'tools4': 'Bitte gültiges Drehmoment eingeben',
      'tools5':
      'Fehler: Drehmoment außerhalb des Bereichs ({minTorque}-{maxTorque} Nm)',
      'tools6':
      'Fehler: interpolierter Druckwert {value} bar außerhalb des Bereichs (150–680 bar)',
      'tools7': 'Interpolierter Druck: {value} bar',
      'tools8': 'Kundencode',
      'tools9': '10-stelliger Kundencode',
      'tools10': 'Importieren',

      // ========================================================
      // UPLOAD
      // ========================================================

      'upl1': 'Bitte alle Felder korrekt ausfüllen',
      'upl2': 'Bitte nur ganze Zahlen eingeben',
      'upl3': 'Bitte mindestens eine Zeile ausfüllen',
      'upl4': 'Tool erfolgreich hochgeladen!',
      'upl5': 'Kundencode',
      'upl6': '10-stelliger Kundencode',
      'upl7': 'Werkzeugname',
      'upl8': 'Seriennummer',
      'upl9': 'Druck / Drehmoment',
      'upl10': 'Druck [{Value}]',
      'upl11': 'Drehmoment [{Value}]',
      'upl12': 'Am Hochladen...',
      'upl13': 'Hochladen',

      // ========================================================
      // APP-TEMPLATE
      // ========================================================

      'temp1': 'Verbunden',
      'temp2': 'Nicht verbunden',

      // ========================================================
      // PDF
      // ========================================================

      'pdf1': 'Nr.',
      'pdf2': 'Solldruck [{Value}]',
      'pdf3': 'Istdruck [{Value}]',
      'pdf4': 'Solldrehmoment [{Value}]',
      'pdf5': 'Istdrehmoment [{Value}]',
      'pdf6': 'Datum',
      'pdf7': 'Messwerte',
      'pdf8':'Graphische Auswertung',

      // ========================================================
      // ALLGEMEINE FELDER
      // ========================================================

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
      'tool_insert': 'Werkzeugbeschreibung',
      'continue': 'Weiter',
      'save_back': 'Speichern & Zurück',
      'language': 'Sprache auswählen',
      'mode': 'Modus',
      'automatic': 'Automatik',
      'safety': 'Sicherheitsmodus',
      'connected': 'Verbunden',
      'not_connected': 'Nicht verbunden',
      'zurueck': 'Zurück',
      'weiter': 'Weiter',
      'home_title': 'Projektdaten',
      'home_subtitle': 'Gib die Projektdaten und Gerätedetails ein.',
      'home_project_section': 'Projektinformationen',
      'home_equipment_section': 'Geräteinformationen',
      'project_error_length': 'Maximal 15 Zeichen erlaubt',
      'project_error_characters': 'Nur Buchstaben und Zahlen erlaubt',
      'storage_permission_required': 'Speicherzugriff benötigt!',
      'project_file_exists': 'Ein Protokoll für dieses Projekt existiert bereits!',
      'settings_title': 'Einstellungen',
      'settings_subtitle': 'Passe die Anwendung an deine Anforderungen an.',
      'settings_german': 'Deutsch',
      'settings_english': 'Englisch',
      'settings_mode_section': 'Betriebsmodus',
      'settings_mode_label': 'Modus auswählen',
      'settings_csv': 'CSV-Export',
      'settings_csv_description': 'Messdaten als CSV-Datei speichern',
      'settings_pdf': 'PDF-Protokoll',
      'settings_pdf_description': 'Messprotokoll als PDF-Datei speichern',
      'settings_units_section': 'Einheiten',
      'settings_name_required_description': 'Name muss eingegeben werden',
      'settings_tool_required_description': 'Werkzeug-Seriennummer muss eingegeben werden',
      'settings_hose_required_description': 'Schlauch-Seriennummer muss eingegeben werden',
      'settings_update_section': 'Software',
      'settings_legal_section': 'Rechtliches',
      'set_url_error': 'Die Seite konnte nicht geöffnet werden',
      'tools_title': 'Werkzeugauswahl',
      'tools_subtitle': 'Wähle dein Werkzeug aus und gib das gewünschte Drehmoment ein.',
      'tools_section_selection': 'Werkzeug auswählen',
      'tools_empty': 'Noch keine Werkzeuge geladen. Bitte gib deinen Kundencode ein und importiere deine Werkzeuge.',
      'tools_torque_section': 'Drehmoment einstellen',
      'tools_import_section': 'Werkzeuge importieren',
      'tools_import_description': 'Gib deinen Kundencode ein, um die verfügbaren Werkzeuge zu laden.',
      'upload_title': 'Werkzeug hochladen',
      'upload_subtitle': 'Hinterlege ein Werkzeug mit Seriennummer und Druck-Drehmoment-Werten.',
      'upload_tool_details': 'Werkzeugdetails',
      'selection_title': 'Sollwertvorgabe auswählen',
      'selection_subtitle': 'Wähle aus, mit welcher Sollwertvorgabe Sie arbeiten möchten.',
      'selection_section': 'Verfügbare Sollwertvorgaben',
      'selection_pressure_title': 'Druck',
      'selection_pressure_description': 'Sollwert über Druck auswählen dort fortfahren.',
      'selection_tools_title': 'Drehmoment',
      'selection_tools_description': 'Druck durch Werkzeugauswahl und Drehmoment ermitteln',
      'calibration_title': 'Kalibrierung',
      'calibration_subtitle': 'Das System bereitet sich auf den nächsten Arbeitsschritt vor.',
      'calibration_status_title': 'Kalibrierungsstatus',
      'calibration_wait_description': 'Bitte warten. Die Kalibrierung wird durchgeführt.',
      'calibration_complete_title': 'Kalibrierung abgeschlossen',
      'calibration_complete_description': 'Das System ist bereit. Du kannst fortfahren.',
      'auto_header_title': 'Automatische Verschraubung',
      'auto_header_subtitle': 'Lege die Anzahl der Schrauben fest und verfolge den Fortschritt der Verschraubung.',
      'manual_header_title': 'Manueller Betrieb',
      'manual_header_subtitle': 'Steuere den Schraubvorgang manuell und behalte den Systemstatus im Blick.',
      'manual_status_title': 'Manueller Betrieb aktiv',
      'manual_error_description': 'Es ist ein Fehler aufgetreten. Du kannst den manuellen Betrieb erneut starten.',
      'manual_disconnected_description': 'Die Bluetooth-Verbindung wurde unterbrochen. Verbinde das Gerät erneut, um fortzufahren.',
      'menu_header_title': 'Betriebsmodus auswählen',
      'menu_header_subtitle': 'Wähle, ob du die Verschraubung automatisch oder manuell durchführen möchtest.',
      'menu_card_auto_title': 'Automatischer Betrieb',
      'menu_card_auto_description': 'Führe mehrere Verschraubungen nacheinander durch und verfolge den Fortschritt.',
      'menu_card_manual_title': 'Manueller Betrieb',
      'menu_card_manual_description': 'Steuere den Schraubvorgang manuell über das verbundene System.',
      'menu_card_back_title': 'Zurück zur Auswahl',
      'menu_card_back_description': 'Kehre zur vorherigen Auswahl der Sollwertvorgabe zurück.',
    },

    'en': {
      // ========================================================
      // AUTOMATIC
      // ========================================================

      'automatik1': 'Please enter the number of bolts',
      'automatik2': 'Number of bolts',
      'automatik3': 'Confirm',
      'automatik4': 'The bolting process was aborted by the user',
      'automatik5':
      'Bolting process aborted after the first stroke due to strength check',
      'automatik6': 'Process aborted, bolt is tight',
      'automatik7': 'The bolt was loose at start',
      'automatik8': 'Process aborted, bolt is not tight',
      'automatik9': 'The bolt was not loose at start',
      'automatik10':
      'All bolts tightened, please return to the main menu',
      'automatik11':
      'WARNING: Actual pressure out of tolerance, please retighten or check tolerance',
      'automatik12': 'Bolting in progress...',
      'automatik13': 'Ready for bolting...',
      'automatik14': 'Target pressure: {value} {unit}',
      'automatik15': 'Bolt {value} of {unit}',
      'automatik16':
      'An error has occurred with Bluetooth communication.\nPlease confirm.',
      'automatik17':
      'An error has occurred with the pump.\nClick here to reconnect Bluetooth.',

      // ========================================================
      // BLUETOOTH
      // ========================================================

      'bt1': 'Device connected!',
      'bt2': 'Error!',
      'bt3': 'Select device',

      'bt_title': 'Bluetooth',
      'bt_subtitle': 'Search for and connect devices',

      'bt_status': 'Connection status',
      'bt_status_description': 'Current Bluetooth connection status',

      'bt_connected': 'Connected',
      'bt_scanning': 'Searching for devices',
      'bt_disconnected': 'Not connected',

      'bt_select_device': 'Select device',
      'bt_device_label': 'Discovered Bluetooth device',
      'bt_no_devices': 'No devices found yet',
      'bt_selected_device': 'Selected device',

      'bt_scan': 'Search for Bluetooth devices',
      'bt_scan_again': 'Scan again',

      'bt_permission_error': 'Bluetooth permissions are required!',

      'bt_scan_notification_title': 'Bluetooth service',
      'bt_scan_notification_text': 'Searching for devices...',

      'bt_search_hint': 'Select a device from the list.',

      'bt_device_count_zero': 'No devices found',
      'bt_device_count_one': '1 device found',
      'bt_device_count_many': '{count} devices found',

      // ========================================================
      // SELECTION
      // ========================================================

      'ch1': 'Continue with pressure input',
      'ch2': 'Continue with tool selection',

      // ========================================================
      // HOME
      // ========================================================

      'home1': 'Name',
      'home2': 'Please enter the name',
      'home3': 'Project number',
      'home4': 'Please enter the project number',
      'home5': 'Maximum of 15 characters allowed',
      'home6': 'Letters and numbers only',
      'home7': 'Tolerance',
      'home8': 'Please enter the tolerance',
      'home9': 'Pump serial number',
      'home10': 'Please enter the pump serial number',
      'home11': 'Hose serial number',
      'home12': 'Please enter the hose serial number',
      'home13': 'Tool serial number',
      'home14': 'Please enter the tool serial number',
      'home15': 'Tool',
      'home16': 'Please enter the tool description',

      // ========================================================
      // CALIBRATION
      // ========================================================

      'kal1':
      'To calibrate, detach the tool from the bolt and hold the START button.\n'
          'The pump will slowly increase pressure and perform three control strokes.',

      // ========================================================
      // MANUAL
      // ========================================================

      'man1':
      'To start the pump and extend the cylinder, press the START button.\n'
          'To retract the cylinder, release the START button.\n'
          'To stop the pump, press the STOP button.',

      // ========================================================
      // MENU
      // ========================================================

      'menu1': 'Automatic mode',
      'menu2': 'Manual bolting',
      'menu3': 'Back to pressure selection',

      // ========================================================
      // PRESSURE
      // ========================================================

      'pres1': 'Pressure input 150 bar – 680 bar',
      'pres2': 'Pressure input 2176 PSI – 9427 PSI',
      'pres3': 'Please enter the pressure',
      'pres4': 'Target pressure must be between 150 and 680 bar',
      'pres5': 'Target pressure must be between 2716 and 9427 PSI',

      // ========================================================
      // SETTINGS
      // ========================================================

      'set1': 'Select language',
      'set2': 'Mode',
      'set3': 'Automatic mode',
      'set4': 'Safety mode',
      'set5': 'Required fields',
      'set6': 'Name',
      'set7': 'Tool serial number',
      'set8': 'Hose serial number',
      'set9': 'Add tools to database',
      'set10': 'Select pressure unit',
      'set11': 'Legal notice',
      'set12': 'Privacy notice',
      'set13': 'Select torque unit',
      'set14': 'Export format',

      // ========================================================
      // TOOLS
      // ========================================================

      'tools1': 'Customer code must be 10 digits!',
      'tools2': 'Error loading tools',
      'tools3': 'Torque (Nm)',
      'tools4': 'Please enter a valid torque value',
      'tools5': 'Error: Torque out of range ({minTorque}-{maxTorque} Nm)',
      'tools6':
      'Error: Interpolated pressure value {value} bar out of range (150–680 bar)',
      'tools7': 'Interpolated pressure: {value} bar',
      'tools8': 'Customer code',
      'tools9': '10-digit customer code',
      'tools10': 'Import',

      // ========================================================
      // UPLOAD
      // ========================================================

      'upl1': 'Please fill in all fields correctly',
      'upl2': 'Please enter whole numbers only',
      'upl3': 'Please fill in at least one row',
      'upl4': 'Tool successfully uploaded!',
      'upl5': 'Customer code',
      'upl6': '10-digit customer code',
      'upl7': 'Tool name',
      'upl8': 'Serial number',
      'upl9': 'Pressure / Torque',
      'upl10': 'Pressure [{Value}]',
      'upl11': 'Torque [{Value}]',
      'upl12': 'Uploading...',
      'upl13': 'Upload',

      // ========================================================
      // APP-TEMPLATE
      // ========================================================

      'temp1': 'Connected',
      'temp2': 'Not connected',

      // ========================================================
      // PDF
      // ========================================================

      'pdf1': 'No.',
      'pdf2': 'Target pressure [{Value}]',
      'pdf3': 'Actual pressure [{Value}]',
      'pdf4': 'Target torque [{Value}]',
      'pdf5': 'Actual torque [{Value}]',
      'pdf6': 'Date',
      'pdf7': 'Measurements',

      // ========================================================
      // GENERAL FIELDS
      // ========================================================

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
      'tool_insert': 'Enter tool description',
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
      'home_title': 'Project details',
      'home_subtitle': 'Enter the project details and equipment information.',
      'home_project_section': 'Project information',
      'home_equipment_section': 'Equipment information',
      'project_error_length': 'A maximum of 15 characters is allowed',
      'project_error_characters': 'Only letters and numbers are allowed',
      'storage_permission_required': 'Storage access is required!',
      'project_file_exists': 'A report for this project already exists!',
      'settings_title': 'Settings',
      'settings_subtitle': 'Customize the application to suit your needs.',
      'settings_german': 'German',
      'settings_english': 'English',
      'settings_mode_section': 'Operating mode',
      'settings_mode_label': 'Select mode',
      'settings_csv': 'CSV export',
      'settings_csv_description': 'Save measurement data as a CSV file',
      'settings_pdf': 'PDF report',
      'settings_pdf_description': 'Save the measurement report as a PDF file',
      'settings_units_section': 'Units',
      'settings_name_required_description': 'Name is required',
      'settings_tool_required_description': 'Tool serial number is required',
      'settings_hose_required_description': 'Hose serial number is required',
      'settings_update_section': 'Software',
      'settings_legal_section': 'Legal information',
      'set_url_error': 'The page could not be opened',
      'tools_title': 'Tool selection',
      'tools_subtitle': 'Select your tool and enter the desired torque.',
      'tools_section_selection': 'Select tool',
      'tools_empty': 'No tools loaded yet. Enter your customer code and import your tools.',
      'tools_torque_section': 'Set torque',
      'tools_import_section': 'Import tools',
      'tools_import_description': 'Enter your customer code to load the available tools.',
      'upload_title': 'Upload tool',
      'upload_subtitle': 'Register a tool with its serial number and pressure-torque values.',
      'upload_tool_details': 'Tool details',
      'selection_title': 'Select Setpoint Type',
      'selection_subtitle': 'Choose which setpoint type you would like to work with.',
      'selection_section': 'Available Setpoint Types',
      'selection_pressure_title': 'Pressure',
      'selection_pressure_description': 'Set the setpoint using pressure and continue.',
      'selection_tools_title': 'Torque',
      'selection_tools_description': 'Determine the pressure using tool selection and torque.',
      'calibration_title': 'Calibration',
      'calibration_subtitle': 'The system is preparing for the next step.',
      'calibration_status_title': 'Calibration Status',
      'calibration_wait_description': 'Please wait while calibration is in progress.',
      'calibration_complete_title': 'Calibration Complete',
      'calibration_complete_description': 'The system is ready. You can continue.',
      'auto_header_title': 'Automatic Tightening',
      'auto_header_subtitle': 'Set the number of screws and monitor the tightening process.',
      'manual_header_title': 'Manual Operation',
      'manual_header_subtitle': 'Control the tightening process manually and monitor the system status.',
      'manual_status_title': 'Manual Operation Active',
      'manual_error_description': 'An error occurred. You can restart manual operation.',
      'manual_disconnected_description': 'The Bluetooth connection was interrupted. Reconnect the device to continue.',
      'menu_header_title': 'Select Operating Mode',
      'menu_header_subtitle': 'Choose whether you want to perform tightening automatically or manually.',
      'menu_card_auto_title': 'Automatic Operation',
      'menu_card_auto_description': 'Perform multiple tightening operations in sequence and monitor progress.',
      'menu_card_manual_title': 'Manual Operation',
      'menu_card_manual_description': 'Control the tightening process manually using the connected system.',
      'menu_card_back_title': 'Back to Selection',
      'menu_card_back_description': 'Return to the previous setpoint selection.',
      'pdf8':'Graphical Analysis',

},
  };
}