import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:torquedoc/utils/file_exporter.dart';

import 'globals.dart';
import 'utils/translation.dart';
import 'styles/app_colors.dart';
import 'styles/app_text_styles.dart';

import 'screens/home.dart';
import 'screens/settings.dart';
import 'screens/automatik.dart';
import 'screens/choosescreen.dart';
import 'screens/kalibration.dart';
import 'screens/manuel.dart';
import 'screens/menu.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/pressureinput.dart';
import 'screens/tools.dart';
import 'screens/upload_tool_scree.dart';
import 'providers/field_settings.dart';
import 'utils/ble_foreground_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("[MAIN] Widgets binding initialisiert");

  await loadSettings();
  debugPrint("[MAIN] Einstellungen geladen");
  debugPrint("[MAIN] Logo geladen");
  // Alte ForegroundService stoppen, falls aktiv
  if (await FlutterForegroundTask.isRunningService) {
    await FlutterForegroundTask.stopService();
    debugPrint("[MAIN] Alter ForegroundService gestoppt");
  }

  // ForegroundTask initialisieren
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'ble_channel',
      channelName: 'BLE Service',
      channelDescription: 'BLE Foreground Service',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(500),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  debugPrint("[MAIN] ForegroundTask.init ausgeführt");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => Translations(initialLanguage: currentLanguage)),
        ChangeNotifierProvider(create: (_) => FieldSettings()),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void startBleTask() {
  FlutterForegroundTask.setTaskHandler(BleForegroundTask());
  debugPrint("[MAIN] startBleTask() aufgerufen");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      // Stoppe BLE-Service beim Beenden der App
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
        debugPrint(
            "[MAIN] Foreground Service gestoppt beim Beenden der App");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TorqueDoc',
      debugShowCheckedModeBanner: false,
      initialRoute: '/bluetooth',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      routes: {
        '/home': (_) => HomeScreen(),
        '/auto': (_) => Autoscreen(),
        '/choose': (_) => Auswahlscreen(),
        '/kalibration': (_) => Kalibrierscreen(),
        '/manuell': (_) => Manuelscreen(),
        '/menu': (_) => Menuscreen(),
        '/pressure': (_) => pressurescreen(),
        '/settings': (_) => Settingsscreen(),
        '/tools': (_) => Toolsscreen(),
        '/update':(_)=>UploadToolScreen(),
        '/bluetooth': (_) => const BluetoothScreen(isInitialScreen: true),
      },
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Barlow',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}