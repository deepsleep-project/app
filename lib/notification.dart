import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

abstract class AppNotification {
  static final FlutterLocalNotificationsPlugin instance =
      FlutterLocalNotificationsPlugin();
  static final NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      'com.example.drp_19',
      'com.example.drp_19',
      channelDescription: 'com.example.drp_19',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'com.example.drp_19',
    ),
  );
  static int id = 0;

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      if (task == "notification-daemon") {
        debugPrint("daemon");
        for (
          Duration d = Duration.zero;
          d < Duration(minutes: 15);
          d += Duration(seconds: 2)
        ) {
          debugPrint(d.toString());
          Workmanager().registerOneOffTask(
            d.toString(),
            "notifyOnce",
            initialDelay: d,
          );
        }
      } else if (task == 'notifyOnce') {
        debugPrint("once");
        publishFriendNotifications();
        publishSleepReminders();
      }

      return Future.value(true);
    });
  }

  static void publishFriendNotifications() {
    debugPrint("notify");
    debugPrint(id.toString());
    instance.show(id++, 'plain title', 'plain body', details);
  }

  static void publishSleepReminders() {}
}
