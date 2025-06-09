import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class AppNotification {
  static final FlutterLocalNotificationsPlugin instance =
      FlutterLocalNotificationsPlugin();
  static final NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      'io.github.deepsleep',
      'io.github.deepsleep',
      channelDescription: 'io.github.deepsleep',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'io.github.deepsleep',
    ),
  );
  static int id = 0;

  static void publishFriendNotifications() {
    debugPrint("notify");
    debugPrint(id.toString());
    instance.show(id++, 'plain title', 'plain body', details);
  }

  static Future<void> publishSleepReminders(int startH, int startM) async {
    final now = DateTime.now();

    bool passed =
        now.hour > startH || (now.hour == startH && startM <= now.minute);
    final scheduleDate = DateTime(
      now.year,
      now.month,
      passed ? now.day + 1 : now.day,
      startH,
      startM,
    );

    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: scheduleDate,
      assetAudioPath: 'alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
      ),
      notificationSettings: const NotificationSettings(
        title: 'Bro it is sleep time',
        body: 'are you ready?',
        stopButton: 'I understand',
        icon: 'ic_launcher.png',
        iconColor: Color(0xff862778),
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Alarm set for $scheduleDate');
  }

  static void initializeAlarmListener() {
    Alarm.scheduled.listen((alarmSet) {
      if (alarmSet.alarms.isEmpty) {
        debugPrint("Received an alarmSet with no alarms.");
        return;
      }

      final alarmSettings = alarmSet.alarms.first;
      debugPrint("Alarm ringing: ${alarmSettings.id}");

      final nextAlarm = alarmSettings.dateTime.add(Duration(days: 1));
      final newSettings = alarmSettings.copyWith(dateTime: nextAlarm);
      Alarm.set(alarmSettings: newSettings);
      debugPrint("Next day's alarm scheduled: ${newSettings.dateTime}");
    });
  }

  static Future<void> cancelTodaySleepReminder() async {
    final alarms = await Alarm.getAlarms();
    final today = DateTime.now();

    for (var alarm in alarms) {
      if (alarm.id == 42 &&
          alarm.dateTime.year == today.year &&
          alarm.dateTime.month == today.month &&
          alarm.dateTime.day == today.day) {
        await Alarm.stop(alarm.id);
        debugPrint("Today's alarm cancelled.");
        return;
      }
    }

    debugPrint('No alarm found for today.');
  }
}
