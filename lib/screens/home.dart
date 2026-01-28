import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt ?? 0;

      if (sdkInt < 29) {
        // Android < 10
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      // Android 10+ regelt MediaStore automatisch, keine Permission nötig
      return true;
    }
    // iOS fragt automatisch
    return true;
  }
  Future<bool> checkProjectFileExists(String projectVar) async {
    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final safeProjectVar = projectVar.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), "_");
    final fileName = "${safeProjectVar}_$dateString.pdf";

    String filePath;

    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download/TorqueDoc');
      filePath = '${directory.path}/$fileName';
    } else {
      final baseDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${baseDir.path}/TorqueDocData');
      filePath = '${dir.path}/$fileName';
    }

    return File(filePath).exists();
  }
  late final t = Provider.of<Translations>(context);

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      UserName = prefs.getString('userName') ?? "";
      Projectnumber = prefs.getString('projectNumber') ?? "";
      Toleranz = prefs.getString('toleranz') ?? "";
      Serialpump = connectedDeviceName.isNotEmpty
          ? connectedDeviceName
          : prefs.getString('serpump') ?? ""; // 🔹 BLE Name hat Priorität
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

              SizedBox(height: 16),

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


              AppButtons.primaryText(
                text: t.text('continue'),
                onPressed: (){
                  validateAndProceed();

                },

                verticalPadding: 16,
              ),



            ],
          ),
        ),
      ),
    );
  }

  Future<void> validateAndProceed() async {
    final fields = Provider.of<FieldSettings>(context, listen: false);
    final t = Provider.of<Translations>(context, listen: false); // ⚡ wichtig

    if (fields.requireName && UserName.isEmpty) {
      AppToast.warning(t.text('name_insert'));
      return;
    }
    if (Projectnumber.isEmpty) {
      AppToast.warning(t.text('project_insert'));
      return;
    }
    if (Toleranz.isEmpty) {
      AppToast.warning(t.text('tolerance_insert'));
      return;
    }
    if (Serialpump.isEmpty) {
      AppToast.warning(t.text('serial_pump_insert'));
      return;
    }
    if (fields.requireSerialTool && Serialtool.isEmpty) {
      AppToast.warning(t.text('serial_tool_insert'));
      return;
    }
    if (fields.requireSerialHose && Serialhose.isEmpty) {
      AppToast.warning(t.text('serial_hose_insert'));
      return;
    }
    if (Tool.isEmpty) {
      AppToast.warning(t.text('tool_insert'));
      return;
    }
    // 🔹 Storage Permission abfragen
    bool permissionGranted = await ensureStoragePermission();
    if (!permissionGranted) {
      AppToast.warning("Speicherzugriff benötigt!");
      return;
    }
    bool exists = await checkProjectFileExists(Projectnumber);
    if (exists) {
      AppToast.warning("Ein Protokoll für dieses Projekt existiert bereits!");
      return;
    }
    Navigator.pushNamed(context, '/choose');
  }


}
