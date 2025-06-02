import 'dart:async';
import 'package:localstorage/localstorage.dart';

class SleepRecord {
  final String start;
  final String end;
  final String date;
  final bool sleepRecordState;

  SleepRecord({required this.start, required this.end, required this.date, required this.sleepRecordState});

  Map<String, dynamic> toMap() {
    return {'start': start, 'end': end, 'date': date, 'sleepRecordState': sleepRecordState};
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(start: map['start'], end: map['end'],  date: map['date'], sleepRecordState: map['sleepRecordState']);
  }
}

class SleepStorage {
  static final LocalStorage _storage = LocalStorage('sleep_data');

  static Future<bool> loadIsSleeping() async {
    await _storage.ready;
    return _storage.getItem('isSleeping') == true;
  }

  static Future<void> saveIsSleeping(bool value) async {
    await _storage.ready;
    await _storage.setItem('isSleeping', value);
  }

  static Future<int> loadCurrency() async {
    await _storage.ready;
    return _storage.getItem('currency') ?? 0;
  }

  static Future<void> saveCurrency(int value) async {
    await _storage.ready;
    await _storage.setItem('currency', value);
  }

  static Future<String> loadTargetSleepTime() async {
    await _storage.ready;
    return _storage.getItem('TargetSleepTime') ?? "2025-01-01T23:00:00.000000";
  }

  static Future<void> saveTargetSleepTime(String value) async {
    await _storage.ready;
    await _storage.setItem('TargetSleepTime', value);
  }
    static Future<String> loadTargetWakeUpTime() async {
    await _storage.ready;
    return _storage.getItem('TargetWakeUpTime') ?? "2025-01-01T07:00:00.000000";
  }

  static Future<void> saveTargetWakeUpTime(String value) async {
    await _storage.ready;
    await _storage.setItem('TargetWakeUpTime', value);
  }

  static Future<String?> loadStartTime() async {
    await _storage.ready;
    return _storage.getItem('startTime')?.toString();
  }

  static Future<void> saveStartTime(String time) async {
    await _storage.ready;
    await _storage.setItem('startTime', time);
  }

  static Future<void> saveUsername(String username) async {
    await _storage.ready;
    await _storage.setItem('username', username);
  }

  static Future<String?> loadUsername() async {
    await _storage.ready;
    return _storage.getItem('username')?.toString();
  }

  static Future<void> saveUserId(String id) async {
    await _storage.ready;
    return _storage.setItem('userId', id);
  }

  static Future<String?> loadUserId() async {
    await _storage.ready;
    return _storage.getItem('userId') as String?;
  }

  static Future<List<SleepRecord>> loadRecords() async {
    await _storage.ready;
    final list = _storage.getItem('records');
    if (list is List) {
      return list
          .map((item) => SleepRecord.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  static Future<void> saveRecords(List<SleepRecord> records) async {
    await _storage.ready;
    final data = records.map((r) => r.toMap()).toList();
    await _storage.setItem('records', data);
  }
}
