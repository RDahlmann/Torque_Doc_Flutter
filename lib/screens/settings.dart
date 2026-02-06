import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';
import '../utils/translation.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../providers/field_settings.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class Settingsscreen extends StatefulWidget {
  @override
  _SettingsscreenState createState() => _SettingsscreenState();
}

class _SettingsscreenState extends State<Settingsscreen> {
  @override
  void initState() {
    super.initState();
    // BLE-Kommunikation initialisieren
    FlutterForegroundTask.initCommunicationPort();
    // Callback nur notwendig, falls Settings selbst Daten empfangen soll
    // FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
  }

  // 🔹 Funktion zum Senden von BLE-Kommandos
  void _sendCommand(String cmd) {
    debugPrint("[SETTINGS_SCREEN] Sending command: $cmd");
    FlutterForegroundTask.sendDataToTask({
      'event': 'writeCommand',
      'command': cmd,
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = Provider.of<FieldSettings>(context);
    late final t = Provider.of<Translations>(context);

    return AppTemplate(
      hideSettingsIcon: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),

            // 🔸 Impressum & Datenschutz
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🔸 Impressum
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse("https://www.stephandahlmann.com/impressum"));//Standart
                    //launchUrl(Uri.parse("https://www.alkitronic.com/en/privacy-policy/legal-notice/"));//Alkitronik
                  },
                  child: Text(
                    t.text('set11'),
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                // 🔸 Datenschutz
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse("https://www.stephandahlmann.com/datenschutz"));//Standart
                    //launchUrl(Uri.parse("https://www.alkitronic.com/en/privacy-policy/"));//Alkitronik
                  },
                  child: Text(
                    t.text('set12'),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 🔹 Sprache
            Text(t.text('set1'), style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: DropdownButton<String>(
                value: fields.language == 'de' ? 'Deutsch' : 'English',
                items: ['English', 'Deutsch']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    String langCode = val == 'Deutsch' ? 'de' : 'en';
                    fields.setLanguage(langCode);
                    await t.setLocale(langCode);
                  }
                },
              ),
            ),

            SizedBox(height: 24),

            // 🔹 Modus (Dropdown)
            Center(
              child: DropdownButtonHideUnderline(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<bool>(
                    value: fields.automatik,
                    items: [
                      DropdownMenuItem(value: true, child: Text(t.text('set3'))),
                      DropdownMenuItem(value: false, child: Text(t.text('set4'))),
                    ],
                    onChanged: (val) {
                      if (val != null) fields.setAutomatik(val);
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
            // 🔹 CSV / PDF Checkboxen
            Text(t.text('set14'), style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text("CSV"),
              value: fields.csv,
              onChanged: (val) => fields.setCSV(val!),
            ),
            CheckboxListTile(
              title: Text("PDF"),
              value: fields.pdf,
              onChanged: (val) => fields.setPDF(val!),
            ),

            SizedBox(height: 24),

            // 🔹 Druckeinheit
            Text(t.text('set10'), style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: DropdownButton<String>(
                value: DRUCK_EINHEIT,
                items: ['Bar', 'PSI']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    DRUCK_EINHEIT = val;
                    await saveSettings();
                    setState(() {});
                  }
                },
              ),
            ),

            SizedBox(height: 24),

            // 🔹 Drehmoment-Einheit
            Text(t.text('set13'), style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: DropdownButton<String>(
                value: DREHMOMENT_EINHEIT,
                items: ['Nm', 'Ft Lbs.']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    DREHMOMENT_EINHEIT = val;
                    await saveSettings();
                    setState(() {});
                  }
                },
              ),
            ),

            SizedBox(height: 24),

            // 🔹 Pflichtfelder
            Text(t.text('set5'), style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text(t.text('set6')),
              value: fields.requireName,
              onChanged: (val) => fields.setField('requireName', val!),
            ),
            CheckboxListTile(
              title: Text(t.text('set7')),
              value: fields.requireSerialTool,
              onChanged: (val) => fields.setField('requireSerialTool', val!),
            ),
            CheckboxListTile(
              title: Text(t.text('set8')),
              value: fields.requireSerialHose,
              onChanged: (val) => fields.setField('requireSerialHose', val!),
            ),

            SizedBox(height: 24),

            // 🔹 Update Button
            AppButtons.primaryText(
              text: t.text('set9'),
              onPressed: () {
                Navigator.pushNamed(context, '/update');
              },
              verticalPadding: 16,
            ),

            // 🔹 Zurück-Button
            AppButtons.primaryText(
              text: t.text('zurueck'),
              onPressed: () {
                Navigator.pop(context);

                // 🔹 Automatik-Logik nur, wenn Autoscreen aktiv
                if (isauto) {
                  iscomplete = false;
                  isaborted1 = false;
                  isaborted2 = false;

                  final now = DateTime.now();
                  final formattedDate =
                      "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";

                  if (!isSchrauben) {
                    _sendCommand('-STOP\$');
                  } else {
                    if (Automatik) {
                      _sendCommand(
                        '-AutomatikA $pwm $Projectnumber $formattedDate '
                            '$SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                      );
                    } else {
                      _sendCommand(
                        '-AutomatikM $pwm $Projectnumber $formattedDate '
                            '$SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
                      );
                    }
                  }
                }
              },
              verticalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }
}
