library my_app_globals;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Variablen Datalog
String UserName="";
String Projectnumber="";
String Toleranz="";
String Serialpump="";
String Serialhose="";
String Serialtool="";
String Tool="";

//Einheitsauswahl
String DRUCK_EINHEIT = "Bar"; // default

//Empfangsvariablen
int? pwm;
int? referenzzeitkal;
int? vorreferenzzeit;
int? schraubennummer;
int? druckmax;
int? solldruck;

//Solldruckvariable
int SOLLDRUCK=0;
int SOLLDRUCKBAR=0;
int SOLLDRUCKPSI=0;
//Zustandsvariablen
bool Automatik = true;
bool isfehler=false;
bool iskalibriert=false;
bool isrunning=false;
bool isSchrauben=false;
bool iscomplete=false;
bool isaborted1=false;
bool isaborted2=false;
bool istorque=false;
bool isnotintol=false;
int akt_schraube=0;
int SCHRAUBENANZAHL=0;

//BLE
String Geraetename="";
bool connectedble=false;

String currentLanguage = 'en'; // Standard: Englisch

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  Automatik = prefs.getBool('Automatik') ?? true;
  currentLanguage = prefs.getString('language') ?? 'en';
  DRUCK_EINHEIT = prefs.getString('druckEinheit') ?? 'Bar'; // neue Zeile
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('Automatik', Automatik);
  await prefs.setString('language', currentLanguage);
  await prefs.setString('druckEinheit', DRUCK_EINHEIT); // neue Zeile
}

BluetoothDevice? bleDeviceForService;


