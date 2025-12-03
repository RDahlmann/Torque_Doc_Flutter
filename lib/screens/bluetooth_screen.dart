import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/translation.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';

import 'package:permission_handler/permission_handler.dart';

class DeviceData {
  final String id;
  final String name;

  DeviceData({required this.id, required this.name});
}

class BluetoothScreen extends StatefulWidget {
  final bool isInitialScreen;

  const BluetoothScreen({super.key, this.isInitialScreen = false});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}


class _BluetoothScreenState extends State<BluetoothScreen> {
  List<DeviceData> devicesList = [];
  DeviceData? selectedDevice;
  bool isConnected = false;
  late final t = Provider.of<Translations>(context);
  Future<bool> ensureBlePermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt ?? 0;

      Map<Permission, PermissionStatus> statuses;

      if (sdkInt >= 31) {
        // Android 12+
        statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();
      } else {
        // Android <12
        statuses = await [
          Permission.bluetooth,
          Permission.locationWhenInUse,
        ].request();
      }

      return statuses.values.every((s) => s.isGranted);
    }

    // iOS fragt automatisch
    return true;
  }

  Future<void> _startBleService() async {
    final granted = await ensureBlePermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('BLE-Permissions benötigt!')),
      );
      return;
    }

    // Foreground BLE-Service starten
    await FlutterForegroundTask.startService(
      notificationTitle: 'BLE Service',
      notificationText: 'Scanning for devices...',
      callback: startBleTask,
    );
    debugPrint("[BLE_SCREEN] Foreground BLE service started");
  }
  @override
  void initState() {
    super.initState();
    debugPrint("[BLE_SCREEN] initState called");

    // Kommunikation mit Foreground Task initialisieren
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);

    _startBleService();
  }

  void _handleTaskData(dynamic data) {
    debugPrint("[BLE_SCREEN] onReceiveData: $data");

    if (data['event'] == 'deviceFound') {
      final id = data['id'] as String?;
      final name = data['name'] as String?;
      if (id == null) return;

      final newDevice = DeviceData(id: id, name: name ?? id);

      setState(() {
        if (!devicesList.any((d) => d.id == id)) {
          devicesList.add(newDevice);
          debugPrint("[BLE_SCREEN] Device added: ${newDevice.name} (${newDevice.id})");
        }
      });
    }

    if (data['event'] == 'connected') {
      setState(() => isConnected = true);
      debugPrint("[BLE_SCREEN] Device connected: ${data['name']} (${data['id']})");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.text('bt1'))),
      );
    }

    if (data['event'] == 'connectError') {
      debugPrint("[BLE_SCREEN] Connection error: ${data['error']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.text('bt2'))),
      );
    }
  }

  void _selectDevice(DeviceData device) {
    setState(() => selectedDevice = device);
    debugPrint("[BLE_SCREEN] Selected device: ${device.name} (${device.id})");

    FlutterForegroundTask.sendDataToTask({
      'event': 'connectDevice',
      'id': device.id,
    });
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
    debugPrint("[BLE_SCREEN] dispose called");
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            DropdownButton<DeviceData>(
              hint: Text(t.text('bt3')),
              isExpanded: true,
              value: selectedDevice,
              items: devicesList
                  .map((d) => DropdownMenuItem(
                value: d,
                child: Text(d.name),
              ))
                  .toList(),
              onChanged: (d) {
                if (d != null) _selectDevice(d);
              },
            ),
            const SizedBox(height: 16),
            AppButtons.primaryText(
              text: "Scan",
              onPressed: () {
                debugPrint("[BLE_SCREEN] Requesting new scan");
                FlutterForegroundTask.sendDataToTask({
                  'event': 'startScan',
                });
              },
              verticalPadding: 16,
            ),
            const SizedBox(height: 16),

            AppButtons.primaryText(
             text: t.text('weiter'),
              onPressed: () {
                if (widget.isInitialScreen) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  Navigator.pop(context);
                }
              },
              verticalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }
}
