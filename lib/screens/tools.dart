import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torquedoc/globals.dart';
import '../utils/translation.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/api_service.dart';
import '../utils/tool_model.dart';
import 'dart:convert';

class Toolsscreen extends StatefulWidget {
  @override
  _Toolsscreenstate createState() => _Toolsscreenstate();
}

class _Toolsscreenstate extends State<Toolsscreen> {
  late TextEditingController customerCodeController;
  late TextEditingController torqueController;
  List<Tool1> tools = [];
  Tool1? selectedTool;
  bool isLoading = false;
  String? errorMessage;
  double? interpolatedPressure;
  late final t = Provider.of<Translations>(context);

  @override
  void initState() {
    super.initState();
    customerCodeController = TextEditingController();
    torqueController = TextEditingController();
    _loadSavedData();
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
    customerCodeController.dispose();
    torqueController.dispose();
    super.dispose();
  }

  /// Kundencode und gespeicherte Tools laden
  void _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Kundencode laden
    final code = prefs.getString('lastCustomerCode');
    debugPrint("[DEBUG] Loaded customerCode: $code");
   /* if (code != null) {
      customerCodeController.text = code;
    }*/ //Standart
    if (code != null && code.startsWith('10019')) {
      // Nur die letzten 5 Stellen ins TextField schreiben
      customerCodeController.text = code.substring(5);
    }


    // Tools laden
    final jsonStr = prefs.getString('tools');
    if (jsonStr != null) {
      final data = jsonDecode(jsonStr) as List;
      final savedTools = data.map((e) => Tool1.fromJson(e)).toList();
      debugPrint("[DEBUG] Loaded tools: ${savedTools.map((t) => t.toolName).toList()}");
      if (savedTools.isNotEmpty) {
        setState(() {
          tools = savedTools;
          selectedTool = tools.first;
        });
      }
    } else {
      debugPrint("[DEBUG] No tools found in storage");
    }
  }

  /// Tools speichern
  Future<void> _saveTools(List<Tool1> tools) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tools.map((e) => e.toJson()).toList());
    await prefs.setString('tools', jsonStr);
    debugPrint("[DEBUG] Saved tools: ${tools.map((t) => t.toolName).toList()}");
  }

  /// Tools importieren
  void _importTools() async {
    //final code = customerCodeController.text.trim(); //Standart
    final code = '10019${customerCodeController.text.trim()}'; //Alki

    if (code.length != 10) {
      setState(() {
        errorMessage = t.text('tools1');
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiTools = await ApiService.getTools(code);

      // Alte Tools überschreiben
      await _saveTools(apiTools);

      // Kundencode speichern
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCustomerCode', code);

      setState(() {
        tools = apiTools;
        selectedTool = apiTools.isNotEmpty ? apiTools.first : null;
      });
    } catch (e) {
      setState(() {
        errorMessage = t.text('tools2');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Lineare Interpolation
  double? interpolatePressure(Tool1 tool, double inputTorque) {
    if (tool.torque.isEmpty || tool.pressure.isEmpty) return null;
    List<double> torqueList = tool.torque.map((e) => e.toDouble()).toList();
    List<double> pressureList = tool.pressure.map((e) => e.toDouble()).toList();

    if (torqueList.length != pressureList.length) return null;

    if (inputTorque <= torqueList.first) return pressureList.first;
    if (inputTorque >= torqueList.last) return pressureList.last;

    for (int i = 0; i < torqueList.length - 1; i++) {
      if (inputTorque >= torqueList[i] && inputTorque <= torqueList[i + 1]) {
        double x0 = torqueList[i];
        double x1 = torqueList[i + 1];
        double y0 = pressureList[i];
        double y1 = pressureList[i + 1];
        return y0 + (inputTorque - x0) * (y1 - y0) / (x1 - x0);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AppTemplate(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) const Center(child: CircularProgressIndicator()),

              // TOOL AUSWAHL
              if (tools.isNotEmpty)
                DropdownButtonFormField<Tool1>(
                  value: selectedTool,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                  items: tools.map((tool) {
                    final minTorque = tool.torque.reduce((a, b) => a < b ? a : b);
                    final maxTorque = tool.torque.reduce((a, b) => a > b ? a : b);

                    return DropdownMenuItem<Tool1>(
                      value: tool,
                      child: Text(
                        "${tool.toolName} (${tool.serialNumber})\n"
                            "Torque: "
                            "${convertNmToSelected(minTorque).toStringAsFixed(0)} - "
                            "${convertNmToSelected(maxTorque).toStringAsFixed(0)} $DREHMOMENT_EINHEIT",
                        softWrap: true,
                      ),
                    );
                  }).toList(),
                  onChanged: (tool) {
                    setState(() {
                      selectedTool = tool;
                      interpolatedPressure = null;
                    });
                  },
                ),

              const SizedBox(height: 16),

              // TORQUE EINGABE
              TextField(
                controller: torqueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.text('tools3') + " ($DREHMOMENT_EINHEIT)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // WEITER BUTTON
              AppButtons.primaryText(
                text: t.text('weiter'),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (selectedTool == null) return;

                  final rawInput = int.tryParse(torqueController.text);

                  if (rawInput == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.text('tools4'))),
                    );
                    return;
                  }

// Umrechnung auf Nm
                  final inputTorque = convertTorqueToNm(rawInput);

                  final minTorque = selectedTool!.torque.reduce((a, b) => a < b ? a : b);
                  final maxTorque = selectedTool!.torque.reduce((a, b) => a > b ? a : b);

                  // Nutzer-Bereichsprüfung in ausgewählter Einheit
                  if (rawInput < convertNmToSelected(minTorque) ||
                      rawInput > convertNmToSelected(maxTorque)) {
                    String errorText = t.textArgs(
                      'tools5',
                      {
                        'minTorque': convertNmToSelected(minTorque).toStringAsFixed(0),
                        'maxTorque': convertNmToSelected(maxTorque).toStringAsFixed(0),
                      },
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorText)),
                    );
                    return;
                  }

                  final pressure = interpolatePressure(selectedTool!, inputTorque.toDouble());

                  if (pressure != null && (pressure < 150 || pressure > 650)) {
                    String errorText = t.textArgs(
                      'tools6',
                      {'value': pressure.toStringAsFixed(2)},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorText)),
                    );
                    return;
                  }

                  setState(() => interpolatedPressure = pressure);

                  String success = t.textArgs(
                    'tools7',
                    {'value': pressure?.toStringAsFixed(2)},
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success)),
                  );

                  SOLLDRUCK = pressure!.toInt();
                  SOLLDRUCKBAR = SOLLDRUCK;
                  SOLLDRUCKPSI = (SOLLDRUCK * 14.503).round();
                  iskalibriert = false;

                  final tool = selectedTool!;
                  FlutterForegroundTask.sendDataToTask({
                    'event': 'setToolData',
                    'Solltorque': inputTorque.toInt(),
                    'toolName': tool.toolName,
                    'torque': tool.torque,
                    'pressure': tool.pressure,
                    'command': '-SETP $SOLLDRUCK\$',
                  });
                  istorque=true;
                  TOOLNAME=tool.toolName;
                  SOLLTORQUE=inputTorque.toInt();
                  TORQUELIST=tool.torque;
                  PRESSURELIST=tool.pressure;
                  Navigator.pushNamed(context, '/kalibration');
                },
              ),

              AppButtons.primaryText(
                text: t.text('zurueck'),
                onPressed: () => Navigator.pop(context),
                verticalPadding: 16,
              ),

              const SizedBox(height: 40),

              TextField(
                controller: customerCodeController,
                decoration: InputDecoration(
                  labelText: t.text('tools8'),
                  hintText: 'XXXXX', // zeigt optisch, dass 10019 fix ist
                  prefixText: '10019', // immer vorne angezeigt
                  errorText: errorMessage,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5), // nur die letzten 5 Stellen
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (v) async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('lastCustomerCode', '10019$v'); // Prefix beim Speichern
                },
              ),//Alki
              /*TextField(
                controller: customerCodeController,
                decoration: InputDecoration(
                  labelText: t.text('tools8'),
                  hintText: t.text('tools9'),
                  errorText: errorMessage,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),*/ //Standart

              const SizedBox(height: 16),

              AppButtons.primaryText(
                text: t.text('tools10'),
                onPressed: _importTools,
                verticalPadding: 16,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
