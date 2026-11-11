import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import '../globals.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Menuscreen extends StatefulWidget {
const Menuscreen({super.key});

@override
_Menuscreenstate createState() => _Menuscreenstate();
}

class _Menuscreenstate extends State<Menuscreen> {
late TextEditingController exampleController;
late final t = Provider.of<Translations>(context);

@override
void initState() {
super.initState();

exampleController = TextEditingController();

FlutterForegroundTask.initCommunicationPort();
FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
}

void _handleTaskData(dynamic data) {}

void _sendCommand(String cmd) {
debugPrint('[BLE_SCREEN] Sending command: $cmd');

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

Widget _buildHeader(Translations t) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColors.primary,
AppColors.primary.withOpacity(0.82),
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
color: AppColors.white.withOpacity(0.16),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.dashboard_customize_outlined,
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
t.text('menu_header_title'),
style: AppTextStyles.headline.copyWith(
color: AppColors.textOnPrimary,
fontSize: 22,
),
),
const SizedBox(height: 6),
Text(
t.text('menu_header_subtitle'),
style: AppTextStyles.body.copyWith(
color: AppColors.textOnPrimary.withOpacity(0.88),
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

Widget _buildMenuCard({
required IconData icon,
required String title,
required String description,
required String buttonText,
required VoidCallback onPressed,
required Color iconColor,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.border.withOpacity(0.7),
),
boxShadow: [
BoxShadow(
color: AppColors.shadow.withOpacity(0.06),
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: iconColor.withOpacity(0.12),
borderRadius: BorderRadius.circular(14),
),
child: Icon(
icon,
color: iconColor,
size: 26,
),
),
const SizedBox(width: 14),
Expanded(
child: Text(
title,
style: AppTextStyles.headline.copyWith(
color: AppColors.textPrimary,
fontSize: 18,
),
),
),
],
),
const SizedBox(height: 12),
Text(
description,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
),
),
const SizedBox(height: 18),
AppButtons.primaryText(
text: buttonText,
onPressed: onPressed,
verticalPadding: 16,
),
],
),
);
}

@override
Widget build(BuildContext context) {
return WillPopScope(
onWillPop: () async => false,
child: AppTemplate(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
_buildHeader(t),
const SizedBox(height: 20),

_buildMenuCard(
icon: Icons.build_circle_outlined,
iconColor: AppColors.primary,
title: t.text('menu_card_auto_title'),
description: t.text('menu_card_auto_description'),
buttonText: t.text('menu1'),
onPressed: () {
iscomplete = false;
isaborted1 = false;
isaborted2 = false;
isauto = true;

final now = DateTime.now();
final formattedDate =
'${now.day.toString().padLeft(2, '0')}-'
'${now.month.toString().padLeft(2, '0')}-'
'${now.year}';

if (!isSchrauben) {
_sendCommand('-STOP\$');
} else {
if (Automatik) {
_sendCommand(
'-AutomatikA $pwm $Projectnumber $formattedDate '
'$SOLLDRUCK $referenzzeitkal $vorreferenzzeit '
'$akt_schraube\$',
);
} else {
_sendCommand(
'-AutomatikM $pwm $Projectnumber $formattedDate '
'$SOLLDRUCK $referenzzeitkal $vorreferenzzeit '
'$akt_schraube\$',
);
}
}

Navigator.pushNamed(context, '/auto');
},
),

const SizedBox(height: 16),

_buildMenuCard(
icon: Icons.handyman_outlined,
iconColor: AppColors.secondary,
title: t.text('menu_card_manual_title'),
description: t.text('menu_card_manual_description'),
buttonText: t.text('menu2'),
onPressed: () {
Navigator.pushNamed(context, '/manuell');
_sendCommand('-Manuell $pwm $SOLLDRUCK\$');
},
),

const SizedBox(height: 16),

_buildMenuCard(
icon: Icons.arrow_back_rounded,
iconColor: AppColors.textSecondary,
title: t.text('menu_card_back_title'),
description: t.text('menu_card_back_description'),
buttonText: t.text('menu3'),
onPressed: () {
Navigator.pushReplacementNamed(context, '/choose');
},
),

const SizedBox(height: 12),
],
),
),
),
);
}
}