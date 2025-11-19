import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../providers/field_settings.dart';

class Settingsscreen extends StatefulWidget {
  @override
  _SettingsscreenState createState() => _SettingsscreenState();
}

class _SettingsscreenState extends State<Settingsscreen>{
  @override
  Widget build(BuildContext context) {
    final fields = Provider.of<FieldSettings>(context);

    return AppTemplate(
      hideSettingsIcon: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),

            // 🔹 Sprache
            Text("Sprache auswählen", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: DropdownButton<String>(
                value: fields.language == 'de' ? 'Deutsch' : 'Englisch',
                items: ['Deutsch', 'Englisch']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    fields.setLanguage(val == 'Deutsch' ? 'de' : 'en');
                  }
                },
              ),
            ),

            SizedBox(height: 24),

            // 🔹 Modus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Modus", style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: fields.automatik,
                  onChanged: (val) => fields.setAutomatik(val),
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ],
            ),

            SizedBox(height: 24),
            Text("Druckeinheit auswählen", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    await saveSettings(); // Speichert die Auswahl in SharedPreferences
                    setState(() {});
                  }
                },
              ),
            ),
            SizedBox(height: 24),

            // 🔹 Pflichtfelder Checkboxen
            Text("Pflichtfelder", style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text("Name"),
              value: fields.requireName,
              onChanged: (val) => fields.setField('requireName', val!),
            ),
            CheckboxListTile(
              title: Text("Seriennummer Werkzeug"),
              value: fields.requireSerialTool,
              onChanged: (val) => fields.setField('requireSerialTool', val!),
            ),
            CheckboxListTile(
              title: Text("Seriennummer Schlauch"),
              value: fields.requireSerialHose,
              onChanged: (val) => fields.setField('requireSerialHose', val!),
            ),

            SizedBox(height: 24),

            AppButtons.primaryText(
              text: "Zurück",
              onPressed: () => Navigator.pop(context,true),
              verticalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }
}
