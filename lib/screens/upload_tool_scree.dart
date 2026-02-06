import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../utils/translation.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadToolScreen extends StatefulWidget {
  @override
  _UploadToolScreenState createState() => _UploadToolScreenState();
}

class _UploadToolScreenState extends State<UploadToolScreen> {
  final _customerController = TextEditingController();
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();

  List<TextEditingController> pressureControllers = [];
  List<TextEditingController> torqueControllers = [];

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Kundencode laden
    /*final savedCustomer = prefs.getString('customerCode');
    if (savedCustomer != null) {
      _customerController.text = savedCustomer;
    }*/ //Standart
    final savedCustomer = prefs.getString('customerCode');
    if (savedCustomer != null && savedCustomer.startsWith('10019')) {
      _customerController.text = savedCustomer.substring(5); // nur die letzten 5 Ziffern
    }//Alki

    // Druckwerte laden
    final savedPressure = prefs.getString('saved_pressure_values');
    List<String> loaded = [];
    if (savedPressure != null) {
      loaded = List<String>.from(jsonDecode(savedPressure));
    }

    // Controller initialisieren
    pressureControllers = loaded.map((v) => TextEditingController(text: v)).toList();
    torqueControllers = loaded.map((_) => TextEditingController(text: '')).toList();

    // Immer mindestens eine leere Zeile anhängen
    pressureControllers.add(TextEditingController());
    torqueControllers.add(TextEditingController());

    setState(() {});
  }

  void _savePressureValues() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pressureList =
    pressureControllers.map((c) => c.text).where((p) => p.isNotEmpty).toList();
    prefs.setString('saved_pressure_values', jsonEncode(pressureList));
  }

  void _checkAddRow() {
    final lastIndex = pressureControllers.length - 1;
    if (pressureControllers[lastIndex].text.isNotEmpty ||
        torqueControllers[lastIndex].text.isNotEmpty) {
      setState(() {
        pressureControllers.add(TextEditingController());
        torqueControllers.add(TextEditingController());
      });
    }
  }

  Future<void> _uploadTool() async {
    final customer = _customerController.text.trim();
    final name = _nameController.text.trim();
    final serial = _serialController.text.trim();

    /*if (customer.length != 10 || name.isEmpty || serial.isEmpty) {
      final te = Provider.of<Translations>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(te.text('upl1'))),
      );
      return;
    }*///Standart
    final fullCustomerCode = '10019${_customerController.text}';
    if (fullCustomerCode.length != 10 || name.isEmpty || serial.isEmpty) {
      final te = Provider.of<Translations>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(te.text('upl1'))),
      );
      return;
    }//Alkitronik

    List<int> pressure = [];
    List<int> torque = [];

    for (int i = 0; i < pressureControllers.length; i++) {
      final pText = pressureControllers[i].text;
      final tText = torqueControllers[i].text;

      if (pText.isEmpty || tText.isEmpty) continue;

      final p = int.tryParse(pText);
      final t = int.tryParse(tText);

      if (p == null || t == null) {
        final te = Provider.of<Translations>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(te.text('upl2'))),
        );
        return;
      }

      final pressureValue =
      DRUCK_EINHEIT == 'PSI' ? (p / 14.503).round() : p;
      final torqueValue =
      DREHMOMENT_EINHEIT == 'Nm' ? t : convertTorqueToNm(t);

      pressure.add(pressureValue);
      torque.add(torqueValue);
    }

    if (pressure.isEmpty || torque.isEmpty) {
      final te = Provider.of<Translations>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(te.text('upl3'))),
      );
      return;
    }

   /* final payload = {
      'customer_code': customer,
      'tool_name': name,
      'serial_number': serial,
      'torque': jsonEncode(torque),
      'pressure': jsonEncode(pressure),
    };*///Standart
    final payload = {
      'customer_code': fullCustomerCode,
      'tool_name': name,
      'serial_number': serial,
      'torque': jsonEncode(torque),
      'pressure': jsonEncode(pressure),
    }; //Alki
    setState(() => isUploading = true);

    try {
      final res = await http.post(
        Uri.parse('https://www.stephandahlmann.com/tool_api/upload_tool.php'),
        body: payload,
      );

      if (res.body.isEmpty) throw Exception('Leere Antwort vom Server');

      final data = jsonDecode(res.body);

      if (data['status'] == 'ok') {
        final prefs = await SharedPreferences.getInstance();
        //prefs.setString('customerCode', customer);//Standart
        prefs.setString('customerCode', fullCustomerCode);//Alki
        final te = Provider.of<Translations>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(te.text('upl4'))),
        );

        _nameController.clear();
        _serialController.clear();

        // Torque löschen, Druckwerte behalten
        setState(() {
          for (var t in torqueControllers) {
            t.clear();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Upload: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _nameController.dispose();
    _serialController.dispose();
    for (var c in pressureControllers) c.dispose();
    for (var c in torqueControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final te = Provider.of<Translations>(context);

    return AppTemplate(
      hideSettingsIcon: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          /* TextField(
              controller: _customerController,
              decoration: InputDecoration(
                labelText: te.text('upl5'),
                hintText: te.text('upl6'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString(
                    'customerCode', _customerController.text.trim());
              },
            ),
            *///Standart
            TextField(
              controller: _customerController,
              decoration: InputDecoration(
                labelText: te.text('upl5'),
                hintText: 'XXXXX', // optisch zeigen, dass 10019 fix ist
                prefixText: '10019',     // **das wird automatisch vorne angezeigt**
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(5), // User tippt nur die letzten 5 Stellen
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (v) async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('customerCode', '10019$v'); // Prefix hinzufügen beim Speichern
              },
            ),//Alkitronik
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: te.text('upl7'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: _serialController,
              decoration: InputDecoration(
                labelText: te.text('upl8'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            Text(
              te.text('upl9'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pressureControllers.length,
              itemBuilder: (context, i) {
                return KeyedSubtree(
                  key: ValueKey("row_$i"),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pressureControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: te.textArgs(
                                'upl10', {'Value': DRUCK_EINHEIT}),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            _savePressureValues();
                            _checkAddRow();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: torqueControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: te.textArgs(
                                'upl11', {'Value': DREHMOMENT_EINHEIT}),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            _checkAddRow();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            AppButtons.primaryText(
              text: isUploading ? te.text('upl12') : te.text('upl13'),
              onPressed: () {
                if (!isUploading) _uploadTool();
              },
              verticalPadding: 16,
            ),
            SizedBox(height: 16),

            AppButtons.primaryText(
              text: te.text('zurueck'),
              onPressed: () => Navigator.pop(context),
              verticalPadding: 16,
            ),
          ],
        ),
      ),
    );
  }
}
