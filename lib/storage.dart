import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SleepRecord {
  final String start;
  final String end;
  final String date;
  final bool sleepRecordState;

  SleepRecord({
    required this.start,
    required this.end,
    required this.date,
    required this.sleepRecordState,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
      'date': date,
      'sleepRecordState': sleepRecordState,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      start: map['start'],
      end: map['end'],
      date: map['date'],
      sleepRecordState: map['sleepRecordState'] ?? false,
    );
  }
}

class SleepStorage {
  static Future<SharedPreferences> get pref async =>
      await SharedPreferences.getInstance();

  static Future<bool> loadIsSleeping() async {
    return (await pref).getBool('isSleeping') ?? false;
  }

  static Future<void> saveIsSleeping(bool value) async {
    await (await pref).setBool('isSleeping', value);
  }

  static Future<int> loadCurrency() async {
    return (await pref).getInt('currency') ?? 0;
  }

  static Future<void> saveCurrency(int value) async {
    await (await pref).setInt('currency', value);
  }

  static Future<int> loadStreak() async {
    return (await pref).getInt('streak') ?? 0;
  }

  static Future<void> saveStreak(int value) async {
    await (await pref).setInt('streak', value);
  }

  static Future<String> loadTargetSleepTime() async {
    return (await pref).getString('TargetSleepTime') ??
        "2025-01-01T23:00:00.000000";
  }

  static Future<void> saveTargetSleepTime(String value) async {
    await (await pref).setString('TargetSleepTime', value);
  }

  static Future<String> loadTargetWakeUpTime() async {
    return (await pref).getString('TargetWakeUpTime') ??
        "2025-01-01T07:00:00.000000";
  }

  static Future<void> saveTargetWakeUpTime(String value) async {
    await (await pref).setString('TargetWakeUpTime', value);
  }

  static Future<String?> loadStartTime() async {
    return (await pref).getString('startTime')?.toString();
  }

  static Future<void> saveStartTime(String time) async {
    await (await pref).setString('startTime', time);
  }

  static Future<void> saveUsername(String username) async {
    await (await pref).setString('username', username);
  }

  static Future<String?> loadUsername() async {
    return (await pref).getString('username')?.toString();
  }

  static Future<void> saveUserId(String id) async {
    (await pref).setString('userId', id);
  }

  static Future<String> loadUserId() async {
    return (await pref).getString('userId') ?? '';
  }

  static Future<void> saveShopItemStates(List<int> states) async {
    final stringList = states.map((b) => b.toString()).toList();
    await (await pref).setStringList('shop_item_states', stringList);
  }

  static Future<List<int>> loadShopItemStates() async {
    final stringList = (await pref).getStringList('shop_item_states');
    return stringList == null
        ? []
        : stringList.map((s) => int.parse(s)).toList();
  }

  static Future<List<SleepRecord>> loadRecords() async {
    final list = (await pref).getStringList('records');
    return list == null
        ? []
        : list
              .map(
                (item) => SleepRecord.fromMap(
                  Map<String, dynamic>.from(jsonDecode(item)),
                ),
              )
              .toList();
  }

  static Future<void> saveRecords(List<SleepRecord> records) async {
    final data = records.map((r) => jsonEncode(r.toMap())).toList();
    await (await pref).setStringList('records', data);
  }
}
