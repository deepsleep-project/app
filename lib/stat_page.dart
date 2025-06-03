import 'package:drp_19/storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatPage extends StatelessWidget {
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
              DayWeekStat(sleepRecords: sleepRecords),
              SizedBox(height: 20),
              Text(
                'Sleep duration this week',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 30,
                    left: 20,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(sleepDurationChart()),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Bed time this week',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 30,
                    left: 20,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(bedTimeChart()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    // Get current weekday and hour
    int currentWeekday = now.weekday; // 1 (Mon) - 7 (Sun)
    int currentHour = now.hour;

    // Determine the reference day for case 7
    int referenceWeekday;
    if (currentHour >= 12) {
      referenceWeekday = currentWeekday;
    } else {
      referenceWeekday = currentWeekday - 1;
      if (referenceWeekday == 0) referenceWeekday = 7;
    }

    // Build the list of weekdays for the chart
    // weekdays[0] = day for case 1, weekdays[6] = day for case 7
    List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> chartDays = List.generate(7, (i) {
      int dayIndex = (referenceWeekday - 7 + i) % 7;
      if (dayIndex < 0) dayIndex += 7;
      return weekDays[dayIndex];
    });

    Widget text;
    int idx = value.toInt() - 1;
    if (idx >= 0 && idx < 7) {
      text = Text(chartDays[idx], style: style);
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(meta: meta, child: text);
  }

  Widget leftHourTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2h';
        break;
      case 4:
        text = '4h';
        break;
      case 6:
        text = '6h';
        break;
      case 8:
        text = '8h';
        break;
      case 10:
        text = '10h';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget leftTimeTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case 22:
        text = '10pm';
        break;
      case 23:
        text = '11pm';
        break;
      case 24:
        text = '0am';
        break;
      case 25:
        text = '1am';
        break;
      case 26:
        text = '2am';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData sleepDurationChart() {
    // Prepare sleep duration data for the last 7 days
    int currentHour = now.hour;

    // Build a list of the last 7 days (from oldest to newest)
    List<DateTime> last7Days = List.generate(7, (i) {
      int daysAgo = 6 - i;
      if (currentHour < 12) {
        // If current hour is before noon, adjust the reference day
        daysAgo += 1;
      }
      DateTime day = now.subtract(Duration(days: daysAgo));
      // Set to midnight for comparison
      return DateTime(day.year, day.month, day.day);
    });

    // Map weekday index (1-7) to sleep duration (in hours)
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = last7Days[i];
      // Find the record for this day
      final record = sleepRecords.firstWhere(
        (r) {
          final startDate = DateTime.parse(r.start);
          return startDate.year == day.year &&
              startDate.month == day.month &&
              startDate.day == day.day;
        },
        orElse: () => SleepRecord(
          start: DateTime(2000).toIso8601String(),
          end: DateTime(2000).toIso8601String(),
          date: DateTime(2000).toIso8601String(),
          sleepRecordState: false,
        ),
      );
      double duration = 0;
      final startDate = DateTime.parse(record.start);
      final endDate = DateTime.parse(record.end);
      duration = endDate.difference(startDate).inMinutes / 60.0;
      if (duration < 0) duration = 0;
      if (startDate.year != 2000) {
        spots.add(FlSpot((i + 1).toDouble(), duration));
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftHourTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(colors: StatPage.gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: StatPage.gradientColors
                  .map((color) => color.withAlpha((0.3 * 255).toInt()))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData bedTimeChart() {
    // Prepare bed time data for the last 7 days
    int currentWeekday = now.weekday;
    int currentHour = now.hour;
    int referenceWeekday = (currentHour >= 12)
        ? currentWeekday
        : (currentWeekday - 1 == 0 ? 7 : currentWeekday - 1);

    // Build a list of the last 7 days (from oldest to newest)
    List<DateTime> last7Days = List.generate(7, (i) {
      int daysAgo = 6 - i;
      int weekdayOffset = (referenceWeekday - 7 + i) % 7;
      if (weekdayOffset < 0) weekdayOffset += 7;
      DateTime day = now.subtract(Duration(days: daysAgo));
      // Set to midnight for comparison
      return DateTime(day.year, day.month, day.day);
    });

    // Map weekday index (1-7) to bed time (in hour, e.g. 23.5 for 23:30)
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = last7Days[i];
      final record = sleepRecords.firstWhere(
        (r) =>
            DateTime.parse(r.start).year == day.year &&
            DateTime.parse(r.start).month == day.month &&
            DateTime.parse(r.start).day == day.day,
        orElse: () => SleepRecord(
          start: DateTime(2000).toIso8601String(),
          end: DateTime(2000).toIso8601String(),
          date: DateTime(2000).toIso8601String(),
          sleepRecordState: false,
        ),
      );
      double bedTime = 0;
      // Check if the record is a placeholder by comparing the start date
      if (DateTime.parse(record.start).year != 2000) {
        // If sleepStart is before 21:00, treat as after midnight (e.g. 1am = 25)
        int hour = DateTime.parse(record.start).hour;
        double minute = DateTime.parse(record.start).minute / 60.0;
        if (hour < 12) {
          bedTime = hour + 24 + minute;
        } else {
          bedTime = hour + minute;
        }
        spots.add(FlSpot((i + 1).toDouble(), bedTime));
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 0.5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTimeTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 1,
      maxX: 7,
      minY: 21,
      maxY: 26,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(colors: StatPage.gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: StatPage.gradientColors
                  .map((color) => color.withAlpha((0.3 * 255).toInt()))
                  .toList(),
            ),
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
      String suffix = hour >= 12 ? 'pm' : 'am';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
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
    List<double> last7Durations = last7
        .map((r) {
          final start = DateTime.parse(r.start);
          final end = DateTime.parse(r.end);
          double d = end.difference(start).inMinutes / 60.0;
          return d < 0 ? 0 : d;
        })
        .toList()
        .cast<double>();

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
