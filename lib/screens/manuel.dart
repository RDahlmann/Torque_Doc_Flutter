import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../globals.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';
import 'bluetooth_screen.dart';
import 'package:torquedoc/main.dart';

class Manuelscreen extends StatefulWidget {
const Manuelscreen({super.key});

@override
_Manuelscreenstate createState() => _Manuelscreenstate();
}

class _Manuelscreenstate extends State<Manuelscreen> {
late TextEditingController exampleController;
late final t = Provider.of<Translations>(context);

@override
void initState() {
super.initState();

exampleController = TextEditingController();

FlutterForegroundTask.initCommunicationPort();
FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
}

Future<void> _startBleService() async {
final granted = await ensureBlePermissions();

if (!granted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('BLE-Permissions benötigt!'),
),
);
return;
}

await FlutterForegroundTask.startService(
notificationTitle: 'BLE Service',
notificationText: 'Scanning for devices...',
callback: startBleTask,
);

debugPrint('[MANUAL_SCREEN] Foreground BLE service started');
}

Future<bool> ensureBlePermissions() async {
if (Platform.isAndroid) {
final deviceInfo = DeviceInfoPlugin();
final androidInfo = await deviceInfo.androidInfo;
final sdkInt = androidInfo.version.sdkInt ?? 0;

Map<Permission, PermissionStatus> statuses;

if (sdkInt >= 31) {
statuses = await [
Permission.bluetoothScan,
Permission.bluetoothConnect,
Permission.locationWhenInUse,
].request();
} else {
statuses = await [
Permission.bluetooth,
Permission.locationWhenInUse,
].request();
}

return statuses.values.every((s) => s.isGranted);
}

return true;
}

Future<void> _handleTaskData(dynamic data) async {
if (data is Map && data['event'] == 'statedisconnected') {
debugPrint('⚠️ BLE disconnected → Foreground task stoppen');

if (!isdisconnect) {
isdisconnect = true;

await FlutterForegroundTask.stopService();

if (!mounted) return;

setState(() {
isrunning = false;
isaborted1 = false;
isaborted2 = false;
iscomplete = false;
isnotintol = false;
isfehler = false;
isnotconnected = true;
});
}
}

if (data is Map && data['event'] == 'fehler') {
if (!mounted) return;

setState(() {
isrunning = false;
isaborted1 = false;
isaborted2 = false;
iscomplete = false;
isnotintol = false;
isfehler = true;
isnotconnected = false;
isdisconnect = false;
});
}
}

void _sendCommand(String cmd) {
debugPrint('[BLE_SCREEN] Sending command: $cmd');

FlutterForegroundTask.sendDataToTask({
'event': 'writeCommand',
'command': cmd,
});
}

void _sendFehler(String cmd) {
debugPrint('[BLE_SCREEN] Sending command: $cmd');

FlutterForegroundTask.sendDataToTask({
'event': 'fehlerCommand',
'command': cmd,
'isTorque': istorque,
'torquelist': TORQUELIST,
'toolname': TOOLNAME,
'pressurelist': PRESSURELIST,
'solltorque': SOLLTORQUE,
});
}

@override
void dispose() {
exampleController.dispose();
FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
super.dispose();
}

// Kopfbereich im gleichen Design wie der Kalibrierscreen
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
Icons.handyman_outlined,
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
t.text('manual_header_title'),
style: AppTextStyles.headline.copyWith(
color: AppColors.textOnPrimary,
fontSize: 22,
),
),
const SizedBox(height: 6),
Text(
t.text('manual_header_subtitle'),
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

// Statuskarte für den manuellen Betrieb
Widget _buildStatusCard(Translations t) {
if (isfehler) {
return _buildActionCard(
icon: Icons.warning_amber_rounded,
iconColor: AppColors.warning,
title: t.text('automatik16'),
description: t.text('manual_error_description'),
buttonText: t.text('automatik16'),
buttonColor: AppColors.warning,
onPressed: () {
setState(() {
isrunning = false;
isaborted1 = false;
isaborted2 = false;
iscomplete = false;
isnotintol = false;
isfehler = false;
isnotconnected = false;

_sendCommand('-Manuell $pwm $SOLLDRUCK\$');
});
},
);
}

if (isnotconnected) {
return _buildActionCard(
icon: Icons.bluetooth_disabled,
iconColor: AppColors.error,
title: t.text('automatik17'),
description: t.text('manual_disconnected_description'),
buttonText: t.text('automatik17'),
buttonColor: AppColors.error,
onPressed: () {
setState(() {
isrunning = false;
isaborted1 = false;
isaborted2 = false;
iscomplete = false;
isnotintol = false;
isfehler = true;
isnotconnected = false;
});

_startBleService();

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const BluetoothScreen(
isInitialScreen: false,
),
),
);
},
);
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: AppColors.border.withOpacity(0.7),
),
boxShadow: [
BoxShadow(
color: AppColors.shadow.withOpacity(0.06),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
children: [
Container(
width: 64,
height: 64,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.09),
shape: BoxShape.circle,
),
child: const Center(
child: SizedBox(
width: 30,
height: 30,
child: CircularProgressIndicator(
strokeWidth: 3,
color: AppColors.primary,
),
),
),
),
const SizedBox(height: 20),
Text(
t.text('manual_status_title'),
style: AppTextStyles.headline.copyWith(
color: AppColors.textPrimary,
fontSize: 19,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 10),
Text(
t.text('man1'),
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
),
textAlign: TextAlign.center,
),
],
),
);
}

Widget _buildActionCard({
required IconData icon,
required Color iconColor,
required String title,
required String description,
required String buttonText,
required Color buttonColor,
required VoidCallback onPressed,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: AppColors.border.withOpacity(0.7),
),
boxShadow: [
BoxShadow(
color: AppColors.shadow.withOpacity(0.06),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
children: [
Container(
width: 64,
height: 64,
decoration: BoxDecoration(
color: iconColor.withOpacity(0.12),
shape: BoxShape.circle,
),
child: Icon(
icon,
color: iconColor,
size: 32,
),
),
const SizedBox(height: 18),
Text(
title,
style: AppTextStyles.headline.copyWith(
color: AppColors.textPrimary,
fontSize: 19,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 10),
Text(
description,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
AppButtons.primaryText(
text: buttonText,
backgroundColor: buttonColor,
foregroundColor: AppColors.white,
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
const SizedBox(height: 18),
_buildStatusCard(t),
const SizedBox(height: 18),
AppButtons.primaryText(
text: t.text('zurueck'),
onPressed: () {
_sendCommand('-STOP\$');
Navigator.pop(context);
},
verticalPadding: 16,
),
],
),
),
),
);
}
}

