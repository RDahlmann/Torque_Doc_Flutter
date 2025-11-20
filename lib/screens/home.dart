import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../utils/app_toast.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../providers/field_settings.dart';
import '../utils/translation.dart';
import '../globals.dart';
import 'package:torquedoc/styles/app_text_styles.dart';
import '../utils/file_exporter.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController nameController;
  late TextEditingController projectController;
  late TextEditingController toleranceController;
  late TextEditingController sPumpController;
  late TextEditingController sHoseController;
  late TextEditingController sToolController;
  late TextEditingController toolController;
  String? _projectError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    projectController = TextEditingController();
    toleranceController = TextEditingController();
    sPumpController = TextEditingController();
    sHoseController = TextEditingController();
    sToolController = TextEditingController();
    toolController = TextEditingController();

    // Daten laden
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      UserName = prefs.getString('userName') ?? "";
      Projectnumber = prefs.getString('projectNumber') ?? "";
      Toleranz = prefs.getString('toleranz') ?? "";
      Serialpump = prefs.getString('serpump') ?? "";
      Serialhose = prefs.getString('serhose') ?? "";
      Serialtool = prefs.getString('sertool') ?? "";
      Tool = prefs.getString('tool') ?? "";

      nameController.text = UserName;
      projectController.text = Projectnumber;
      toleranceController.text = Toleranz;
      sPumpController.text = Serialpump;
      sHoseController.text = Serialhose;
      sToolController.text = Serialtool;
      toolController.text = Tool;
    });
  }

  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  void dispose() {
    nameController.dispose();
    projectController.dispose();
    toleranceController.dispose();
    sPumpController.dispose();
    sHoseController.dispose();
    sToolController.dispose();
    toolController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final fields = Provider.of<FieldSettings>(context);
    final t = Provider.of<Translations>(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: AppTemplate(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 🔹 Name
              if (fields.requireName)
                TextField(
                  controller: nameController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: t.text('name'),
                    hintText: t.text('name_insert'),
                    labelStyle: AppTextStyles.body,
                    hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                  ),
                  onChanged: (value) {
                    UserName = value;
                    saveData('userName', value);
                  },
                ),
              if (fields.requireName) SizedBox(height: 16),

              // 🔹 Project Number

              TextField(
                controller: projectController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: t.text('project'),
                  hintText: t.text('project_insert'),
                  labelStyle: AppTextStyles.body,
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                  errorText: _projectError,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                onChanged: (value) {
                  String? error;
                  if (value.length > 15) error = "Maximal 15 Zeichen erlaubt";
                  if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)) error = "Nur Buchstaben & Zahlen erlaubt";

                  setState(() => _projectError = error);
                  if (error == null) {
                    Projectnumber = value;
                    saveData('projectNumber', value);
                  }},
              ),
              SizedBox(height: 16),

              // 🔹 Tolerance
              TextField(
                controller: toleranceController,
                style: AppTextStyles.body,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: t.text('tolerance'),
                  hintText: t.text('tolerance_insert'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text("%", style: AppTextStyles.body),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  labelStyle: AppTextStyles.body,
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                ),
                onChanged: (value) {
                  Toleranz = value;
                  saveData('toleranz', value);
                },
              ),
              SizedBox(height: 16),

              // 🔹 Seriennummer Pumpe
              if (fields.requireSerialPump)
                TextField(
                  controller: sPumpController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: t.text('serial_pump'),
                    hintText: t.text('serial_pump_insert'),
                    labelStyle: AppTextStyles.body,
                    hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                  ),
                  onChanged: (value) {
                    Serialpump = value;
                    saveData('serpump', value);
                  },
                ),
              if (fields.requireSerialPump) SizedBox(height: 16),

              // 🔹 Seriennummer Schlauch
              if (fields.requireSerialHose)
                TextField(
                  controller: sHoseController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: t.text('serial_hose'),
                    hintText: t.text('serial_hose_insert'),
                    labelStyle: AppTextStyles.body,
                    hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                  ),
                  onChanged: (value) {
                    Serialhose = value;
                    saveData('serhose', value);
                  },
                ),
              if (fields.requireSerialHose) SizedBox(height: 16),

              // 🔹 Seriennummer Tool
              if (fields.requireSerialTool)
                TextField(
                  controller: sToolController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: t.text('serial_tool'),
                    hintText: t.text('serial_tool_insert'),
                    labelStyle: AppTextStyles.body,
                    hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                  ),
                  onChanged: (value) {
                    Serialtool = value;
                    saveData('sertool', value);
                  },
                ),
              if (fields.requireSerialTool) SizedBox(height: 16),

              // 🔹 Tool
              TextField(
                controller: toolController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: t.text('tool'),
                  hintText: t.text('tool_insert'),
                  labelStyle: AppTextStyles.body,
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
                ),
                onChanged: (value) {
                  Tool = value;
                  saveData('tool', value);
                },
              ),
              SizedBox(height: 16),
              AppButtons.primaryText(
                text: t.text('Bluetooth_send'),
                onPressed: (){
                },
                verticalPadding: 16,
              ),



              AppButtons.primaryText(
                text: t.text('Bluetooth'),
                onPressed: (){
                  Navigator.pushNamed(context, '/bluetooth');
                },
                verticalPadding: 16,
              ),

              AppButtons.primaryText(
                text: t.text('continue'),
                onPressed: (){
                  validateAndProceed;
                  Navigator.pushNamed(context, '/choose');
                },

                verticalPadding: 16,
              ),

              AppButtons.primaryText(
                text: t.text('Auto'),
                onPressed: (){
                  Navigator.pushNamed(context, '/auto');
                },
                verticalPadding: 16,
              ),

              AppButtons.primaryText(
                text: t.text('Choose'),
                onPressed: (){
                  Navigator.pushNamed(context, '/choose');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('Kalibration'),
                onPressed: (){
                  Navigator.pushNamed(context, '/kalibration');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('Manuell'),
                onPressed: (){
                  Navigator.pushNamed(context, '/manuell');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('Hauptmenü'),
                onPressed: (){
                  Navigator.pushNamed(context, '/menu');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('Pressure'),
                onPressed: (){
                  Navigator.pushNamed(context, '/pressure');
                },
                verticalPadding: 16,
              ),
              AppButtons.primaryText(
                text: t.text('Tools'),
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

  void validateAndProceed() {
    final fields = Provider.of<FieldSettings>(context, listen: false);

    if (fields.requireName && UserName.isEmpty) {
      AppToast.warning("Bitte Name eingeben");
      return;
    }
    if (Projectnumber.isEmpty) {
      AppToast.warning("Bitte Projektnummer eingeben");
      return;
    }
    if (fields.requireSerialPump && Serialpump.isEmpty) {
      AppToast.warning("Bitte Seriennummer Pumpe eingeben");
      return;
    }
    if (fields.requireSerialTool && Serialtool.isEmpty) {
      AppToast.warning("Bitte Seriennummer Werkzeug eingeben");
      return;
    }
    if (fields.requireSerialHose && Serialhose.isEmpty) {
      AppToast.warning("Bitte Seriennummer Schlauch eingeben");
      return;
    }
    if (Tool.isEmpty) {
      AppToast.warning("Bitte Werkzeug eingeben");
      return;
    }

    AppToast.success("Alle Pflichtfelder korrekt ausgefüllt!");
  }
}
