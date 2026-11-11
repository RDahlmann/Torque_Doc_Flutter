import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import '../globals.dart';
import '../styles/RotatingSignal.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Kalibrierscreen extends StatefulWidget {
const Kalibrierscreen({super.key});

@override
State<Kalibrierscreen> createState() => _Kalibrierscreenstate();
}

class _Kalibrierscreenstate extends State<Kalibrierscreen> {
late TextEditingController exampleController;

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
Icons.settings_suggest_rounded,
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

Widget _buildStatusCard(Translations t) {
final bool kalibriert = iskalibriert;

return Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
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
children: [
if (!kalibriert) ...[
Container(
width: 84,
height: 84,
decoration: BoxDecoration(
color: AppColors.primary.withValues(alpha: 0.08),
borderRadius: BorderRadius.circular(24),
),
alignment: Alignment.center,
child: RotatingSignal(
color: AppColors.primary,
),
),
const SizedBox(height: 24),
Text(
t.text('kal1'),
textAlign: TextAlign.center,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 10),
Text(
t.text('calibration_wait_description'),
textAlign: TextAlign.center,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
fontWeight: FontWeight.w400,
),
),
] else ...[
Container(
width: 84,
height: 84,
decoration: BoxDecoration(
color: AppColors.success.withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(24),
),
child: Icon(
Icons.check_circle_rounded,
color: AppColors.success,
size: 52,
),
),
const SizedBox(height: 24),
Text(
t.text('calibration_complete_title'),
textAlign: TextAlign.center,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 8),
Text(
t.text('calibration_complete_description'),
textAlign: TextAlign.center,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
fontWeight: FontWeight.w400,
),
),
],
],
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

void _handleTaskData(dynamic data) {
if (!mounted) return;

if (data is Map && data['event'] == 'kalibriert') {
pwm = data['pwm'] as int?;
referenzzeitkal = data['referenzzeitkal'] as int?;
vorreferenzzeit = data['vorreferenzzeit'] as int?;

setState(() {
iskalibriert = true;
});
}
}

@override
void dispose() {
FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
exampleController.dispose();

super.dispose();
}

@override
Widget build(BuildContext context) {
final t = Provider.of<Translations>(context);

return WillPopScope(
onWillPop: () async => false,
child: AppTemplate(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(
title: t.text('calibration_title'),
subtitle: t.text('calibration_subtitle'),
),

const SizedBox(height: 24),

Text(
t.text('calibration_status_title'),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 14),

_buildStatusCard(t),

const SizedBox(height: 24),

if (iskalibriert)
AppButtons.primaryText(
text: t.text('weiter'),
onPressed: () {
akt_schraube = 1;
isSchrauben = false;

debugPrint(
"🔧 Kalibrierung weiter gedrückt -> "
"pwm=$pwm, "
"vorreferenzzeit=$vorreferenzzeit, "
"referenzzeitkal=$referenzzeitkal",
);

Navigator.pushNamed(context, '/menu');
},
verticalPadding: 16,
),

const SizedBox(height: 12),

AppButtons.primaryText(
text: t.text('zurueck'),
onPressed: () => Navigator.pop(context),
verticalPadding: 16,
backgroundColor: AppColors.secondary,
),

const SizedBox(height: 16),
],
),
),
),
);
}
}

