import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';
import 'bluetooth_screen.dart';
import 'package:torquedoc/main.dart';

class Manuelscreen extends StatefulWidget {

  @override
  _Manuelscreenstate createState() => _Manuelscreenstate();
}

class _Manuelscreenstate  extends State<Manuelscreen> {
  // Beispiel: Hier können Controller oder Variablen für jeden Screen definiert werden
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
        SnackBar(content: Text('BLE-Permissions benötigt!')),
      );
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'BLE Service',
      notificationText: 'Scanning for devices...',
      callback: startBleTask,
    );
    debugPrint("[AUTO_SCREEN] Foreground BLE service started");
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
    return true; // iOS fragt automatisch
  }
  Future<void> _handleTaskData(dynamic data) async {
    if (data is Map && data['event'] == 'statedisconnected') {
      debugPrint("⚠️ BLE disconnected → Foreground task stoppen");
      if (!isdisconnect) {
        isdisconnect = true;
        await FlutterForegroundTask.stopService();
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
      setState(() {
        isrunning = false;
        isaborted1=false;
        isaborted2=false;
        iscomplete=false;
        isnotintol=false;
        isfehler=true;
        isnotconnected=false;
        isdisconnect=false;
      });
    }
  }

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
  void _sendFehler(String cmd) {
    debugPrint("[BLE_SCREEN] Sending command: $cmd");
    FlutterForegroundTask.sendDataToTask({
      'event': 'fehlerCommand',
      'command': cmd,
      'isTorque':istorque,
      'torquelist':TORQUELIST,
      'toolname':TOOLNAME,
      'pressurelist':PRESSURELIST,
      'solltorque':SOLLTORQUE,

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // verhindert System-Zurück
      child: AppTemplate(
        child: SingleChildScrollView(
          child: isfehler
          ?Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [AppButtons.primaryText(
              text: t.text('automatik16'),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.black,
              onPressed: () {
                setState(() {
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
                  isnotintol=false;
                  isfehler=false;
                  isnotconnected=false;
                  _sendCommand('-Manuell $pwm $SOLLDRUCK\$');

                });

              },
              verticalPadding: 16,
            ),
            ],
          )
              :(isnotconnected)
              ?Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [AppButtons.primaryText(
              text: t.text('automatik17'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
                  isnotintol=false;
                  isfehler=true;
                  isnotconnected=false;
                  _startBleService();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BluetoothScreen(isInitialScreen: false),
                    ),
                  );


                });

              },
              verticalPadding: 16,
            ),
            ],
          )
          :Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    t.text('man1'),
                    style:AppTextStyles.body,textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 24),



              // Optional: Zurück Button (Navigation nur über Button)
              AppButtons.primaryText(
                text: t.text('zurueck'),
                onPressed: () {
                  _sendCommand('-STOP\$');
                  Navigator.pop(context); // Zurück zum vorherigen Screen
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
