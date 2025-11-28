import 'package:flutter/material.dart';
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

  void _handleTaskData(dynamic data) {

  }

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
    if (code != null) {
      customerCodeController.text = code;
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

  /// Importieren von Tools über API
  void _importTools() async {
    final code = customerCodeController.text.trim();
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

      debugPrint("[DEBUG] Fetched tools from API: ${apiTools.map((t) => t.toolName).toList()}");

      // Alte Tools überschreiben
      await _saveTools(apiTools);

      // Kundencode speichern
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCustomerCode', code);
      debugPrint("[DEBUG] Saved customerCode: $code");

      setState(() {
        tools = apiTools;
        selectedTool = apiTools.isNotEmpty ? apiTools.first : null;
      });
    } catch (e) {
      setState(() {
        errorMessage = t.text('tools2');
      });
      debugPrint("[DEBUG] API error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Lineare Interpolation von Druckwert anhand Drehmoment
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
              // Eingabefeld Kundencode


              // Ladeindikator
              if (isLoading)
                const Center(child: CircularProgressIndicator()),

              // Dropdown für Tools
              if (tools.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton<Tool1>(
                    value: selectedTool,
                    isExpanded: true,
                    items: tools.map((tool) {
                      final minTorque = tool.torque.isNotEmpty
                          ? tool.torque.reduce((a, b) => a < b ? a : b)
                          : 0;
                      final maxTorque = tool.torque.isNotEmpty
                          ? tool.torque.reduce((a, b) => a > b ? a : b)
                          : 0;
                      return DropdownMenuItem(
                        value: tool,
                        child: Text(
                            "${tool.toolName} (${tool.serialNumber}) | Torque: $minTorque-$maxTorque Nm"),
                      );
                    }).toList(),
                    onChanged: (tool) {
                      setState(() {
                        selectedTool = tool;
                        interpolatedPressure = null;
                      });
                    },
                  ),
                ),


              const SizedBox(height: 16),

              // Eingabefeld Drehmoment
              TextField(
                controller: torqueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.text('tools3'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Weiter Button
              AppButtons.primaryText(
                text: t.text('weiter'),
                onPressed: () {
                  if (selectedTool == null) return;

                  final inputTorque = double.tryParse(torqueController.text);
                  if (inputTorque == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(t.text('tools4'),)),
                    );
                    return;
                  }

                  final minTorque = selectedTool!.torque.isNotEmpty
                      ? selectedTool!.torque.reduce((a, b) => a < b ? a : b)
                      : 0;
                  final maxTorque = selectedTool!.torque.isNotEmpty
                      ? selectedTool!.torque.reduce((a, b) => a > b ? a : b)
                      : 0;

                  if (inputTorque < minTorque || inputTorque > maxTorque) {
                    String errorText = t.textArgs(
                        'tools5',
                        {'minTorque': minTorque.toStringAsFixed(0),
                          'maxTorque': maxTorque.toStringAsFixed(0),
                        }  // ❌ Map, nicht nur String
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              errorText)),
                    );
                    setState(() {
                      interpolatedPressure = null;
                    });
                    return;
                  }

                  final pressure =
                  interpolatePressure(selectedTool!, inputTorque);

                  if (pressure != null && (pressure < 150 || pressure > 650)) {
                    String errorText = t.textArgs(
                        'tools6',
                        {'value': pressure.toStringAsFixed(2)}  // ❌ Map, nicht nur String
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(errorText),
                    ));
                    setState(() {
                      interpolatedPressure = null;
                    });
                    return;
                  }
                  else{
                    setState(() {
                      interpolatedPressure = pressure;
                    });
                    String errorText = t.textArgs(
                        'tools7',
                        {'value': pressure?.toStringAsFixed(2)}  // ❌ Map, nicht nur String
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              errorText)),
                    );
                    final tool = selectedTool;
                    if (tool == null) return;
                    SOLLDRUCK=pressure!.toInt();
                    SOLLDRUCKBAR=SOLLDRUCK;
                    SOLLDRUCKPSI=(SOLLDRUCK*14.503).round();
                    iskalibriert=false;
                    FlutterForegroundTask.sendDataToTask({
                      'event': 'setToolData',
                      'Solltorque': inputTorque.toInt(),
                      'toolName': tool.toolName,
                      'torque': tool.torque,
                      'pressure': tool.pressure,
                      'command': '-SETP $SOLLDRUCK\$',
                    });
                    Navigator.pushNamed(context, '/kalibration');

                  }


                },
              ),


              // Zurück Button
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
                  hintText: t.text('tools9'),
                  errorText: errorMessage,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Importieren Button
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
