import 'package:alarm/alarm.dart';
import 'package:deepsleep/home_page.dart';
import 'package:deepsleep/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  AppNotification.initializeAlarmListener();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('logo'),
    iOS: DarwinInitializationSettings(),
  );
  await AppNotification.instance.initialize(initializationSettings);

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
