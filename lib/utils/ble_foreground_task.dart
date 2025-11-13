import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

import '../globals.dart';



// 🔹 Liste für empfangene BLE-Werte
List<Map<String, dynamic>> BLE_Werteliste = [];


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
  String _buffer = '';

  void _parseBleMessage(String msg) {
    debugPrint("[BLE_TASK] Parsed message: $msg");

    // 🔹 Einfache Befehle ohne Parameter
    if (msg == "laeuft") {
      debugPrint("✅ BLE meldet: Läuft erkannt!");
      FlutterForegroundTask.sendDataToMain({
        'event': 'laeuft',
      });
      return;
    }

    if (msg == "fehler") {
      debugPrint("⚠️ BLE meldet: Fehler erkannt!");
      FlutterForegroundTask.sendDataToMain({
        'event': 'fehler',
      });
      return;
    }

    // 🔹 Kalibrierungsnachricht
    if (msg.startsWith("kalibriert")) {
      try {
        final parts = msg.split("&");
        if (parts.length >= 4) {
          pwm = int.tryParse(parts[1]);
          referenzzeitkal = int.tryParse(parts[2]);
          vorreferenzzeit = int.tryParse(parts[3]);
          debugPrint("🔧 Kalibriert empfangen -> pwm=$pwm, ref=$referenzzeitkal, vorref=$vorreferenzzeit");
          FlutterForegroundTask.sendDataToMain({
            'event': 'kalibriert',
            'pwm': pwm,
            'referenzzeitkal': referenzzeitkal,
            'vorreferenzzeit': vorreferenzzeit,
          });
        }
      } catch (e) {
        debugPrint("⚠️ Fehler beim Parsen von kalibriert: $e");
      }
      return;
    }

    // 🔹 Angezogen / Abgebrochen1 / Abgebrochen2
    if (msg.endsWith("angezogen") ||
        msg.endsWith("abgebrochen1") ||
        msg.endsWith("abgebrochen2")) {
      try {
        final parts = msg.split("&");
        if (parts.length >= 4) {
          schraubennummer = int.tryParse(parts[0]);
          druckmax = int.tryParse(parts[1]);
          solldruck = int.tryParse(parts[2]);
          final status = parts[3]; // angezogen / abgebrochen1 / abgebrochen2

          String ergebnis = "";

          switch (status) {
            case "angezogen":
              ergebnis = "iO";
              debugPrint("🟢 Schraube $schraubennummer angezogen (Druck=$druckmax / Soll=$solldruck)");
              final eintrag = {
                "Schraubennummer": schraubennummer,
                "Druckmax": druckmax,
                "Solldruck": solldruck,
                "Ergebnis": ergebnis,

              };
              BLE_Werteliste.add(eintrag);
              debugPrint("📋 Datensatz hinzugefügt: $eintrag");
              FlutterForegroundTask.sendDataToMain({
                'event': 'angezogen',
                'Werteliste':BLE_Werteliste,
              });
              debugPrint("[BLE_TASK] angezogen verschickt");
              break;
            case "abgebrochen1":
              ergebnis = "nIO";
              debugPrint("🟠 Schraube $schraubennummer abgebrochen1");
              final eintrag = {
                "Schraubennummer": schraubennummer,
                "Druckmax": druckmax,
                "Solldruck": solldruck,
                "Ergebnis": ergebnis,
              };
              BLE_Werteliste.add(eintrag);
              debugPrint("📋 Datensatz hinzugefügt: $eintrag");
              FlutterForegroundTask.sendDataToMain({
                'event': 'abgebrochen1',
                'Werteliste':BLE_Werteliste,
              });
              debugPrint("[BLE_TASK] angezogen verschickt");
              break;
            case "abgebrochen2":
              ergebnis = "nIO";
              debugPrint("🔴 Schraube $schraubennummer abgebrochen2");
              final eintrag = {
                "Schraubennummer": schraubennummer,
                "Druckmax": druckmax,
                "Solldruck": solldruck,
                "Ergebnis": ergebnis,
              };
              BLE_Werteliste.add(eintrag);
              debugPrint("📋 Datensatz hinzugefügt: $eintrag");
              FlutterForegroundTask.sendDataToMain({
                'event': 'abgebrochen2',
                'Werteliste':BLE_Werteliste,
              });
              debugPrint("[BLE_TASK] angezogen verschickt");
              break;
          }

          // 🔹 In Liste einfügen



          debugPrint("📦 Aktuelle Länge BLE_Werteliste: ${BLE_Werteliste.length}");
        }
      } catch (e) {
        debugPrint("⚠️ Fehler beim Parsen von Schraubenstatus: $e");
      }
      return;
    }

    debugPrint("❓ Unbekannte Nachricht: $msg");
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
    if (data['event'] == 'startScan') {
      debugPrint("[BLE_TASK] Starting scan...");

      // Bestehende Liste leeren, optional
      devices.clear();

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }

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
              // Notifications aktivieren
              await writeCharacteristic!.setNotifyValue(true);
              writeCharacteristic!.value.listen((value) {
                if (value.isEmpty) return;

                // Empfangene Rohdaten in Buffer sammeln
                final received = utf8.decode(value);
                debugPrint("[BLE_TASK] Raw data: $received");
                _buffer += received;

                // Prüfen, ob eine oder mehrere komplette Nachrichten vorliegen
                while (_buffer.contains('\$') && _buffer.contains('~')) {
                  final start = _buffer.indexOf('\$');
                  final end = _buffer.indexOf('~', start);
                  if (end == -1) break; // Nachricht noch unvollständig

                  // Nachricht extrahieren, führendes $ und abschließendes ~ werden entfernt
                  final message = _buffer.substring(start + 1, end).trim();
                  final cleanMessage = message.startsWith(r'$') ? message.substring(1) : message;

                  // Debug: Zeige die saubere Nachricht
                  debugPrint("[BLE_TASK] Complete message parsed: '$message'");

                  // Nachricht an Parser senden
                  _parseBleMessage(cleanMessage);

                  // Buffer kürzen
                  _buffer = _buffer.substring(end + 1);
                }
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