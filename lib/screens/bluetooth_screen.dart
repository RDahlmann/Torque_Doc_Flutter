import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../main.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';
import '../styles/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    debugPrint("[BLE_SCREEN] initState called");

    // Kommunikation mit Foreground Task initialisieren
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);

    // Foreground BLE-Service starten
    FlutterForegroundTask.startService(
      notificationTitle: 'BLE Service',
      notificationText: 'Scanning for devices...',
      callback: startBleTask,
    ).then((_) => debugPrint("[BLE_SCREEN] Foreground BLE service started"));
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
        const SnackBar(content: Text('Gerät verbunden!')),
      );
    }

    if (data['event'] == 'connectError') {
      debugPrint("[BLE_SCREEN] Connection error: ${data['error']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${data['error']}')),
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
              hint: const Text('Gerät auswählen'),
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
              text: "Sende \$SETP 150~",
              onPressed: () {
                _sendCommand('-SETP 150\$');
              },
              verticalPadding: 16,
            ),
            AppButtons.primaryText(
              text: "Weiter",
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
