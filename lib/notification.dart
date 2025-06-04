import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static void publishFriendNotifications() {
    debugPrint("notify");
    debugPrint(id.toString());
    instance.show(id++, 'plain title', 'plain body', details);
  }

  static Future<void> publishSleepReminders(int startH, int startM) async {
    final now = DateTime.now();

    var scheduleDate = DateTime(
      now.year,
      now.month,
      now.day,
      startH,
      startM
    );
    final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: scheduleDate,
    assetAudioPath: 'assets/alarm.mp3',
    loopAudio: true,
    vibrate: true,
    warningNotificationOnKill: Platform.isIOS,
    androidFullScreenIntent: true,
    volumeSettings: VolumeSettings.fade(
      volume: 0.8,
      fadeDuration: Duration(seconds: 5),
      volumeEnforced: true,
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
  print('set clock on $startH:$startM');
  }
}
