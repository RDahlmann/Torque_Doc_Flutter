import 'package:flutter/foundation.dart';

class BleConnectionNotifier extends ValueNotifier<Map<String, dynamic>> {
  BleConnectionNotifier()
      : super({'isConnected': false, 'deviceName': ''});

  void update({bool? connected, String? name}) {
    value = {
      'isConnected': connected ?? value['isConnected'],
      'deviceName': name ?? value['deviceName'],
    };
    notifyListeners(); // wichtig für UI-Update
  }
}

// Globale Instanz (kann überall importiert werden)
final bleConnectionNotifier = BleConnectionNotifier();
