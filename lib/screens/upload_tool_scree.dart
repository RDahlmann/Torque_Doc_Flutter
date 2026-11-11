import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../utils/translation.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';

class UploadToolScreen extends StatefulWidget {
@override
_UploadToolScreenState createState() => _UploadToolScreenState();
}

class _UploadToolScreenState extends State<UploadToolScreen> {
final _customerController = TextEditingController();
final _nameController = TextEditingController();
final _serialController = TextEditingController();

List<TextEditingController> pressureControllers = [];
List<TextEditingController> torqueControllers = [];

bool isUploading = false;

@override
void initState() {
super.initState();
_loadSavedData();
}

Future<void> _loadSavedData() async {
final prefs = await SharedPreferences.getInstance();

// Kundencode laden
final savedCustomer = prefs.getString('customerCode');
    if (savedCustomer != null) {
      _customerController.text = savedCustomer;
    } //Standart

/*final savedCustomer = prefs.getString('customerCode');
if (savedCustomer != null && savedCustomer.startsWith('10019')) {
_customerController.text = savedCustomer.substring(5);
}*/ //Alki

// Druckwerte laden
final savedPressure = prefs.getString('saved_pressure_values');
List<String> loaded = [];

if (savedPressure != null) {
loaded = List<String>.from(jsonDecode(savedPressure));
}

// Controller initialisieren
pressureControllers =
loaded.map((v) => TextEditingController(text: v)).toList();

torqueControllers =
loaded.map((_) => TextEditingController(text: '')).toList();

// Immer mindestens eine leere Zeile anhängen
pressureControllers.add(TextEditingController());
torqueControllers.add(TextEditingController());

setState(() {});
}

void _savePressureValues() async {
final prefs = await SharedPreferences.getInstance();

final List<String> pressureList = pressureControllers
    .map((c) => c.text)
    .where((p) => p.isNotEmpty)
    .toList();

prefs.setString('saved_pressure_values', jsonEncode(pressureList));
}

void _checkAddRow() {
final lastIndex = pressureControllers.length - 1;

if (pressureControllers[lastIndex].text.isNotEmpty ||
torqueControllers[lastIndex].text.isNotEmpty) {
setState(() {
pressureControllers.add(TextEditingController());
torqueControllers.add(TextEditingController());
});
}
}

Future<void> _uploadTool() async {
final customer = _customerController.text.trim();
final name = _nameController.text.trim();
final serial = _serialController.text.trim();
//
if (customer.length != 10 || name.isEmpty || serial.isEmpty) {
      final te = Provider.of<Translations>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(te.text('upl1'))),
      );
      return;
    } //Standart
/*
final fullCustomerCode = '10019${_customerController.text}';

if (fullCustomerCode.length != 10 ||
name.isEmpty ||
serial.isEmpty) {
final te = Provider.of<Translations>(context, listen: false);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(te.text('upl1'))),
);

return;
} *///Alkitronik

List<int> pressure = [];
List<int> torque = [];

for (int i = 0; i < pressureControllers.length; i++) {
final pText = pressureControllers[i].text;
final tText = torqueControllers[i].text;

if (pText.isEmpty || tText.isEmpty) continue;

final p = int.tryParse(pText);
final t = int.tryParse(tText);

if (p == null || t == null) {
final te = Provider.of<Translations>(context, listen: false);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(te.text('upl2'))),
);

return;
}

final pressureValue =
DRUCK_EINHEIT == 'PSI' ? (p / 14.503).round() : p;

final torqueValue =
DREHMOMENT_EINHEIT == 'Nm' ? t : convertTorqueToNm(t);

pressure.add(pressureValue);
torque.add(torqueValue);
}

if (pressure.isEmpty || torque.isEmpty) {
final te = Provider.of<Translations>(context, listen: false);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(te.text('upl3'))),
);

return;
}
//
 final payload = {
      'customer_code': customer,
      'tool_name': name,
      'serial_number': serial,
      'torque': jsonEncode(torque),
      'pressure': jsonEncode(pressure),
    };//Standart

/*final payload = {
'customer_code': fullCustomerCode,
'tool_name': name,
'serial_number': serial,
'torque': jsonEncode(torque),
'pressure': jsonEncode(pressure),
}; *///Alki

setState(() => isUploading = true);

try {
final res = await http.post(
Uri.parse(
'https://www.stephandahlmann.com/tool_api/upload_tool.php',
),
body: payload,
);

if (res.body.isEmpty) {
throw Exception('Leere Antwort vom Server');
}

final data = jsonDecode(res.body);

if (data['status'] == 'ok') {
final prefs = await SharedPreferences.getInstance();

prefs.setString('customerCode', customer);//Standart
//prefs.setString('customerCode', fullCustomerCode); //Alki

final te = Provider.of<Translations>(context, listen: false);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(te.text('upl4'))),
);

_nameController.clear();
_serialController.clear();

// Torque löschen, Druckwerte behalten
setState(() {
for (var t in torqueControllers) {
t.clear();
}
});
} else {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Fehler beim Upload: ${data['message']}'),
),
);
}
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Fehler: $e')),
);
} finally {
setState(() => isUploading = false);
}
}

@override
void dispose() {
_customerController.dispose();
_nameController.dispose();
_serialController.dispose();

for (var c in pressureControllers) {
c.dispose();
}

for (var c in torqueControllers) {
c.dispose();
}

super.dispose();
}

// Header im gleichen Design wie Settingsscreen und Toolsscreen
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
Icons.cloud_upload_rounded,
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

Widget _buildSectionTitle({
required IconData icon,
required String title,
}) {
return Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: AppColors.lightBlue,
borderRadius: BorderRadius.circular(11),
),
child: Icon(
icon,
color: AppColors.primary,
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
],
);
}

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
blurRadius: 10,
offset: Offset(0, 3),
),
],
),
child: child,
);
}

InputDecoration _inputDecoration({
required String label,
String? hint,
String? prefixText,
}) {
return InputDecoration(
labelText: label,
hintText: hint,
prefixText: prefixText,
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
);
}

@override
Widget build(BuildContext context) {
final te = Provider.of<Translations>(context);

return AppTemplate(
hideSettingsIcon: true,
child: GestureDetector(
behavior: HitTestBehavior.translucent,
onTap: () => FocusScope.of(context).unfocus(),
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(
title: te.text('upload_title'),
subtitle: te.text('upload_subtitle'),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.person_outline_rounded,
title: te.text('upl5'),
),

const SizedBox(height: 12),
  _buildCard(
    child: TextField(
      controller: _customerController,
      decoration: _inputDecoration(
        label: te.text('upl5'),
        hint: 'XXXXXXXXXX',
        prefixText: '',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (v) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('customerCode', '$v');
      },
    ),
  ),//Standard
/*
_buildCard(
child: TextField(
controller: _customerController,
decoration: _inputDecoration(
label: te.text('upl5'),
hint: 'XXXXX',
prefixText: '10019',
),
keyboardType: TextInputType.number,
inputFormatters: [
LengthLimitingTextInputFormatter(5),
FilteringTextInputFormatter.digitsOnly,
],
onChanged: (v) async {
final prefs = await SharedPreferences.getInstance();
prefs.setString('customerCode', '10019$v');
},
),
),
*/ //Alkitronik
const SizedBox(height: 16),

_buildCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildSectionTitle(
icon: Icons.handyman_outlined,
title: te.text('upload_tool_details'),
),

const SizedBox(height: 16),

TextField(
controller: _nameController,
decoration: _inputDecoration(
label: te.text('upl7'),
),
),

const SizedBox(height: 14),

TextField(
controller: _serialController,
decoration: _inputDecoration(
label: te.text('upl8'),
),
),
],
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.tune_rounded,
title: te.text('upl9'),
),

const SizedBox(height: 12),

_buildCard(
child: Column(
children: [
Row(
children: [
Expanded(
child: Text(
te.textArgs(
'upl10',
{'Value': DRUCK_EINHEIT},
),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
),
const SizedBox(width: 8),
Expanded(
child: Text(
te.textArgs(
'upl11',
{'Value': DREHMOMENT_EINHEIT},
),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 12),

ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: pressureControllers.length,
itemBuilder: (context, i) {
return KeyedSubtree(
key: ValueKey("row_$i"),
child: Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: TextField(
controller: pressureControllers[i],
keyboardType: TextInputType.number,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
),
decoration: _inputDecoration(
label: te.textArgs(
'upl10',
{'Value': DRUCK_EINHEIT},
),
),
onChanged: (v) {
_savePressureValues();
_checkAddRow();
},
),
),

const SizedBox(width: 8),

Expanded(
child: TextField(
controller: torqueControllers[i],
keyboardType: TextInputType.number,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
),
decoration: _inputDecoration(
label: te.textArgs(
'upl11',
{'Value': DREHMOMENT_EINHEIT},
),
),
onChanged: (v) {
_checkAddRow();
},
),
),
],
),
),
);
},
),
],
),
),

const SizedBox(height: 24),

AppButtons.primaryText(
text: isUploading ? te.text('upl12') : te.text('upl13'),
onPressed: () {
if (!isUploading) _uploadTool();
},
verticalPadding: 16,
),

const SizedBox(height: 12),

AppButtons.primaryText(
text: te.text('zurueck'),
onPressed: () => Navigator.pop(context),
backgroundColor: AppColors.secondary,
verticalPadding: 16,
),
],
),
),
),
);
}
}

