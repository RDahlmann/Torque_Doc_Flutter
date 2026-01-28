import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Menuscreen extends StatefulWidget {

  @override
  _Menuscreenstate createState() => _Menuscreenstate();
}

class _Menuscreenstate  extends State<Menuscreen> {
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

  void _handleTaskData(dynamic data) {

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // verhindert System-Zurück
      child: AppTemplate(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 24),


              // Weiter Button
              AppButtons.primaryText(
                text: t.text('menu1'),
                onPressed: () {
                  iscomplete = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  isauto=true;
                  final now = DateTime.now();
                  final formattedDate = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";

                  if (!isSchrauben) {
                    // Standard-Fall: Schraubenanzahl noch nicht eingegeben

                    _sendCommand('-STOP\$');
                  } else {
                    // Automatik-Modus: Schrauben laufen bereits
                    if (Automatik) {
                      _sendCommand('-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$');
                    } else {
                      _sendCommand('-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$');
                    }
                  }
                  Navigator.pushNamed(context, '/auto');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('menu2'),
                onPressed: () {
                  Navigator.pushNamed(context, '/manuell');
                  _sendCommand('-Manuell $pwm $SOLLDRUCK\$');
                },
                verticalPadding: 16,
              ),

              // Optional: Zurück Button (Navigation nur über Button)
              AppButtons.primaryText(
                text: t.text('menu3'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/choose');// Zurück zum vorherigen Screen
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
