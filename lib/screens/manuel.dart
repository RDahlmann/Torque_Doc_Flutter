import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    exampleController = TextEditingController();
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

              // Beispiel für Eingabefeld
              TextField(
                controller: exampleController,
                decoration: InputDecoration(
                  labelText: "Manuell",
                  hintText: "Text eingeben",
                ),
                onChanged: (value) {
                  // Hier kannst du den Wert speichern oder validieren
                  print("Eingabe: $value");
                },
              ),
              SizedBox(height: 16),

              // Weiter Button
              AppButtons.primaryText(
                text: "Weiter",
                onPressed: () {
                  // Beispiel: Navigiere zum nächsten Screen
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
                },
                verticalPadding: 16,
              ),

              // Optional: Zurück Button (Navigation nur über Button)
              AppButtons.primaryText(
                text: "Zurück",
                onPressed: () {
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
