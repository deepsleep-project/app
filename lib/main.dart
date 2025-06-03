import 'package:drp_19/home_page.dart';
import 'package:drp_19/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppNotification.instance.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('logo'),
    ),
  );

  Workmanager().initialize(
    AppNotification.callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
  Workmanager().registerPeriodicTask(
    "notification-daemon",
    "null",
    frequency: Duration(minutes: 15), // is capped at 15 min
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false);
  }
}
