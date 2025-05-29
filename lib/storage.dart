import 'dart:async';
import 'package:localstorage/localstorage.dart';

class SleepRecord {
  final String start;
  final String end;

  SleepRecord({required this.start, required this.end});

  Map<String, dynamic> toMap() {
    return {'start': start, 'end': end};
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(start: map['start'], end: map['end']);
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

  static Future<void> saveUserId(int id) async {
    await _storage.ready;
    return _storage.setItem('userId', id);
  }

  static Future<int?> loadUserId() async {
    await _storage.ready;
    return _storage.getItem('userId') as int?;
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
