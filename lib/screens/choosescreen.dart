import 'package:flutter/material.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Auswahlscreen extends StatefulWidget {

  @override
  _Auswahlscreenstate createState() => _Auswahlscreenstate();
}

class _Auswahlscreenstate  extends State<Auswahlscreen> {
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

              SizedBox(height: 16),

              // Weiter Button
              AppButtons.primaryText(
                text: "Weiter mit Druckeingabe",
                onPressed: (){
                  Navigator.pushNamed(context, '/pressure');
                },
                verticalPadding: 16,
              ),

              // Optional: Zurück Button (Navigation nur über Button)
              AppButtons.primaryText(
                text: "Weiter mit Werkzeugauswahl",
                onPressed: (){
                  Navigator.pushNamed(context, '/tools');
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
