import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import '../globals.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_toast.dart';
import '../utils/translation.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';

class pressurescreen extends StatefulWidget {
const pressurescreen({super.key});

@override
State<pressurescreen> createState() => _pressurescreenstate();
}

class _pressurescreenstate extends State<pressurescreen> {
late TextEditingController exampleController;
late int _eingabe = 0;

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
Icons.speed_rounded,
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

Widget _buildSectionTitle(String title) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
);
}

InputDecoration _inputDecoration({
required String label,
required String hint,
required String unit,
}) {
return InputDecoration(
labelText: label,
hintText: hint,
suffixText: unit,
labelStyle: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
),
hintStyle: AppTextStyles.body.copyWith(
color: AppColors.textHint,
fontSize: 14,
),
suffixStyle: AppTextStyles.body.copyWith(
color: AppColors.primary,
fontWeight: FontWeight.w700,
),
filled: true,
fillColor: AppColors.backgroundInput,
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 18,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: AppColors.border),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: AppColors.border),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide(
color: AppColors.primary,
width: 1.8,
),
),
);
}

@override
void initState() {
super.initState();

exampleController = TextEditingController();

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
exampleController.dispose();

FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);

super.dispose();
}

@override
Widget build(BuildContext context) {
final t = Provider.of<Translations>(context);

final bool isPSI = DRUCK_EINHEIT == "PSI";
final String unitLabel = isPSI ? "PSI" : "bar";

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
_buildHeader(
title: t.text('selection_pressure_title'),
subtitle: t.text('selection_pressure_description'),
),

const SizedBox(height: 24),

_buildSectionTitle(t.text('pres1')),

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
width: 1,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 10,
offset: Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: AppColors.primary.withValues(alpha: 0.10),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.tune_rounded,
color: AppColors.primary,
size: 24,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
t.text('pres3'),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 20),

TextField(
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 18,
),
keyboardType: TextInputType.number,
inputFormatters: [
FilteringTextInputFormatter.digitsOnly,
],
decoration: _inputDecoration(
label: isPSI
? t.text('pres2')
    : t.text('pres1'),
hint: t.text('pres3'),
unit: unitLabel,
),
onChanged: (value) {
_eingabe = int.tryParse(value) ?? 0;
},
),

const SizedBox(height: 12),

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
Icons.info_outline_rounded,
color: AppColors.textSecondary,
size: 18,
),
const SizedBox(width: 8),
Expanded(
child: Text(
isPSI
? t.text('pres5')
    : t.text('pres4'),
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 12,
fontWeight: FontWeight.w400,
),
),
),
],
),
],
),
),

const SizedBox(height: 24),

AppButtons.primaryText(
text: t.text('continue'),
onPressed: () {
FocusScope.of(context).unfocus();

int druckBar;
final bool isPSI = DRUCK_EINHEIT == "PSI";

if (isPSI) {
SOLLDRUCKPSI = _eingabe;
druckBar = (_eingabe / 14.5038).round();
SOLLDRUCKBAR = druckBar;
} else {
druckBar = _eingabe;
SOLLDRUCKBAR = _eingabe;
SOLLDRUCKPSI = (_eingabe * 14.503).round();
}

if (druckBar < 150 || druckBar > 680) {
AppToast.warning(
isPSI ? t.text('pres5') : t.text('pres4'),
);

SOLLDRUCK = 0;
return;
} else {
istorque = false;
SOLLDRUCK = druckBar;

_sendCommand('-SETP $SOLLDRUCK\$');

iskalibriert = false;

FlutterForegroundTask.sendDataToTask({
'event': 'ispressure',
});

Navigator.pushNamed(context, '/kalibration');
}
},
verticalPadding: 16,
),

const SizedBox(height: 10),

AppButtons.primaryText(
text: t.text('zurueck'),
onPressed: () {
Navigator.pop(context);
},
verticalPadding: 16,
backgroundColor: AppColors.secondary,
),

const SizedBox(height: 16),
],
),
),
),
),
);
}
}

