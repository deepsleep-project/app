import 'package:deepsleep/storage.dart';

// Example sleep records with varied times
final List<SleepRecord> exampleRecords = [
  // Monday, May 5, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 5, 22, 45).toIso8601String(),
    end: DateTime.utc(2025, 5, 6, 6, 55).toIso8601String(),
    date: DateTime.utc(2025, 5, 5, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Tuesday, May 6, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 6, 23, 10).toIso8601String(),
    end: DateTime.utc(2025, 5, 7, 7, 5).toIso8601String(),
    date: DateTime.utc(2025, 5, 6, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, May 7, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 7, 22, 55).toIso8601String(),
    end: DateTime.utc(2025, 5, 8, 6, 45).toIso8601String(),
    date: DateTime.utc(2025, 5, 7, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, May 8, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 8, 23, 20).toIso8601String(),
    end: DateTime.utc(2025, 5, 9, 7, 10).toIso8601String(),
    date: DateTime.utc(2025, 5, 8, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Friday, May 9, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 9, 23, 5).toIso8601String(),
    end: DateTime.utc(2025, 5, 10, 7, 0).toIso8601String(),
    date: DateTime.utc(2025, 5, 9, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Saturday, May 10, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 10, 23, 30).toIso8601String(),
    end: DateTime.utc(2025, 5, 11, 8, 0).toIso8601String(),
    date: DateTime.utc(2025, 5, 10, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Sunday, May 11, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 12, 0, 45).toIso8601String(),
    end: DateTime.utc(2025, 5, 12, 7, 20).toIso8601String(),
    date: DateTime.utc(2025, 5, 11, 0, 0).toIso8601String(),
    sleepRecordState: false,
  ),
  // Tuesday, May 13, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 13, 23, 5).toIso8601String(),
    end: DateTime.utc(2025, 5, 14, 6, 55).toIso8601String(),
    date: DateTime.utc(2025, 5, 13, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, May 14, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 14, 22, 58).toIso8601String(),
    end: DateTime.utc(2025, 5, 15, 6, 50).toIso8601String(),
    date: DateTime.utc(2025, 5, 14, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, May 15, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 15, 23, 10).toIso8601String(),
    end: DateTime.utc(2025, 5, 16, 7, 2).toIso8601String(),
    date: DateTime.utc(2025, 5, 15, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Friday, May 16, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 16, 23, 20).toIso8601String(),
    end: DateTime.utc(2025, 5, 17, 7, 15).toIso8601String(),
    date: DateTime.utc(2025, 5, 16, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Saturday, May 17, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 17, 23, 35).toIso8601String(),
    end: DateTime.utc(2025, 5, 18, 8, 5).toIso8601String(),
    date: DateTime.utc(2025, 5, 17, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Sunday, May 18, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 19, 2, 0).toIso8601String(),
    end: DateTime.utc(2025, 5, 19, 7, 30).toIso8601String(),
    date: DateTime.utc(2025, 5, 18, 0, 0).toIso8601String(),
    sleepRecordState: false,
  ),
  // Monday, May 19, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 19, 22, 45).toIso8601String(),
    end: DateTime.utc(2025, 5, 20, 6, 55).toIso8601String(),
    date: DateTime.utc(2025, 5, 19, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Tuesday, May 20, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 20, 23, 10).toIso8601String(),
    end: DateTime.utc(2025, 5, 21, 7, 5).toIso8601String(),
    date: DateTime.utc(2025, 5, 20, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, May 21, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 21, 22, 55).toIso8601String(),
    end: DateTime.utc(2025, 5, 22, 6, 45).toIso8601String(),
    date: DateTime.utc(2025, 5, 21, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, May 22, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 22, 23, 20).toIso8601String(),
    end: DateTime.utc(2025, 5, 23, 7, 10).toIso8601String(),
    date: DateTime.utc(2025, 5, 22, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Friday, May 23, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 23, 23, 5).toIso8601String(),
    end: DateTime.utc(2025, 5, 24, 7, 0).toIso8601String(),
    date: DateTime.utc(2025, 5, 23, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Saturday, May 24, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 25, 0, 30).toIso8601String(),
    end: DateTime.utc(2025, 5, 25, 6, 30).toIso8601String(),
    date: DateTime.utc(2025, 5, 24, 0, 0).toIso8601String(),
    sleepRecordState: false,
  ),
  // Sunday, May 25, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 26, 0, 0).toIso8601String(),
    end: DateTime.utc(2025, 5, 26, 7, 20).toIso8601String(),
    date: DateTime.utc(2025, 5, 25, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Monday, May 26, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 27, 2, 10).toIso8601String(),
    end: DateTime.utc(2025, 5, 27, 8, 20).toIso8601String(),
    date: DateTime.utc(2025, 5, 26, 0, 0).toIso8601String(),
    sleepRecordState: false,
  ),
  // Tuesday, May 27, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 27, 23, 5).toIso8601String(),
    end: DateTime.utc(2025, 5, 28, 6, 55).toIso8601String(),
    date: DateTime.utc(2025, 5, 27, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, May 28, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 28, 22, 58).toIso8601String(),
    end: DateTime.utc(2025, 5, 29, 6, 50).toIso8601String(),
    date: DateTime.utc(2025, 5, 28, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, May 29, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 29, 23, 10).toIso8601String(),
    end: DateTime.utc(2025, 5, 30, 7, 2).toIso8601String(),
    date: DateTime.utc(2025, 5, 29, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Friday, May 30, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 30, 23, 20).toIso8601String(),
    end: DateTime.utc(2025, 5, 31, 7, 15).toIso8601String(),
    date: DateTime.utc(2025, 5, 30, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Saturday, May 31, 2025
  SleepRecord(
    start: DateTime.utc(2025, 5, 31, 23, 35).toIso8601String(),
    end: DateTime.utc(2025, 6, 1, 8, 5).toIso8601String(),
    date: DateTime.utc(2025, 5, 31, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Sunday, June 1, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 1, 22, 30).toIso8601String(),
    end: DateTime.utc(2025, 6, 2, 7, 30).toIso8601String(),
    date: DateTime.utc(2025, 6, 1, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Monday, June 2, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 2, 23, 2).toIso8601String(),
    end: DateTime.utc(2025, 6, 3, 7, 0).toIso8601String(),
    date: DateTime.utc(2025, 6, 2, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Tuesday, June 3, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 3, 22, 52).toIso8601String(),
    end: DateTime.utc(2025, 6, 4, 7, 20).toIso8601String(),
    date: DateTime.utc(2025, 6, 3, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, June 4, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 5, 1, 15).toIso8601String(),
    end: DateTime.utc(2025, 6, 5, 7, 30).toIso8601String(),
    date: DateTime.utc(2025, 6, 4, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, June 5, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 5, 21, 27).toIso8601String(),
    end: DateTime.utc(2025, 6, 6, 7, 18).toIso8601String(),
    date: DateTime.utc(2025, 6, 5, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Friday, June 6, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 6, 22, 45).toIso8601String(),
    end: DateTime.utc(2025, 6, 7, 7, 54).toIso8601String(),
    date: DateTime.utc(2025, 6, 6, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Saturday, June 7, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 7, 23, 9).toIso8601String(),
    end: DateTime.utc(2025, 6, 8, 8, 12).toIso8601String(),
    date: DateTime.utc(2025, 6, 7, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Sunday, June 8, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 9, 1, 27).toIso8601String(),
    end: DateTime.utc(2025, 6, 9, 7, 36).toIso8601String(),
    date: DateTime.utc(2025, 6, 8, 0, 0).toIso8601String(),
    sleepRecordState: false,
  ),
  // Monday, June 9, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 9, 21, 58).toIso8601String(),
    end: DateTime.utc(2025, 6, 10, 6, 43).toIso8601String(),
    date: DateTime.utc(2025, 6, 9, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Tuesday, June 10, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 10, 22, 50).toIso8601String(),
    end: DateTime.utc(2025, 6, 11, 7, 5).toIso8601String(),
    date: DateTime.utc(2025, 6, 10, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Wednesday, June 11, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 11, 23, 15).toIso8601String(),
    end: DateTime.utc(2025, 6, 12, 7, 10).toIso8601String(),
    date: DateTime.utc(2025, 6, 11, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
  // Thursday, June 12, 2025
  SleepRecord(
    start: DateTime.utc(2025, 6, 12, 22, 34).toIso8601String(),
    end: DateTime.utc(2025, 6, 13, 7, 00).toIso8601String(),
    date: DateTime.utc(2025, 6, 12, 0, 0).toIso8601String(),
    sleepRecordState: true,
  ),
];
