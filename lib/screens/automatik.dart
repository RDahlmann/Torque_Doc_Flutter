import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:torquedoc/styles/RotatingSignal.dart';
import 'package:torquedoc/styles/app_text_styles.dart';
import '../styles/FadingCircle.dart';
import '../utils/file_exporter.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';
import '../globals.dart';
import '../styles/app_colors.dart';

class Autoscreen extends StatefulWidget {

  @override
  _Autoscreenstate createState() => _Autoscreenstate();
}

class _Autoscreenstate  extends State<Autoscreen> {
  // Beispiel: Hier können Controller oder Variablen für jeden Screen definiert werden
  late TextEditingController exampleController;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> BLE_Werteliste = [];

  @override
  void initState() {
    super.initState();
    exampleController = TextEditingController();
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
  }

  void _handleTaskData(dynamic data) {
    if (!mounted) return;
    if (data is Map && data['event'] == 'laeuft') {
      setState(() {
        isrunning = true;
        isaborted1=false;
        isaborted2=false;
        iscomplete=false;
      });
    }
    if (data is Map && data['event'] == 'abgebrochen1') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste = List<Map<String, dynamic>>.from(data['Werteliste']);
        });
      }
      setState(() {
        isrunning = false;
        isaborted1=true;
        isaborted2=false;
        iscomplete=false;
        _sendCommand('-STOP\$');
      });
    }
    if (data is Map && data['event'] == 'abgebrochen2') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste = List<Map<String, dynamic>>.from(data['Werteliste']);
        });
      }
      setState(() {
        isrunning = false;
        isaborted1=false;
        isaborted2=true;
        iscomplete=false;
        _sendCommand('-STOP\$');
      });
    }

    if (data is Map && data['event'] == 'angezogen') {
      if (data['Werteliste'] != null && data['Werteliste'] is List) {
        setState(() {
          BLE_Werteliste = List<Map<String, dynamic>>.from(data['Werteliste']);
        });
        markiereLetztenEintrag("IO");
      }
      setState(() {
        akt_schraube++;
        if(akt_schraube>SCHRAUBENANZAHL){
          isrunning = false;
          isaborted1=false;
          isaborted2=false;
          iscomplete=true;
          _sendCommand('-STOP\$');

        }else
          {
            isrunning = false;
          isaborted1=false;
          isaborted2=false;
          iscomplete=false;
          }
      });

    }

  }
  void markiereLetztenEintrag(String status) {
    if (BLE_Werteliste.isNotEmpty) {
      BLE_Werteliste[BLE_Werteliste.length - 1]["Nr."] = akt_schraube;
      BLE_Werteliste[BLE_Werteliste.length - 1]["Solldruck"] = SOLLDRUCKBAR;
      BLE_Werteliste[BLE_Werteliste.length - 1]["IO"] = status;
      setState(() {});

      // 🔹 Direkt PDF exportieren, nachdem geändert
      _sendPDF();
    }
  }
  /// PDF Export aufrufen
  void _sendCommand(String cmd) {
    debugPrint("[BLE_SCREEN] Sending command: $cmd");
    FlutterForegroundTask.sendDataToTask({
      'event': 'writeCommand',
      'command': cmd,
    });
  }

  void _sendPDF(){
    FlutterForegroundTask.sendDataToTask({
      'event': 'pdferstellen',
      'Werteliste': BLE_Werteliste,
      'Projectnumber': Projectnumber,
      'UserName': UserName,
      'Serialpump': Serialpump,
      'Serialhose': Serialhose,
      'Serialtool': Serialtool,
      'Tool': Tool,
    });
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
    exampleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // verhindert System-Zurück
      child: AppTemplate(
        child: SingleChildScrollView(
          child: isSchrauben==false
          ?Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 24),
              Text(
                "Bitte Schraubenzahl eingeben",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              // Beispiel für Eingabefeld
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Anzahl Schrauben",
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Weiter Button
              AppButtons.primaryText(
                text: "Bestätigen",
                onPressed: () {
                  if (_controller.text.isEmpty) return;
                  SCHRAUBENANZAHL = int.tryParse(_controller.text) ?? 0;
                  if (SCHRAUBENANZAHL > 0) {
                    final now = DateTime.now();
                    final formattedDate = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";

                    if(Automatik){
                         _sendCommand('-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                    }
                    else{
                      _sendCommand('-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                    }

                    setState(() {
                      isSchrauben = true;
                    });// Beispiel: Navigiere zum nächsten Screen

                  }// Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
                },
                verticalPadding: 16,
              ),

              // Optional: Zurück Button (Navigation nur über Button)
              AppButtons.primaryText(
                text: "Zurück",
                onPressed: () {
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
                  _sendCommand('-STOP\$');
                  Navigator.pop(context); // Zurück zum vorherigen Screen
                },
                verticalPadding: 16,
              ),
            ],
          )
              : (isaborted1 || isaborted2)
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              Text(
                isaborted1 ? 'Der Schraubvorgang wurde vom Nutzer abgebrochen ' : 'Schraubvorgang nach dem ersten Hub aufgrund der Festigkeitsprüfung abgebrochen',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              AppButtons.primaryText(
                text: isaborted1 ? 'Vorgang abgebrochen, Schraube ist fest' : 'Die Schraube war beim Start Lose',
                onPressed: () {
                  final now = DateTime.now();
                  final formattedDate = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";
                  markiereLetztenEintrag("IO");
                  setState(() {
                    akt_schraube++;
                    if(akt_schraube>SCHRAUBENANZAHL){
                      isrunning = false;
                      isaborted1=false;
                      isaborted2=false;
                      iscomplete=true;
                      _sendCommand('-STOP\$');

                    }else
                    {
                      isrunning = false;
                      isaborted1=false;
                      isaborted2=false;
                      iscomplete=false;
                      if(Automatik){
                        _sendCommand('-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                      }
                      else{
                        _sendCommand('-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                      }
                    }
                  }
                  );
                },
                verticalPadding: 16,
                backgroundColor: AppColors.green,
              ),
              AppButtons.primaryText(
                text: isaborted1 ? 'Vorgang abgebrochen, Schraube ist nicht fest' : 'Die Schraube war beim Start nicht Lose',
                onPressed: () {
                  markiereLetztenEintrag("NIO");
                  final now = DateTime.now();
                  final formattedDate = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";

                  setState(() {
                    isrunning = false;
                    isaborted1=false;
                    isaborted2=false;
                    iscomplete=false;
                    if(Automatik){
                      _sendCommand('-AutomatikA $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                    }
                    else{
                      _sendCommand('-AutomatikM $pwm $Projectnumber $formattedDate $SOLLDRUCK $referenzzeitkal $vorreferenzzeit $SCHRAUBENANZAHL\$');
                    }
                  });
                },
                backgroundColor: AppColors.red,
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: "Zurück",
                onPressed: () {
                  _sendCommand('-STOP\$');
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
                  Navigator.pop(context); // Zurück zum vorherigen Screen
                },
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
                'Alle Schrauben angezogen, bitte zurück zum Hauptmenü',
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
                    color: AppColors.green, // grün hinterlegt
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,    // Haken-Symbol
                      color: Colors.white, // Haken in Weiß
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AppButtons.primaryText(
                text: "Zurück",
                onPressed: () {
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
                  _sendCommand('-STOP\$');
                  Navigator.pop(context); // Zurück zum vorherigen Screen
                },
                verticalPadding: 16,
              ),
            ],
          )

          :Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                isrunning ? 'Verschrauben läuft...' : 'Bereit zum Verschrauben...',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 50,
                height: 50,
                child: isrunning
                    ? const RotatingSignal()
                    : const FadingCircle()
              ),
              const SizedBox(width: 16), // Abstand zwischen Kreis und Text


              Text(
                'Schraube $akt_schraube von $SCHRAUBENANZAHL',
                style: AppTextStyles.body
              ),
              const SizedBox(height: 16), // Abstand zwischen Text und Button
              Text(
                  DRUCK_EINHEIT=="PSI"?'Solldruck $SOLLDRUCKPSI PSI':'Solldruck: $SOLLDRUCKBAR Bar',
                  style: AppTextStyles.body
              ),
              const SizedBox(height: 16),

              AppButtons.primaryText(
                text: "Zurück",
                onPressed: () {
                  isrunning = false;
                  isaborted1 = false;
                  isaborted2 = false;
                  iscomplete = false;
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
