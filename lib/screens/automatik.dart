import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:torquedoc/main.dart';
import 'package:torquedoc/styles/RotatingSignal.dart';
import 'package:torquedoc/styles/app_text_styles.dart';
import '../styles/FadingCircle.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';
import '../globals.dart';
import '../styles/app_colors.dart';
import 'bluetooth_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class Autoscreen extends StatefulWidget {
  @override
  _Autoscreenstate createState() => _Autoscreenstate();
}

class _Autoscreenstate extends State<Autoscreen> {
  late TextEditingController exampleController;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> BLE_Werteliste = [];
  late final t = Provider.of<Translations>(context);

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
    return true;
  }

  Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt =
          (await DeviceInfoPlugin().androidInfo).version.sdkInt ?? 0;

      if (sdkInt < 29) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    exampleController = TextEditingController();
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
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

    if (data is Map && data['event'] == 'laeuft') {
      setState(() {
        isrunning = true;
        isaborted1 = false;
        isaborted2 = false;
        iscomplete = false;
        isnotintol = false;
        isfehler = false;
        isnotconnected = false;
        isdisconnect = false;
      });
    }

    if (data is Map && data['event'] == 'fehler') {
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

    if (data is Map && data['event'] == 'abgebrochen1') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste =
          List<Map<String, dynamic>>.from(data['Werteliste']);
        });
      }

      setState(() {
        isrunning = false;
        isaborted1 = true;
        isaborted2 = false;
        iscomplete = false;
        isnotintol = false;
        isfehler = false;
        isnotconnected = false;
        isdisconnect = false;
        _sendCommand('-STOP\$');
      });
    }

    if (data is Map && data['event'] == 'abgebrochen2') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste =
          List<Map<String, dynamic>>.from(data['Werteliste']);
        });
      }

      setState(() {
        isrunning = false;
        isaborted1 = false;
        isaborted2 = true;
        iscomplete = false;
        isnotintol = false;
        isfehler = false;
        isnotconnected = false;
        isdisconnect = false;
        _sendCommand('-STOP\$');
      });
    }

    if (data is Map && data['event'] == 'angezogen') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste =
          List<Map<String, dynamic>>.from(data['Werteliste']);
        });

        if (toleranzpruefung()) {
          markiereLetztenEintrag("IO");
          setState(() {
            akt_schraube++;

            if (akt_schraube > SCHRAUBENANZAHL) {
              isrunning = false;
              isaborted1 = false;
              isaborted2 = false;
              iscomplete = true;
              isnotintol = false;
              isfehler = false;
              isnotconnected = false;
              isdisconnect = false;
              _sendCommand('-STOP\$');
            } else {
              isrunning = false;
              isaborted1 = false;
              isaborted2 = false;
              iscomplete = false;
              isnotintol = false;
              isfehler = false;
              isnotconnected = false;
              isdisconnect = false;
            }
          });
        } else {
          setState(() {
            markiereLetztenEintrag("NIO");
            isrunning = false;
            isaborted1 = false;
            isaborted2 = false;
            iscomplete = false;
            isnotintol = true;
            isfehler = false;
            isnotconnected = false;
            isdisconnect = false;
            _sendCommand('-STOP\$');
          });
        }
      }
    }
  }

  bool toleranzpruefung() {
    if (BLE_Werteliste.isEmpty) return false;

    final last = BLE_Werteliste.last;

    int soll = SOLLDRUCKBAR;
    int ist = int.tryParse(last["Nenndruck"].toString()) ?? 0;

    if (soll == 0) return false;

    double percent = (ist / soll) * 100;

    int? tol = int.tryParse(Toleranz);
    if (tol == null) return false;

    double tolmax = 100.0 + tol;
    double tolmin = 100.0 - tol;

    return percent >= tolmin && percent <= tolmax;
  }

  void markiereLetztenEintrag(String status) {
    if (BLE_Werteliste.isEmpty) return;

    final last = BLE_Werteliste.last;

    last["Nr."] = akt_schraube;
    last["IO"] = status;

    final dynamic sollTorqueRaw = last["Solldrehmoment"];
    final dynamic nennTorqueRaw = last["Nenndrehmoment"];

    last["Solldrehmoment"] = (sollTorqueRaw is int)
        ? (DREHMOMENT_EINHEIT == "Nm"
        ? sollTorqueRaw
        : convertNmToSelected(sollTorqueRaw))
        : "-";

    last["Nenndrehmoment"] = (nennTorqueRaw is int)
        ? (DREHMOMENT_EINHEIT == "Nm"
        ? nennTorqueRaw
        : convertNmToSelected(nennTorqueRaw))
        : "-";

    if (DRUCK_EINHEIT == 'PSI') {
      last["Solldruck"] = SOLLDRUCKPSI;
      last["Nenndruck"] = (last["Nenndruck"] * 14.503).round();
    } else {
      last["Solldruck"] = SOLLDRUCKBAR;
    }

    BLE_WertelisteGlobal.add(Map<String, dynamic>.from(last));

    if (ISCSV) {
      if (DRUCK_EINHEIT == 'PSI') {
        _sendCSVPSI();
      } else {
        _sendCSVbar();
      }
    }

    if (ISPDF) {
      if (DRUCK_EINHEIT == 'PSI') {
        _sendPDFPSI();
      } else {
        _sendPDFbar();
      }
    }

    setState(() {});
  }

  void _sendCommand(String cmd) {
    debugPrint("[BLE_SCREEN] Sending command: $cmd");
    FlutterForegroundTask.sendDataToTask({
      'event': 'writeCommand',
      'command': cmd,
    });
  }

  void _sendFehler(String cmd) {
    debugPrint("[BLE_SCREEN] Sending command: $cmd");
    FlutterForegroundTask.sendDataToTask({
      'event': 'fehlerCommand',
      'command': cmd,
    });
  }

  Future<void> _sendPDFbar() async {
    final granted = await ensureStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speicher-Permission benötigt, um PDF zu erstellen!'),
        ),
      );
      return;
    }

    final lang =
        Provider.of<Translations>(context, listen: false).currentLanguage;

    FlutterForegroundTask.sendDataToTask({
      'event': 'pdferstellen',
      'Werteliste': BLE_WertelisteGlobal,
      'Projectnumber': Projectnumber,
      'UserName': UserName,
      'Serialpump': Serialpump,
      'Serialhose': Serialhose,
      'Serialtool': Serialtool,
      'Tool': Tool,
      'Toleranz': Toleranz,
      'Einheit': "bar",
      'EinheitD': DREHMOMENT_EINHEIT,
      'Trans': lang,
      'isTorque': istorque,
      'torquelist': TORQUELIST,
      'toolname': TOOLNAME,
      'pressurelist': PRESSURELIST,
      'solltorque': SOLLTORQUE,
    });
  }

  Future<void> _sendPDFPSI() async {
    final granted = await ensureStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speicher-Permission benötigt, um PDF zu erstellen!'),
        ),
      );
      return;
    }

    final lang =
        Provider.of<Translations>(context, listen: false).currentLanguage;

    FlutterForegroundTask.sendDataToTask({
      'event': 'pdferstellen',
      'Werteliste': BLE_WertelisteGlobal,
      'Projectnumber': Projectnumber,
      'UserName': UserName,
      'Serialpump': Serialpump,
      'Serialhose': Serialhose,
      'Serialtool': Serialtool,
      'Tool': Tool,
      'Toleranz': Toleranz,
      'Einheit': "PSI",
      'EinheitD': DREHMOMENT_EINHEIT,
      'Trans': lang,
      'isTorque': istorque,
      'torquelist': TORQUELIST,
      'toolname': TOOLNAME,
      'pressurelist': PRESSURELIST,
      'solltorque': SOLLTORQUE,
    });
  }

  Future<void> _sendCSVbar() async {
    final granted = await ensureStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speicher-Permission benötigt, um CSV zu erstellen!'),
        ),
      );
      return;
    }

    print("DEBUG: Serialpump='$Serialpump'");

    final lang =
        Provider.of<Translations>(context, listen: false).currentLanguage;

    FlutterForegroundTask.sendDataToTask({
      'event': 'csverstellen',
      'Werteliste': BLE_WertelisteGlobal,
      'Projectnumber': Projectnumber,
      'UserName': UserName,
      'Serialpump': Serialpump,
      'Serialhose': Serialhose,
      'Serialtool': Serialtool,
      'Tool': Tool,
      'Toleranz': Toleranz,
      'Einheit': "bar",
      'EinheitD': DREHMOMENT_EINHEIT,
      'Trans': lang,
      'isTorque': istorque,
      'torquelist': TORQUELIST,
      'toolname': TOOLNAME,
      'pressurelist': PRESSURELIST,
      'solltorque': SOLLTORQUE,
    });
  }

  Future<void> _sendCSVPSI() async {
    final granted = await ensureStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speicher-Permission benötigt, um CSV zu erstellen!'),
        ),
      );
      return;
    }

    final lang =
        Provider.of<Translations>(context, listen: false).currentLanguage;

    FlutterForegroundTask.sendDataToTask({
      'event': 'csverstellen',
      'Werteliste': BLE_WertelisteGlobal,
      'Projectnumber': Projectnumber,
      'UserName': UserName,
      'Serialpump': Serialpump,
      'Serialhose': Serialhose,
      'Serialtool': Serialtool,
      'Tool': Tool,
      'Toleranz': Toleranz,
      'Einheit': "PSI",
      'EinheitD': DREHMOMENT_EINHEIT,
      'Trans': lang,
      'isTorque': istorque,
      'torquelist': TORQUELIST,
      'toolname': TOOLNAME,
      'pressurelist': PRESSURELIST,
      'solltorque': SOLLTORQUE,
    });
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
    exampleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Kopfbereich im Stil des Kalibrierscreens
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
              Icons.build_circle_outlined,
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
                  t.text('auto_header_title'),
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.text('auto_header_subtitle'),
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
              Container(
                padding: const EdgeInsets.all(20),
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
                child: isSchrauben == false
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      t.text('automatik1'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: t.text('automatik2'),
                          filled: true,
                          fillColor: AppColors.backgroundInput,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButtons.primaryText(
                      text: t.text('automatik3'),
                      onPressed: () {
                        if (_controller.text.isEmpty) return;

                        SCHRAUBENANZAHL =
                            int.tryParse(_controller.text) ?? 0;

                        if (SCHRAUBENANZAHL > 0) {
                          final now = DateTime.now();
                          final formattedDate =
                              "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

                          if (Automatik) {
                            _sendCommand(
                              '-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          } else {
                            _sendCommand(
                              '-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          }

                          setState(() {
                            isSchrauben = true;
                          });
                        }
                      },
                      verticalPadding: 16,
                    ),
                    AppButtons.primaryText(
                      text: t.text('zurueck'),
                      onPressed: () {
                        isauto = false;
                        isrunning = false;
                        isaborted1 = false;
                        isaborted2 = false;
                        iscomplete = false;
                        isnotintol = false;
                        isfehler = false;
                        isnotconnected = false;
                        _sendCommand('-STOP\$');
                        Navigator.pop(context);
                      },
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : (isaborted1 || isaborted2)
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      isaborted1
                          ? t.text('automatik4')
                          : t.text('automatik5'),
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButtons.primaryText(
                      text: isaborted2
                          ? t.text('automatik7')
                          : t.text('automatik6'),
                      onPressed: () {
                        final now = DateTime.now();
                        final formattedDate =
                            "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

                        if (toleranzpruefung()) {
                          markiereLetztenEintrag("IO");
                          setState(() {
                            akt_schraube++;

                            if (akt_schraube > SCHRAUBENANZAHL) {
                              isrunning = false;
                              isaborted1 = false;
                              isaborted2 = false;
                              iscomplete = true;
                              isnotintol = false;
                              isfehler = false;
                              isnotconnected = false;
                              _sendCommand('-STOP\$');
                            } else {
                              isrunning = false;
                              isaborted1 = false;
                              isaborted2 = false;
                              iscomplete = false;
                              isnotintol = false;
                              isfehler = false;
                              isnotconnected = false;

                              if (Automatik) {
                                _sendCommand(
                                  '-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                                );
                              } else {
                                _sendCommand(
                                  '-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                                );
                              }
                            }
                          });
                        } else {
                          markiereLetztenEintrag("NIO");
                          setState(() {
                            isrunning = false;
                            isaborted1 = false;
                            isaborted2 = false;
                            iscomplete = false;
                            isnotintol = true;
                            isfehler = false;
                            isnotconnected = false;
                            _sendCommand('-STOP\$');
                          });
                        }
                      },
                      verticalPadding: 16,
                      backgroundColor: AppColors.green,
                    ),
                    AppButtons.primaryText(
                      text: isaborted2
                          ? t.text('automatik9')
                          : t.text('automatik8'),
                      onPressed: () {
                        markiereLetztenEintrag("NIO");
                        final now = DateTime.now();
                        final formattedDate =
                            "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

                        setState(() {
                          isrunning = false;
                          isaborted1 = false;
                          isaborted2 = false;
                          iscomplete = false;
                          isnotintol = false;
                          isfehler = false;
                          isnotconnected = false;

                          if (Automatik) {
                            _sendCommand(
                              '-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          } else {
                            _sendCommand(
                              '-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          }
                        });
                      },
                      backgroundColor: AppColors.red,
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : (iscomplete)
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      t.text('automatik10'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButtons.primaryText(
                      text: t.text('zurueck'),
                      onPressed: () {
                        isauto = false;
                        isrunning = false;
                        isaborted1 = false;
                        isaborted2 = false;
                        iscomplete = false;
                        isnotintol = false;
                        isfehler = false;
                        isnotconnected = false;
                        isSchrauben = false;
                        _sendCommand('-STOP\$');
                        akt_schraube = 1;
                        Navigator.pop(context);
                      },
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : (isfehler)
                    ? Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    AppButtons.primaryText(
                      text: t.text('automatik16'),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.black,
                      onPressed: () {
                        setState(() {
                          isrunning = false;
                          isaborted1 = false;
                          isaborted2 = false;
                          iscomplete = false;
                          isnotintol = false;
                          isfehler = false;
                          isnotconnected = false;

                          final now = DateTime.now();
                          final formattedDate =
                              "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

                          if (Automatik) {
                            _sendFehler(
                              '-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          } else {
                            _sendFehler(
                              '-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          }
                        });
                      },
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : (isnotintol)
                    ? Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    AppButtons.primaryText(
                      text: t.text('automatik11'),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.black,
                      onPressed: () {
                        setState(() {
                          isrunning = false;
                          isaborted1 = false;
                          isaborted2 = false;
                          iscomplete = false;
                          isnotintol = false;
                          isfehler = false;
                          isnotconnected = false;

                          final now = DateTime.now();
                          final formattedDate =
                              "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

                          if (Automatik) {
                            _sendCommand(
                              '-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          } else {
                            _sendCommand(
                              '-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                            );
                          }
                        });
                      },
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : (isnotconnected)
                    ? Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    AppButtons.primaryText(
                      text: t.text('automatik17'),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          isrunning = false;
                          isaborted1 = false;
                          isaborted2 = false;
                          iscomplete = false;
                          isnotintol = false;
                          isfehler = true;
                          isnotconnected = false;
                          _startBleService();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const BluetoothScreen(
                                isInitialScreen:
                                false,
                              ),
                            ),
                          );
                        });
                      },
                      verticalPadding: 16,
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      isrunning
                          ? t.text('automatik12')
                          : t.text('automatik13'),
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: isrunning
                          ? const RotatingSignal()
                          : const FadingCircle(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      t.textArgs(
                        'automatik15',
                        {
                          'value': akt_schraube,
                          'unit': SCHRAUBENANZAHL,
                        },
                      ),
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.textArgs(
                        'automatik14',
                        {
                          'value':
                          DRUCK_EINHEIT == "PSI"
                              ? SOLLDRUCKPSI
                              .toString()
                              : SOLLDRUCKBAR
                              .toString(),
                          'unit': DRUCK_EINHEIT,
                        },
                      ),
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    AppButtons.primaryText(
                      text: t.text('zurueck'),
                      onPressed: () {
                        isauto = false;
                        isrunning = false;
                        isaborted1 = false;
                        isaborted2 = false;
                        iscomplete = false;
                        isnotintol = false;
                        isfehler = false;
                        isnotconnected = false;
                        _sendCommand('-STOP\$');
                        Navigator.pop(context);
                      },
                      verticalPadding: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}