
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../providers/field_settings.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_toast.dart';
import '../utils/translation.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
late final TextEditingController nameController;
late final TextEditingController projectController;
late final TextEditingController toleranceController;
late final TextEditingController sPumpController;
late final TextEditingController sHoseController;
late final TextEditingController sToolController;
late final TextEditingController toolController;

String? _projectError;

@override
void initState() {
super.initState();

nameController = TextEditingController();
projectController = TextEditingController();
toleranceController = TextEditingController();
sPumpController = TextEditingController();
sHoseController = TextEditingController();
sToolController = TextEditingController();
toolController = TextEditingController();

loadSavedData();
}

Future<bool> ensureStoragePermission() async {
if (Platform.isAndroid) {
final androidInfo = await DeviceInfoPlugin().androidInfo;
final sdkInt = androidInfo.version.sdkInt;

if (sdkInt < 29) {
final status = await Permission.storage.request();
return status.isGranted;
}

return true;
}

return true;
}

Future<bool> checkProjectFileExists(String projectVar) async {
final now = DateTime.now();

final dateString =
'${now.year}-'
'${now.month.toString().padLeft(2, '0')}-'
'${now.day.toString().padLeft(2, '0')}';

final safeProjectVar =
projectVar.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

final fileName = '${safeProjectVar}_$dateString.pdf';

late String filePath;

if (Platform.isAndroid) {
final directory =
Directory('/storage/emulated/0/Download/TorqueDoc');

filePath = '${directory.path}/$fileName';
} else {
final baseDir = await getApplicationDocumentsDirectory();
final directory = Directory('${baseDir.path}/TorqueDocData');

filePath = '${directory.path}/$fileName';
}

return File(filePath).exists();
}

Future<void> loadSavedData() async {
final prefs = await SharedPreferences.getInstance();

if (!mounted) return;

setState(() {
UserName = prefs.getString('userName') ?? '';
Projectnumber = prefs.getString('projectNumber') ?? '';
Toleranz = prefs.getString('toleranz') ?? '';

Serialpump = connectedDeviceName.isNotEmpty
? connectedDeviceName
    : prefs.getString('serpump') ?? '';

Serialhose = prefs.getString('serhose') ?? '';
Serialtool = prefs.getString('sertool') ?? '';
Tool = prefs.getString('tool') ?? '';

nameController.text = UserName;
projectController.text = Projectnumber;
toleranceController.text = Toleranz;
sPumpController.text = Serialpump;
sHoseController.text = Serialhose;
sToolController.text = Serialtool;
toolController.text = Tool;
});
}

Future<void> saveData(String key, String value) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setString(key, value);
}

@override
void dispose() {
nameController.dispose();
projectController.dispose();
toleranceController.dispose();
sPumpController.dispose();
sHoseController.dispose();
sToolController.dispose();
toolController.dispose();

super.dispose();
}

@override
Widget build(BuildContext context) {
final fields = Provider.of<FieldSettings>(context);
final t = Provider.of<Translations>(context);

return WillPopScope(
onWillPop: () async => false,
child: AppTemplate(
child: GestureDetector(
behavior: HitTestBehavior.translucent,
onTap: () => FocusScope.of(context).unfocus(),
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildPageHeading(
title: t.text('home_title'),
subtitle: t.text('home_subtitle'),
),

const SizedBox(height: 24),

_buildSectionHeading(
icon: Icons.assignment_outlined,
title: t.text('home_project_section'),
),

const SizedBox(height: 14),

if (fields.requireName) ...[
_buildInputField(
controller: nameController,
label: t.text('name'),
hint: t.text('name_insert'),
icon: Icons.person_outline,
onChanged: (value) {
UserName = value;
saveData('userName', value);
},
),
const SizedBox(height: 16),
],

_buildInputField(
controller: projectController,
label: t.text('project'),
hint: t.text('project_insert'),
icon: Icons.folder_outlined,
errorText: _projectError,
inputFormatters: [
FilteringTextInputFormatter.allow(
RegExp(r'[a-zA-Z0-9]'),
),
LengthLimitingTextInputFormatter(15),
],
onChanged: (value) {
String? error;

if (value.length > 15) {
error = t.text('project_error_length');
}

if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)) {
error = t.text('project_error_characters');
}

setState(() {
_projectError = error;
});

if (error == null) {
Projectnumber = value;
saveData('projectNumber', value);
}
},
),

const SizedBox(height: 16),

_buildInputField(
controller: toleranceController,
label: t.text('tolerance'),
hint: t.text('tolerance_insert'),
icon: Icons.tune,
keyboardType: TextInputType.number,
inputFormatters: [
FilteringTextInputFormatter.digitsOnly,
],
suffixText: '%',
onChanged: (value) {
Toleranz = value;
saveData('toleranz', value);
},
),

const SizedBox(height: 26),

_buildSectionHeading(
icon: Icons.precision_manufacturing_outlined,
title: t.text('home_equipment_section'),
),

const SizedBox(height: 14),

_buildInputField(
controller: sPumpController,
label: t.text('serial_pump'),
hint: t.text('serial_pump_insert'),
icon: Icons.settings_outlined,
onChanged: (value) {
Serialpump = value;
saveData('serpump', value);
},
),

if (fields.requireSerialHose) ...[
const SizedBox(height: 16),
_buildInputField(
controller: sHoseController,
label: t.text('serial_hose'),
hint: t.text('serial_hose_insert'),
icon: Icons.water_outlined,
onChanged: (value) {
Serialhose = value;
saveData('serhose', value);
},
),
],

if (fields.requireSerialTool) ...[
const SizedBox(height: 16),
_buildInputField(
controller: sToolController,
label: t.text('serial_tool'),
hint: t.text('serial_tool_insert'),
icon: Icons.build_outlined,
onChanged: (value) {
Serialtool = value;
saveData('sertool', value);
},
),
],

const SizedBox(height: 16),

_buildInputField(
controller: toolController,
label: t.text('tool'),
hint: t.text('tool_insert'),
icon: Icons.handyman_outlined,
onChanged: (value) {
Tool = value;
saveData('tool', value);
},
),

const SizedBox(height: 28),

AppButtons.primary(
text: t.text('continue'),
icon: Icons.arrow_forward_rounded,
onPressed: () {
FocusScope.of(context).unfocus();
validateAndProceed();
},
verticalPadding: 8,
minHeight: 56,
),
],
),
),
),
),
);
}

Widget _buildPageHeading({
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
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 16,
offset: const Offset(0, 6),
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
child: Icon(
Icons.assignment_outlined,
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
),
),
const SizedBox(height: 6),
Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: AppColors.textOnPrimary.withValues(alpha: 0.88),
),
),
],
),
),
],
),
);
}

Widget _buildSectionHeading({
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
),
),
),
],
);
}

Widget _buildInputField({
required TextEditingController controller,
required String label,
required String hint,
required IconData icon,
required ValueChanged<String> onChanged,
String? errorText,
String? suffixText,
TextInputType? keyboardType,
List<TextInputFormatter>? inputFormatters,
}) {
return Container(
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 10,
offset: const Offset(0, 3),
),
],
),
child: TextField(
controller: controller,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
),
keyboardType: keyboardType,
inputFormatters: inputFormatters,
onChanged: onChanged,
decoration: InputDecoration(
labelText: label,
hintText: hint,
errorText: errorText,
prefixIcon: Icon(
icon,
color: AppColors.primary,
size: 22,
),
suffixText: suffixText,
suffixStyle: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
),
filled: true,
fillColor: AppColors.backgroundCard,
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 18,
),
labelStyle: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
),
hintStyle: AppTextStyles.body.copyWith(
color: AppColors.textHint,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.border,
),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.border,
),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.primary,
width: 1.8,
),
),
errorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.error,
),
),
focusedErrorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide(
color: AppColors.error,
width: 1.8,
),
),
),
),
);
}

Future<void> validateAndProceed() async {
final fields = Provider.of<FieldSettings>(context, listen: false);
final t = Provider.of<Translations>(context, listen: false);

if (fields.requireName && UserName.trim().isEmpty) {
AppToast.warning(t.text('name_insert'));
return;
}

if (Projectnumber.isEmpty) {
AppToast.warning(t.text('project_insert'));
return;
}

if (_projectError != null) {
AppToast.warning(_projectError!);
return;
}

if (Toleranz.isEmpty) {
AppToast.warning(t.text('tolerance_insert'));
return;
}

if (Serialpump.isEmpty) {
AppToast.warning(t.text('serial_pump_insert'));
return;
}

if (fields.requireSerialTool && Serialtool.isEmpty) {
AppToast.warning(t.text('serial_tool_insert'));
return;
}

if (fields.requireSerialHose && Serialhose.isEmpty) {
AppToast.warning(t.text('serial_hose_insert'));
return;
}

if (Tool.isEmpty) {
AppToast.warning(t.text('tool_insert'));
return;
}

final permissionGranted = await ensureStoragePermission();

if (!mounted) return;

if (!permissionGranted) {
AppToast.warning(t.text('storage_permission_required'));
return;
}

final exists = await checkProjectFileExists(Projectnumber);

if (!mounted) return;

if (exists) {
AppToast.warning(t.text('project_file_exists'));
return;
}

Navigator.pushNamed(context, '/choose');
}
}

