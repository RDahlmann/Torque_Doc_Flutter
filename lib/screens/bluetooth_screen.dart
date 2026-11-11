import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../globals.dart';
import '../main.dart';
import '../styles/app_colors.dart';
import '../utils/translation.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_template.dart';

class DeviceData {
  final String id;
  final String name;

  DeviceData({
    required this.id,
    required this.name,
  });
}

class BluetoothScreen extends StatefulWidget {
  final bool isInitialScreen;

  const BluetoothScreen({
    super.key,
    this.isInitialScreen = false,
  });

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<DeviceData> devicesList = [];
  DeviceData? selectedDevice;

  bool isConnected = false;
  bool isScanning = false;

  late final t = Provider.of<Translations>(context, listen: false);

  // ---------------------------------------------------------
  // BLE-BERECHTIGUNGEN
  // ---------------------------------------------------------

  Future<bool> ensureBlePermissions() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

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

    return statuses.values.every((status) => status.isGranted);
  }

  // ---------------------------------------------------------
  // BLE-DIENST STARTEN
  // ---------------------------------------------------------

  Future<void> _startBleService() async {
    final granted = await ensureBlePermissions();

    if (!mounted) return;

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.text('bt_permission_error')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: t.text('bt_scan_notification_title'),
      notificationText: t.text('bt_scan_notification_text'),
      callback: startBleTask,
    );

    debugPrint('[BLE_SCREEN] Foreground BLE service started');
  }

  // ---------------------------------------------------------
  // INITIALISIERUNG
  // ---------------------------------------------------------

  @override
  void initState() {
    super.initState();

    debugPrint('[BLE_SCREEN] initState called');

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);

    _startBleService();
  }

  // ---------------------------------------------------------
  // NACHRICHTEN VOM FOREGROUND-DIENST
  // ---------------------------------------------------------

  void _handleTaskData(dynamic data) {
    debugPrint('[BLE_SCREEN] onReceiveData: $data');

    if (!mounted || data is! Map) return;

    if (data['event'] == 'deviceFound') {
      final id = data['id'] as String?;
      final name = data['name'] as String?;

      if (id == null) return;

      final newDevice = DeviceData(
        id: id,
        name: name ?? id,
      );

      connectedDeviceName = name ?? '';

      setState(() {
        if (!devicesList.any((device) => device.id == id)) {
          devicesList.add(newDevice);

          debugPrint(
            '[BLE_SCREEN] Device added: '
                '${newDevice.name} (${newDevice.id})',
          );
        }

        isScanning = true;
      });
    }

    if (data['event'] == 'connected') {
      setState(() {
        isConnected = true;
        isScanning = false;
      });

      debugPrint(
        '[BLE_SCREEN] Device connected: '
            '${data['name']} (${data['id']})',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.text('bt1')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (data['event'] == 'connectError') {
      setState(() {
        isConnected = false;
      });

      debugPrint(
        '[BLE_SCREEN] Connection error: ${data['error']}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.text('bt2')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (data['event'] == 'stateconnected') {
      setState(() {
        isConnected = true;
      });
    }

    if (data['event'] == 'statedisconnected') {
      setState(() {
        isConnected = false;
      });
    }
  }

  // ---------------------------------------------------------
  // GERÄT AUSWÄHLEN
  // ---------------------------------------------------------

  void _selectDevice(DeviceData device) {
    setState(() {
      selectedDevice = device;
    });

    debugPrint(
      '[BLE_SCREEN] Selected device: '
          '${device.name} (${device.id})',
    );

    FlutterForegroundTask.sendDataToTask({
      'event': 'connectDevice',
      'id': device.id,
    });
  }

  // ---------------------------------------------------------
  // BEFEHL SENDEN
  // ---------------------------------------------------------

  void _sendCommand(String cmd) {
    debugPrint('[BLE_SCREEN] Sending command: $cmd');

    FlutterForegroundTask.sendDataToTask({
      'event': 'writeCommand',
      'command': cmd,
    });
  }

  // ---------------------------------------------------------
  // SCAN STARTEN
  // ---------------------------------------------------------

  void _startScan() {
    debugPrint('[BLE_SCREEN] Requesting new scan');

    setState(() {
      devicesList.clear();
      selectedDevice = null;
      isScanning = true;
    });

    FlutterForegroundTask.sendDataToTask({
      'event': 'startScan',
    });
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  @override
  void dispose() {
    debugPrint('[BLE_SCREEN] dispose called');

    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);

    super.dispose();
  }

  // ---------------------------------------------------------
  // KARTEN-DESIGN
  // ---------------------------------------------------------

  Widget _buildCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------
  // ABSCHNITTS-TITEL
  // ---------------------------------------------------------

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.infoBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.blue,
            size: 25,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // VERBINDUNGSSTATUS
  // ---------------------------------------------------------

  Widget _buildStatus() {
    final Color statusColor = isConnected
        ? AppColors.success
        : isScanning
        ? AppColors.warning
        : AppColors.textSecondary;

    final String statusText = isConnected
        ? t.text('bt_connected')
        : isScanning
        ? t.text('bt_scanning')
        : t.text('bt_disconnected');

    final IconData statusIcon = isConnected
        ? Icons.bluetooth_connected
        : isScanning
        ? Icons.bluetooth_searching
        : Icons.bluetooth_disabled;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // GERÄTEANZAHL
  // ---------------------------------------------------------

  String _deviceCountText() {
    if (devicesList.isEmpty) {
      return t.text('bt_device_count_zero');
    }

    if (devicesList.length == 1) {
      return t.text('bt_device_count_one');
    }

    return t.textArgs(
      'bt_device_count_many',
      {'count': devicesList.length},
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      child: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KOPFBEREICH

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.darkBlue,
                      AppColors.blue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.bluetooth,
                        color: AppColors.textOnPrimary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.text('bt_title'),
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            t.text('bt_subtitle'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // STATUSKARTE

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      icon: Icons.monitor_heart_outlined,
                      title: t.text('bt_status'),
                      subtitle: t.text('bt_status_description'),
                    ),
                    const SizedBox(height: 20),
                    _buildStatus(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // GERÄTEAUSWAHL

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      icon: Icons.devices,
                      title: t.text('bt_select_device'),
                      subtitle: t.text('bt_search_hint'),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      t.text('bt_device_label'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundInput,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DeviceData>(
                          isExpanded: true,
                          value: selectedDevice,
                          hint: Row(
                            children: [
                              const Icon(
                                Icons.bluetooth_searching,
                                color: AppColors.textSecondary,
                                size: 21,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  devicesList.isEmpty
                                      ? t.text('bt_no_devices')
                                      : t.text('bt3'),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.blue,
                            size: 28,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          items: devicesList.map((device) {
                            return DropdownMenuItem<DeviceData>(
                              value: device,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bluetooth,
                                    color: AppColors.blue,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      device.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (device) {
                            if (device != null) {
                              _selectDevice(device);
                            }
                          },
                        ),
                      ),
                    ),

                    if (selectedDevice != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.successBackground,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.text('bt_selected_device'),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    selectedDevice!.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    AppButtons.primary(
                      text: t.text(
                        isScanning ? 'bt_scan_again' : 'bt_scan',
                      ),
                      icon: Icons.search_rounded,
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.textOnPrimary,
                      minHeight: 54,
                      verticalPadding: 0,
                      onPressed: _startScan,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 17,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _deviceCountText(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // WEITER

              AppButtons.primary(
                text: t.text('weiter'),
                icon: Icons.arrow_forward_rounded,
                minHeight: 56,
                verticalPadding: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                onPressed: () {
                  if (widget.isInitialScreen) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}