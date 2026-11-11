import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torquedoc/globals.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../utils/api_service.dart';
import '../utils/tool_model.dart';
import '../utils/translation.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';

class Toolsscreen extends StatefulWidget {
@override
_Toolsscreenstate createState() => _Toolsscreenstate();
}

class _Toolsscreenstate extends State<Toolsscreen> {
late TextEditingController customerCodeController;
late TextEditingController torqueController;

List<Tool1> tools = [];
Tool1? selectedTool;
bool isLoading = false;
String? errorMessage;
double? interpolatedPressure;

late final t = Provider.of<Translations>(context);

@override
void initState() {
super.initState();

customerCodeController = TextEditingController();
torqueController = TextEditingController();

_loadSavedData();

FlutterForegroundTask.initCommunicationPort();
FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
}

void _handleTaskData(dynamic data) {}

void _sendCommand(String cmd) {
debugPrint("[BLE_SCREEN] Sending command: $cmd");

FlutterForegroundTask.sendDataToTask({
'event': 'writeCommand',
'command': cmd,
});
}

@override
void dispose() {
customerCodeController.dispose();
torqueController.dispose();
super.dispose();
}

/// Kundencode und gespeicherte Tools laden
void _loadSavedData() async {
final prefs = await SharedPreferences.getInstance();

// Kundencode laden
final code = prefs.getString('lastCustomerCode');

debugPrint("[DEBUG] Loaded customerCode: $code");

if (code != null) {
      customerCodeController.text = code;
    } //Standart

/*if (code != null && code.startsWith('10019')) {
// Nur die letzten 5 Stellen ins TextField schreiben
customerCodeController.text = code.substring(5);
}*///Alki

// Tools laden
final jsonStr = prefs.getString('tools');

if (jsonStr != null) {
final data = jsonDecode(jsonStr) as List;
final savedTools = data.map((e) => Tool1.fromJson(e)).toList();

debugPrint(
"[DEBUG] Loaded tools: "
"${savedTools.map((t) => t.toolName).toList()}",
);

if (savedTools.isNotEmpty) {
setState(() {
tools = savedTools;
selectedTool = tools.first;
});
}
} else {
debugPrint("[DEBUG] No tools found in storage");
}
}

/// Tools speichern
Future<void> _saveTools(List<Tool1> tools) async {
final prefs = await SharedPreferences.getInstance();

final jsonStr = jsonEncode(tools.map((e) => e.toJson()).toList());

await prefs.setString('tools', jsonStr);

debugPrint(
"[DEBUG] Saved tools: ${tools.map((t) => t.toolName).toList()}",
);
}

/// Tools importieren
void _importTools() async {
final code = customerCodeController.text.trim(); //Standart
//final code = '10019${customerCodeController.text.trim()}'; //Alki

if (code.length != 10) {
setState(() {
errorMessage = t.text('tools1');
});
return;
}

setState(() {
isLoading = true;
errorMessage = null;
});

try {
final apiTools = await ApiService.getTools(code);

// Alte Tools überschreiben
await _saveTools(apiTools);

// Kundencode speichern
final prefs = await SharedPreferences.getInstance();
await prefs.setString('lastCustomerCode', code);

setState(() {
tools = apiTools;
selectedTool = apiTools.isNotEmpty ? apiTools.first : null;
});
} catch (e) {
setState(() {
errorMessage = t.text('tools2');
});
} finally {
setState(() {
isLoading = false;
});
}
}

/// Lineare Interpolation
double? interpolatePressure(Tool1 tool, double inputTorque) {
if (tool.torque.isEmpty || tool.pressure.isEmpty) return null;

List<double> torqueList =
tool.torque.map((e) => e.toDouble()).toList();

List<double> pressureList =
tool.pressure.map((e) => e.toDouble()).toList();

if (torqueList.length != pressureList.length) return null;

if (inputTorque <= torqueList.first) return pressureList.first;
if (inputTorque >= torqueList.last) return pressureList.last;

for (int i = 0; i < torqueList.length - 1; i++) {
if (inputTorque >= torqueList[i] &&
inputTorque <= torqueList[i + 1]) {
double x0 = torqueList[i];
double x1 = torqueList[i + 1];
double y0 = pressureList[i];
double y1 = pressureList[i + 1];

return y0 +
(inputTorque - x0) * (y1 - y0) / (x1 - x0);
}
}

return null;
}

/// Header im gleichen Design wie im Settingsscreen
Widget _buildHeader({
required String title,
required String subtitle,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColors.primary,
AppColors.primary.withValues(alpha: 0.82),
],
),
borderRadius: BorderRadius.circular(20),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 16,
offset: Offset(0, 6),
),
],
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: AppColors.white.withValues(alpha: 0.16),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.handyman_rounded,
color: AppColors.textOnPrimary,
size: 27,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: AppTextStyles.headline.copyWith(
color: AppColors.textOnPrimary,
fontSize: 22,
),
),
const SizedBox(height: 6),
Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: AppColors.textOnPrimary.withValues(alpha: 0.88),
fontSize: 14,
),
),
],
),
),
],
),
);
}

/// Einheitliche Überschrift für Kartenbereiche
Widget _buildSectionTitle(String title, {IconData? icon}) {
return Row(
children: [
if (icon != null) ...[
Icon(
icon,
size: 20,
color: AppColors.primary,
),
const SizedBox(width: 8),
],
Expanded(
child: Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 16,
fontWeight: FontWeight.w700,
),
),
),
],
);
}

/// Einheitliche Kartenoptik
Widget _buildCard({
required Widget child,
EdgeInsetsGeometry padding = const EdgeInsets.all(16),
}) {
return Container(
width: double.infinity,
padding: padding,
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 12,
offset: Offset(0, 4),
),
],
),
child: child,
);
}

/// Einheitliches Styling für Eingabefelder
InputDecoration _inputDecoration({
required String label,
String? hint,
String? prefixText,
String? errorText,
}) {
return InputDecoration(
labelText: label,
hintText: hint,
prefixText: prefixText,
errorText: errorText,
filled: true,
fillColor: AppColors.backgroundInput,
labelStyle: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
fontWeight: FontWeight.w500,
),
hintStyle: AppTextStyles.body.copyWith(
color: AppColors.textHint,
fontSize: 14,
fontWeight: FontWeight.normal,
),
prefixStyle: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
fontWeight: FontWeight.w600,
),
contentPadding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 16,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.border,
),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.border,
),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.primary,
width: 1.5,
),
),
errorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.error,
),
),
focusedErrorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.error,
width: 1.5,
),
),
);
}

@override
Widget build(BuildContext context) {
return WillPopScope(
onWillPop: () async => false,
child: AppTemplate(
child: GestureDetector(
behavior: HitTestBehavior.translucent,
onTap: () => FocusScope.of(context).unfocus(),
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header im gleichen Stil wie Settings
_buildHeader(
title: t.text('tools_title'),
subtitle: t.text('tools_subtitle'),
),

const SizedBox(height: 24),

// Ladeanzeige
if (isLoading) ...[
_buildCard(
child: const Padding(
padding: EdgeInsets.symmetric(vertical: 12),
child: Center(
child: CircularProgressIndicator(
color: AppColors.primary,
),
),
),
),
const SizedBox(height: 16),
],

// TOOL AUSWAHL
_buildCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildSectionTitle(
t.text('tools_section_selection'),
icon: Icons.handyman_outlined,
),

const SizedBox(height: 16),

if (tools.isNotEmpty)
DropdownButtonFormField<Tool1>(
value: selectedTool,
isExpanded: true,
icon: const Icon(
Icons.keyboard_arrow_down_rounded,
color: AppColors.textSecondary,
),
dropdownColor: AppColors.backgroundCard,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 14,
fontWeight: FontWeight.normal,
),
decoration: _inputDecoration(
label: t.text('tools_section_selection'),
),
items: tools.map((tool) {
final minTorque = tool.torque.reduce(
(a, b) => a < b ? a : b,
);

final maxTorque = tool.torque.reduce(
(a, b) => a > b ? a : b,
);

return DropdownMenuItem<Tool1>(
value: tool,
child: Text(
"${tool.toolName} (${tool.serialNumber})\n"
"Torque: "
"${convertNmToSelected(minTorque).toStringAsFixed(0)} - "
"${convertNmToSelected(maxTorque).toStringAsFixed(0)} "
"$DREHMOMENT_EINHEIT",
softWrap: true,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 14,
fontWeight: FontWeight.normal,
height: 1.5,
),
),
);
}).toList(),
onChanged: (tool) {
setState(() {
selectedTool = tool;
interpolatedPressure = null;
});
},
),

if (tools.isEmpty)
Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.lightBlue,
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
const Icon(
Icons.info_outline,
color: AppColors.primary,
size: 20,
),
const SizedBox(width: 10),
Expanded(
child: Text(
t.text('tools_empty'),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 14,
fontWeight: FontWeight.normal,
),
),
),
],
),
),
],
),
),

const SizedBox(height: 16),

// TORQUE EINGABE
_buildCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildSectionTitle(
t.text('tools_torque_section'),
icon: Icons.speed_rounded,
),

const SizedBox(height: 16),

TextField(
controller: torqueController,
keyboardType: TextInputType.number,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 16,
fontWeight: FontWeight.w600,
),
decoration: _inputDecoration(
label: '${t.text('tools3')} ($DREHMOMENT_EINHEIT)',
),
),

const SizedBox(height: 18),

// WEITER BUTTON
AppButtons.primaryText(
text: t.text('weiter'),
onPressed: () {
FocusScope.of(context).unfocus();

if (selectedTool == null) return;

final rawInput =
int.tryParse(torqueController.text);

if (rawInput == null) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(t.text('tools4')),
),
);
return;
}

// Umrechnung auf Nm
final inputTorque = convertTorqueToNm(rawInput);

final minTorque = selectedTool!.torque.reduce(
(a, b) => a < b ? a : b,
);

final maxTorque = selectedTool!.torque.reduce(
(a, b) => a > b ? a : b,
);

// Nutzer-Bereichsprüfung in ausgewählter Einheit
if (rawInput < convertNmToSelected(minTorque) ||
rawInput > convertNmToSelected(maxTorque)) {
String errorText = t.textArgs(
'tools5',
{
'minTorque': convertNmToSelected(minTorque)
    .toStringAsFixed(0),
'maxTorque': convertNmToSelected(maxTorque)
    .toStringAsFixed(0),
},
);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(errorText),
),
);
return;
}

final pressure = interpolatePressure(
selectedTool!,
inputTorque.toDouble(),
);

if (pressure != null &&
(pressure < 150 || pressure > 680)) {
String errorText = t.textArgs(
'tools6',
{
'value': pressure.toStringAsFixed(2),
},
);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(errorText),
),
);
return;
}

setState(() => interpolatedPressure = pressure);

String success = t.textArgs(
'tools7',
{
'value': pressure?.toStringAsFixed(2),
},
);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(success),
),
);

SOLLDRUCK = pressure!.toInt();
SOLLDRUCKBAR = SOLLDRUCK;
SOLLDRUCKPSI = (SOLLDRUCK * 14.503).round();
iskalibriert = false;

final tool = selectedTool!;

FlutterForegroundTask.sendDataToTask({
'event': 'setToolData',
'Solltorque': inputTorque.toInt(),
'toolName': tool.toolName,
'torque': tool.torque,
'pressure': tool.pressure,
'command': '-SETP $SOLLDRUCK\$',
});

istorque = true;
TOOLNAME = tool.toolName;
SOLLTORQUE = inputTorque.toInt();
TORQUELIST = tool.torque;
PRESSURELIST = tool.pressure;

Navigator.pushNamed(context, '/kalibration');
},
),
],
),
),

const SizedBox(height: 12),

// ZURÜCK BUTTON
AppButtons.primaryText(
text: t.text('zurueck'),
onPressed: () => Navigator.pop(context),
  backgroundColor: AppColors.secondary,
verticalPadding: 16,
),

const SizedBox(height: 28),

// KUNDENCODE UND TOOL-IMPORT
_buildCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildSectionTitle(
t.text('tools_import_section'),
icon: Icons.cloud_download_outlined,
),

const SizedBox(height: 8),

Text(
t.text('tools_import_description'),
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 13,
fontWeight: FontWeight.normal,
height: 1.4,
),
),

const SizedBox(height: 18),
/*
TextField(
controller: customerCodeController,
decoration: _inputDecoration(
label: t.text('tools8'),
hint: 'XXXXX',
prefixText: '10019',
errorText: errorMessage,
),
keyboardType: TextInputType.number,
inputFormatters: [
LengthLimitingTextInputFormatter(5),
FilteringTextInputFormatter.digitsOnly,
],
onChanged: (v) async {
final prefs =
await SharedPreferences.getInstance();

prefs.setString('lastCustomerCode', '10019$v');
},
),*/ //Alki

 TextField(
                        controller: customerCodeController,
                        decoration: InputDecoration(
                          labelText: t.text('tools8'),
                          hintText: t.text('tools9'),
                          errorText: errorMessage,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ), //Standart

const SizedBox(height: 16),

AppButtons.primaryText(
text: t.text('tools10'),
onPressed: () {
FocusScope.of(context).unfocus();
_importTools();
},
verticalPadding: 16,
),
],
),
),

const SizedBox(height: 24),
],
),
),
),
),
);
}
}