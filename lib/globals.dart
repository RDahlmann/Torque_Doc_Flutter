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
String DREHMOMENT_EINHEIT = "Nm"; // default

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
int SOLLDREHMOMENT=0;
int SOLLDREHMOMENTNM=0;
int SOLLDREHMOMENTFTLBS=0;
int SOLLTORQUE=0;



//Zustandsvariablen
bool Automatik = true;
bool isfehler=false;
bool iskalibriert=false;
bool isrunning=false;
bool isSchrauben=false;
bool iscomplete=false;
bool isaborted1=false;
bool isaborted2=false;
bool isnotintol=false;
bool isnotconnected=false;
bool ISCSV=false;
bool ISPDF=false;
int akt_schraube=0;
int SCHRAUBENANZAHL=0;
bool isdisconnect=false;
bool istorque=false;
List<Map<String, dynamic>> BLE_WertelisteGlobal = [];

String TOOLNAME="";
List<int> TORQUELIST=[];
List<int> PRESSURELIST=[];
//BLE
String Geraetename="";
bool connectedble=false;

String currentLanguage = 'en'; // Standard: Englisch

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  Automatik = prefs.getBool('Automatik') ?? true;
  currentLanguage = prefs.getString('language') ?? 'en';
  DRUCK_EINHEIT = prefs.getString('druckEinheit') ?? 'Bar'; // neue Zeile
  DREHMOMENT_EINHEIT=prefs.getString('drehmomentEinheit')??'Nm';
  ISCSV=prefs.getBool('iscsv')??true;
  ISPDF=prefs.getBool('ispdf')??true;
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('Automatik', Automatik);
  await prefs.setBool('iscsv', ISCSV);
  await prefs.setBool('ispdf', ISPDF);
  await prefs.setString('language', currentLanguage);
  await prefs.setString('druckEinheit', DRUCK_EINHEIT); // neue Zeile
  await prefs.setString('drehmomentEinheit', DREHMOMENT_EINHEIT); // neue Zeile
}

BluetoothDevice? bleDeviceForService;

int convertTorqueToNm(int value) {
  if (DREHMOMENT_EINHEIT == "Nm") return value;
  return (value / 0.737562149).round(); // ft.lbs → Nm
}

int convertNmToSelected(int value) {
  if (DREHMOMENT_EINHEIT == "Nm") return value;
  return (value * 0.737562149).round(); // Nm → ft.lbs
}

