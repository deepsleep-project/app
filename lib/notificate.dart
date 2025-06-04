

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificate {

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {

    if (_isInitialized) return;

    const AndroidInitializationSettings initializationsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initSettingsIOS = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
    const InitializationSettings initSetting = InitializationSettings(
      android: initializationsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSetting);

    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    print('note1');
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Dail Notification',
        channelDescription: 'Daily notification channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher'
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    print('note');
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  /*Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minite,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minite,
    );
    print('schedual clock set');
    await notificationsPlugin.zonedSchedule(
      id, 
      title, 
      body, 
      scheduleDate,
      const NotificationDetails(), 
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time
    );
  }
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }*/

}