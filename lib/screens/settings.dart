import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';
import '../utils/translation.dart';
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
    late final t = Provider.of<Translations>(context);
    return AppTemplate(
      hideSettingsIcon: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),


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
                    //launchUrl(Uri.parse("https://www.stephandahlmann.com/impressum"));//Standart
                    launchUrl(Uri.parse("https://www.alkitronic.com/en/privacy-policy/legal-notice/"));//Alkitronik
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
                    //launchUrl(Uri.parse("https://www.stephandahlmann.com/datenschutz"));//Standart
                    launchUrl(Uri.parse("https://www.alkitronic.com/en/privacy-policy/"));//Alkitronik
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
                value: fields.language == 'de' ? 'Deutsch' : 'Englisch',
                items: ['Deutsch', 'Englisch']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    String langCode = val == 'Deutsch' ? 'de' : 'en';
                    fields.setLanguage(langCode);     // FieldSettings updaten
                    await t.setLocale(langCode);      // Übersetzungen updaten
                  }
                },
              ),
            ),


            SizedBox(height: 24),

            // 🔹 Modus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.text('set2'), style: TextStyle(fontWeight: FontWeight.bold)),

                Row(
                  children: [
                    Text(
                      fields.automatik
                          ? t.text('set3')
                          : t.text('set4'),
                    ),
                    SizedBox(width: 8),

                    Switch(
                      value: fields.automatik,
                      onChanged: (val) => fields.setAutomatik(val),
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ],
            ),
            Text(t.text('set14'), style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
                title: Text("CSV"),
                value: fields.csv,
                onChanged: (val) => fields.setCSV(val!)
            ),
            CheckboxListTile(
              title: Text("PDF"),
              value: fields.pdf,
              onChanged: (val) => fields.setPDF(val!)
            ),
            SizedBox(height: 24),
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
                    await saveSettings(); // Speichert die Auswahl in SharedPreferences
                    setState(() {});
                  }
                },
              ),
            ),
            SizedBox(height: 24),
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
                    await saveSettings(); // Speichert die Auswahl in SharedPreferences
                    setState(() {});
                  }
                },
              ),
            ),
            SizedBox(height: 24),

            // 🔹 Pflichtfelder Checkboxen
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

            AppButtons.primaryText(
              text: t.text('set9'),
              onPressed: (){
                Navigator.pushNamed(context, '/update');
              },
              verticalPadding: 16,
            ),

            AppButtons.primaryText(
              text: t.text('zurueck'),
              onPressed: () => Navigator.pop(context,true),
              verticalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }
}
