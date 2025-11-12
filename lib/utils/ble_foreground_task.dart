import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleForegroundTask extends TaskHandler {
  final List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    debugPrint("[BLE_TASK] onStart at $timestamp");
    debugPrint("[BLE_TASK] Starting BLE scan...");

    // Scan starten und Ergebnisse senden
    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (r.device.name.isNotEmpty && !devices.any((d) => d.id == r.device.id)) {
          devices.add(r.device);
          debugPrint("[BLE_TASK] Device found: ${r.device.name} (${r.device.id.id})");

          FlutterForegroundTask.sendDataToMain({
            'event': 'deviceFound',
            'id': r.device.id.id,
            'name': r.device.name,
          });
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    debugPrint("[BLE_TASK] Scan started for 5 seconds");
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (connectedDevice != null) {
      try {
        // Aktuellen Status abfragen
        final state = await connectedDevice!.connectionState.first;

        // Debug-Ausgabe
        if (state == BluetoothConnectionState.connected) {
          debugPrint("[BLE_TASK] Device ${connectedDevice!.platformName} is connected");
          FlutterForegroundTask.sendDataToMain({
            'event': 'stateconnected',
          });
        } else if (state == BluetoothConnectionState.disconnected) {
          debugPrint("[BLE_TASK] Device ${connectedDevice!.platformName} is disconnected");
          FlutterForegroundTask.sendDataToMain({
            'event': 'statedisconnected',
          });
        }
      } catch (e) {
        debugPrint("[BLE_TASK] Error checking device state: $e");
      }
    } else {
      debugPrint("[BLE_TASK] No device connected currently");
    }
  }


  @override
  void onReceiveData(dynamic data) async {
    debugPrint("[BLE_TASK] onReceiveData: $data");

    if (data['event'] == 'connectDevice') {
      final id = data['id'] as String?;
      if (id == null) {
        debugPrint("[BLE_TASK] connectDevice: missing id");
        return;
      }

      BluetoothDevice? device;
      try {
        device = devices.firstWhere((d) => d.id.id == id);
      } catch (_) {
        debugPrint("[BLE_TASK] Device not found for id: $id");
        FlutterForegroundTask.sendDataToMain({
          'event': 'connectError',
          'error': 'Device not found',
        });
        return;
      }

      connectedDevice = device;
      debugPrint("[BLE_TASK] Connecting to device: ${device.name} (${device.id.id})");

      try {
        await connectedDevice!.connect(autoConnect: false);
        debugPrint("[BLE_TASK] Connected to device: ${device.name}");

        // Suche HM-10 Characteristic (FFE1)
        final services = await connectedDevice!.discoverServices();
        for (var s in services) {
          for (var c in s.characteristics) {
            if (c.uuid.toString().toLowerCase().contains('ffe1')) {
              writeCharacteristic = c;
              debugPrint("[BLE_TASK] Write characteristic found: ${c.uuid}");

              // Notifications aktivieren
              await writeCharacteristic!.setNotifyValue(true);
              writeCharacteristic!.value.listen((value) {
                final received = utf8.decode(value);
                debugPrint("[BLE_TASK] Received data: $received");

                FlutterForegroundTask.sendDataToMain({
                  'event': 'receivedData',
                  'data': received,
                });
              });

              break;
            }
          }
          if (writeCharacteristic != null) break;
        }

        FlutterForegroundTask.sendDataToMain({
          'event': 'connected',
          'id': id,
          'name': connectedDevice!.name,
        });
      } catch (e) {
        debugPrint("[BLE_TASK] Connection error: $e");
        FlutterForegroundTask.sendDataToMain({
          'event': 'connectError',
          'error': e.toString(),
        });
      }
    }

    if (data['event'] == 'writeCommand') {
      final cmd = data['command'] as String?;
      if (writeCharacteristic != null && cmd != null) {
        debugPrint("[BLE_TASK] Writing command: $cmd");
        await writeCharacteristic!.write(utf8.encode(cmd), withoutResponse: true);
      } else {
        debugPrint("[BLE_TASK] Cannot write command, characteristic or command is null");
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isServiceStopped) async {
    debugPrint("[BLE_TASK] onDestroy at $timestamp, serviceStopped: $isServiceStopped");
    await FlutterBluePlus.stopScan();
    debugPrint("[BLE_TASK] Scan stopped");

    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      debugPrint("[BLE_TASK] Disconnected from device: ${connectedDevice!.name}");
    }
  }
}