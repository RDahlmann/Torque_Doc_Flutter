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

int? pwm;
int? referenzzeitkal;
int? vorreferenzzeit;
int? schraubennummer;
int? druckmax;
int? solldruck;

//Zustandsvariablen
bool Automatik = true;
bool isfehler=false;
bool iskalibriert=false;
bool isrunning=false;

//BLE
String Geraetename="";
bool connectedble=false;

String currentLanguage = 'en'; // Standard: Englisch

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  Automatik = prefs.getBool('Automatik') ?? true;
  currentLanguage = prefs.getString('language') ?? 'en';
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('Automatik', Automatik);
  await prefs.setString('language', currentLanguage);
}

BluetoothDevice? bleDeviceForService;


