import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../utils/ble_foreground_task.dart';
import '../screens/bluetooth_screen.dart';
import '../utils/translation.dart';

class AppTemplate extends StatefulWidget {
  final Widget child;
  final bool hideSettingsIcon;

  const AppTemplate({
    required this.child,
    this.hideSettingsIcon = false,
    super.key,
  });

  @override
  State<AppTemplate> createState() => _AppTemplateState();
}

class _AppTemplateState extends State<AppTemplate> {
  StreamSubscription<dynamic>? _taskDataSubscription;
  bool isConnected = false;
  late final t = Provider.of<Translations>(context);
  @override
  void initState() {
    super.initState();

    // Kommunikation mit dem Foreground Task Port initialisieren
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
  }

  void _handleTaskData(dynamic data) {
    if (data['event'] == 'stateconnected' && !isConnected) {
      setState(() => isConnected = true);
    } else if (data['event'] == 'statedisconnected' && isConnected) {
      setState(() => isConnected = false);
    }
  }

  @override
  void dispose() {
    _taskDataSubscription?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenWidth * 0.06;
    final iconSize = screenWidth * 0.07;
    final statusFontSize = screenWidth * 0.035;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 4),
              child: Row(
                children: [
                  //Image.asset('assets/logosd.jpg', height: logoHeight),//Standart
                  Image.asset('assets/logoalki.jpg', height: logoHeight),//Alkitronik
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          await FlutterForegroundTask.stopService();
                          startBleTask();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BluetoothScreen(isInitialScreen: false),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: statusFontSize * 1.4,
                              color: isConnected ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              isConnected ? t.text('temp1') : t.text('temp2'),
                              style: TextStyle(fontSize: statusFontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!widget.hideSettingsIcon)
                    IconButton(
                      icon: Icon(Icons.settings, size: iconSize),
                      onPressed: () async {
                        // hier warten wir auf Rückgabe aus Settings
                        final result = await Navigator.pushNamed(context, '/settings');
                        if (result == true) {
                          setState(() {
                            // AppTemplate rebuildet das Widget.child
                            // dadurch sieht der darunterliegende Screen die geänderten Werte
                          });
                        }
                      },
                    )
                  else
                    SizedBox(width: iconSize + 16),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: widget.child,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // LEFT: powered by + Logo
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const textStyle = TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      );

                      final textPainter = TextPainter(
                        text: const TextSpan(text: 'powered by', style: textStyle),
                        textDirection: TextDirection.ltr,
                      )..layout();

                      final textWidth = textPainter.width;
                      final logoHeight = textWidth * (269 / 1726);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('powered by', style: textStyle),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: textWidth,
                            height: logoHeight,
                            child: Image.asset(
                              'assets/logosd.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // RIGHT: Mail Icon
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://www.alkitronic.com/en/contact/',
                      );
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: const Icon(
                      Icons.email,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
