import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

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
    return WillPopScope(
      onWillPop: () async => false, // verhindert System-Zurück
      child: AppTemplate(
        child: SingleChildScrollView(
          child: Column(
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
