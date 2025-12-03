import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:torquedoc/styles/app_text_styles.dart';
import '../globals.dart';
import '../styles/RotatingSignal.dart';
import '../styles/app_colors.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Kalibrierscreen extends StatefulWidget {
  @override
  _Kalibrierscreenstate createState() => _Kalibrierscreenstate();
}

class _Kalibrierscreenstate extends State<Kalibrierscreen> {
  late TextEditingController exampleController;
  late final t = Provider.of<Translations>(context);
  @override
  void initState() {
    super.initState();
    exampleController = TextEditingController();

    // Foreground Task Kommunikation aktivieren
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);

    // Falls der Zustand global schon gesetzt ist (z. B. beim Zurücknavigieren)

  }

  void _handleTaskData(dynamic data) {
    if (!mounted) return;
    if (data is Map && data['event'] == 'kalibriert') {
      pwm=data['pwm'] as int?;
      referenzzeitkal=data['referenzzeitkal'] as int?;
      vorreferenzzeit=data['vorreferenzzeit'] as int?;

      setState(() {
        iskalibriert = true;
      });

    }
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 🔹 Statusanzeige (sichtbar, solange noch nicht kalibriert)
              if (!iskalibriert)
                Column(
                  children: [
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: RotatingSignal(
                        color: AppColors.darkblue, // <-- beliebige Farbe
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(t.text('kal1'),
                        style:AppTextStyles.body,textAlign: TextAlign.center,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // 🔹 Weiter-Button (sichtbar, wenn kalibriert)
              if (iskalibriert)
                AppButtons.primaryText(
                  text: t.text('weiter'),
                  onPressed: () {
                    akt_schraube=1;
                    isSchrauben=false;
                    debugPrint("🔧 Kalibrierung weiter gedrückt -> pwm=$pwm, vorreferenzzeit=$vorreferenzzeit, referenzzeitkal=$referenzzeitkal");
                    Navigator.pushNamed(context, '/menu');
                  },
                  verticalPadding: 16,
                ),

              const SizedBox(height: 12),

              // 🔹 Zurück Button
              AppButtons.primaryText(
                text: t.text('zurueck'),
                onPressed: () => Navigator.pop(context),
                verticalPadding: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
