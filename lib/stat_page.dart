import 'package:deepsleep/storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatPage extends StatelessWidget {
  // Example sleep records with varied times
  // final List<SleepRecord> sleepRecords = [
  //   // Monday, June 2, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 2, 23, 02).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 3, 7, 00).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 2, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Tuesday, June 3, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 3, 22, 52).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 4, 7, 20).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 3, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Wednesday, June 4, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 5, 1, 15).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 5, 7, 30).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 4, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Thursday, June 5, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 5, 21, 27).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 6, 7, 18).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 5, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Friday, June 6, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 6, 22, 45).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 7, 7, 54).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 6, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Saturday, June 7, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 7, 23, 09).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 8, 8, 12).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 7, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  //   // Sunday, June 8, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 9, 1, 27).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 9, 7, 36).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 8, 0, 0).toIso8601String(),
  //     sleepRecordState: false,
  //   ),
  //   // Monday, June 9, 2025
  //   SleepRecord(
  //     start: DateTime.utc(2025, 6, 9, 21, 58).toIso8601String(),
  //     end: DateTime.utc(2025, 6, 10, 6, 43).toIso8601String(),
  //     date: DateTime.utc(2025, 6, 9, 0, 0).toIso8601String(),
  //     sleepRecordState: true,
  //   ),
  // ];

  final List<SleepRecord> sleepRecords;
  final DateTime now = DateTime.now();
  static const List<Color> gradientColors = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];

  StatPage({super.key, required this.sleepRecords});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, screenHeight * 0.08),
          child: Column(
            children: [
              Text(
                'Your sleep performance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              DayWeekStat(sleepRecords: sleepRecords),
              SizedBox(height: 10),

              AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    left: 20,
                    top: 20,
                    bottom: 20,
                  ),
                  child: SleepChart(sleepRecords: sleepRecords),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DayWeekStat extends StatelessWidget {
  final List<SleepRecord> sleepRecords;

  const DayWeekStat({super.key, required this.sleepRecords});

  @override
  Widget build(BuildContext context) {
    final lastNightRecord = sleepRecords.isNotEmpty
        ? sleepRecords.reduce(
            (a, b) => DateTime.parse(a.start).isAfter(DateTime.parse(b.start))
                ? a
                : b,
          )
        : null;

    String formatBedTime(DateTime? dateTime) {
      if (dateTime == null) return '--:--';
      int hour = dateTime.hour;
      int minute = dateTime.minute;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    String formatDuration(double hours) {
      int h = hours.floor();
      int m = ((hours - h) * 60).round();
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }

    // Get last night's bed time and duration
    DateTime? lastNightBedTime = lastNightRecord != null
        ? DateTime.parse(lastNightRecord.start)
        : null;
    double? lastNightDuration;
    if (lastNightRecord != null) {
      final start = DateTime.parse(lastNightRecord.start);
      final end = DateTime.parse(lastNightRecord.end);
      lastNightDuration = end.difference(start).inMinutes / 60.0;
      if (lastNightDuration < 0) lastNightDuration = 0;
    }

    // Get last 7 days' records (sorted, most recent first)
    List<SleepRecord> last7Records =
        sleepRecords
            .where((r) => DateTime.parse(r.start).isBefore(DateTime.now()))
            .toList()
          ..sort(
            (a, b) =>
                DateTime.parse(b.start).compareTo(DateTime.parse(a.start)),
          );
    List<SleepRecord> last7 = last7Records.take(7).toList();

    // Bed times for last 7 days
    List<DateTime> last7BedTimes = last7
        .map((r) => DateTime.parse(r.start))
        .toList();

    // Durations for last 7 days
    List<double> last7Durations = last7.map((r) {
      final start = DateTime.parse(r.start);
      final end = DateTime.parse(r.end);
      double d = end.difference(start).inMinutes / 60.0;
      return d < 0 ? 0.0 : d;
    }).toList();

    // Calculate average bed time
    DateTime? avgBedTime;
    if (last7BedTimes.isNotEmpty) {
      int totalMinutes = last7BedTimes.fold(0, (sum, dt) {
        int hour = dt.hour;
        if (hour < 12) hour += 24;
        return sum + hour * 60 + dt.minute;
      });
      int avgMinutes = (totalMinutes / last7BedTimes.length).round();
      int avgHour = avgMinutes ~/ 60;
      int avgMinute = avgMinutes % 60;
      if (avgHour >= 24) avgHour -= 24;
      avgBedTime = DateTime(0, 1, 1, avgHour, avgMinute);
    }

    // Calculate average duration
    double avgDuration = last7Durations.isNotEmpty
        ? last7Durations.reduce((a, b) => a + b) / last7Durations.length
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Last Night',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatBedTime(lastNightBedTime),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    lastNightDuration != null
                        ? formatDuration(lastNightDuration)
                        : '--h --m',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '7-Day Avg',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatBedTime(avgBedTime),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    last7Durations.isNotEmpty
                        ? formatDuration(avgDuration)
                        : '--h --m',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SleepChart extends StatelessWidget {
  final List<SleepRecord> sleepRecords;

  static const List<Color> gradientColorHealthy = [
    Color.fromARGB(255, 6, 181, 163),
    Color(0xff02d39a),
  ];

  static const List<Color> gradientColorUnHealthy = [
    Color.fromARGB(255, 255, 91, 79),
    Color(0xfff7971e),
  ];

  const SleepChart({super.key, required this.sleepRecords});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final now = DateTime.now().toUtc();
    final todayDate = DateTime.utc(now.year, now.month, now.day);
    final showToday = now.hour >= 12;

    // Create a 7-day range
    final days = List.generate(
      7,
      (i) => todayDate.subtract(Duration(days: 6 - i + (showToday ? 0 : 1))),
    );

    // Build a map from date string to record
    final recordMap = {
      for (var record in sleepRecords) DateTime.parse(record.date): record,
    };

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final record = recordMap[day];

      BarChartRodData? rod;

      if (record != null) {
        final start = DateTime.parse(record.start);
        final end = DateTime.parse(record.end);

        final base = DateTime.utc(day.year, day.month, day.day, 20); // 8:00 PM
        final startDiff = start.difference(base).inMinutes / 60;
        final endDiff = end.difference(base).inMinutes / 60;

        rod = BarChartRodData(
          fromY: startDiff,
          toY: endDiff,
          width: screenHeight * 0.03,
          gradient: LinearGradient(
            colors: record.sleepRecordState
                ? gradientColorHealthy
                : gradientColorUnHealthy,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(5),
        );
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: rod != null
              ? [rod]
              : [
                  BarChartRodData(fromY: 0, toY: 0, width: screenHeight * 0.03),
                ], // add empty list if no record
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        barTouchData: BarTouchData(enabled: false),
        maxY: 16,
        minY: 0,

        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: 0, color: Colors.grey, strokeWidth: 1),
            HorizontalLine(y: 16, color: Colors.grey, strokeWidth: 1),
          ],
        ),

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,

              getTitlesWidget: (double val, _) {
                if (val.toInt() >= 0 && val.toInt() < days.length) {
                  final weekday = DateFormat.E().format(days[val.toInt()]);
                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        weekday,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double val, _) {
                final time = DateTime.utc(
                  0,
                ).add(Duration(hours: 20) + Duration(hours: val.toInt()));
                final hour = time.hour % 24;
                final label = hour == 0
                    ? '0AM'
                    : hour < 12
                    ? '${hour}AM'
                    : hour == 12
                    ? '12PM'
                    : '${hour - 12}PM';
                return Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              interval: 2,
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
