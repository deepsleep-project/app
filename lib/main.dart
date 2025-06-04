import 'package:alarm/alarm.dart';
import 'package:drp_19/home_page.dart';
import 'package:drp_19/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();

  await AppNotification.instance.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('logo'),
    ),
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
