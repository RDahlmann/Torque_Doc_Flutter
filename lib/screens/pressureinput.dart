import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_toast.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';
import 'package:flutter/services.dart';

class pressurescreen extends StatefulWidget {
  @override
  _pressurescreenstate createState() => _pressurescreenstate();
}

class _pressurescreenstate extends State<pressurescreen> {
  late TextEditingController exampleController;
  late int _eingabe=0;
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

  @override
  Widget build(BuildContext context) {
    final bool isPSI = DRUCK_EINHEIT == "PSI";
    final String unitLabel = isPSI ? "PSI" : "Bar";
    final int minDruck = isPSI ? (150 * 14.5038).round() : 150; // min in bar
    final int maxDruck = isPSI ? (650 * 14.5038).round() : 650; // max in bar

    return WillPopScope(
      onWillPop: () async => false,
      child: AppTemplate(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              TextField(
                style: AppTextStyles.body,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: isPSI
                      ? t.text('pres2')
                      : t.text('pres1'),
                  hintText: t.text('pres3'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(isPSI ? "PSI" : "bar", style: AppTextStyles.body),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  labelStyle: AppTextStyles.body,
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                ),
                onChanged: (value) {
                  // Nur lokale Variable setzen, SOLLDRUCK wird erst beim Weiter gedrückt
                  _eingabe = int.tryParse(value) ?? 0;
                },
              ),

              AppButtons.primaryText(
                text: "Weiter",
                onPressed: () {
                  int druckBar;
                  if (isPSI) {
                    SOLLDRUCKPSI=_eingabe;
                    druckBar = (_eingabe / 14.5038).round(); // Umrechnung PSI → Bar
                    SOLLDRUCKBAR=druckBar;
                  } else {
                    druckBar = _eingabe;
                    SOLLDRUCKBAR=_eingabe;
                    SOLLDRUCKPSI=(_eingabe*14.503).round();
                  }

                  if (druckBar < 150 || druckBar > 650) {
                    AppToast.warning(
                        isPSI
                            ? t.text('pres5')
                            : t.text('pres4')
                    );
                    SOLLDRUCK = 0;
                    return;
                  }else{
                    SOLLDRUCK = druckBar; // In Bar speichern
                    _sendCommand('-SETP $SOLLDRUCK\$');
                    iskalibriert=false;
                    FlutterForegroundTask.sendDataToTask({
                      'event': 'ispressure',
                    });
                    Navigator.pushNamed(context, '/kalibration');
                  }


                },
                verticalPadding: 16,
              ),

              AppButtons.primaryText(
                text: t.text('zurueck'),
                onPressed: () {
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
