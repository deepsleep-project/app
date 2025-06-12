import 'package:deepsleep/storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatPage extends StatefulWidget {
  final List<SleepRecord> sleepRecords;

  const StatPage({super.key, required this.sleepRecords});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  bool showWeek = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Text(
                'Your sleep performance',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ToggleButtons(
                  isSelected: [showWeek, !showWeek],
                  onPressed: (int index) {
                    setState(() {
                      showWeek = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  selectedColor: Colors.white,
                  fillColor: Colors.teal,
                  color: Colors.teal,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Week',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Month',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SummaryStat(
                sleepRecords: widget.sleepRecords,
                showWeek: showWeek,
              ),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SleepChart(
                    sleepRecords: widget.sleepRecords,
                    showWeek: showWeek,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryStat extends StatelessWidget {
  final List<SleepRecord> sleepRecords;
  final bool showWeek;

  const SummaryStat({
    super.key,
    required this.sleepRecords,
    required this.showWeek,
  });

  @override
  Widget build(BuildContext context) {
    final reversedRecords = sleepRecords.reversed.toList();
    final lastNightRecord = reversedRecords.isNotEmpty
        ? reversedRecords.first
        : null;

    List<SleepRecord> selectedRecords = showWeek
        ? reversedRecords.take(7).toList()
        : reversedRecords.take(30).toList();

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

    // Bed times for last 7 days
    List<DateTime> rangeBedTimes = selectedRecords
        .map((r) => DateTime.parse(r.start))
        .toList();

    // Durations for last 7 days
    List<double> rangeDurations = selectedRecords.map((r) {
      final start = DateTime.parse(r.start);
      final end = DateTime.parse(r.end);
      double d = end.difference(start).inMinutes / 60.0;
      return d < 0 ? 0.0 : d;
    }).toList();

    // Calculate average bed time
    DateTime? avgBedTime;
    if (rangeBedTimes.isNotEmpty) {
      int totalMinutes = rangeBedTimes.fold(0, (sum, dt) {
        int hour = dt.hour;
        if (hour < 12) hour += 24;
        return sum + hour * 60 + dt.minute;
      });
      int avgMinutes = (totalMinutes / rangeBedTimes.length).round();
      int avgHour = avgMinutes ~/ 60;
      int avgMinute = avgMinutes % 60;
      if (avgHour >= 24) avgHour -= 24;
      avgBedTime = DateTime(0, 1, 1, avgHour, avgMinute);
    }

    // Calculate average duration
    double avgDuration = rangeDurations.isNotEmpty
        ? rangeDurations.reduce((a, b) => a + b) / rangeDurations.length
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
                    showWeek ? '7-Day Avg' : '30-Day Avg',
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
                    rangeDurations.isNotEmpty
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
  final bool showWeek;

  static const List<Color> gradientColorHealthy = [
    Color.fromARGB(255, 6, 181, 163),
    Color(0xff02d39a),
  ];

  static const List<Color> gradientColorUnHealthy = [
    Color.fromARGB(255, 255, 91, 79),
    Color(0xfff7971e),
  ];

  const SleepChart({
    super.key,
    required this.sleepRecords,
    required this.showWeek,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final now = DateTime.now().toUtc();
    final todayDate = DateTime.utc(now.year, now.month, now.day);
    final showToday = now.hour >= 12;

    final range = showWeek ? 7 : 30;

    final days = List.generate(
      range,
      (i) => todayDate.subtract(
        Duration(days: range - 1 - i + (showToday ? 0 : 1)),
      ),
    );

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
          width: showWeek ? screenHeight * 0.03 : screenHeight * 0.005,
          gradient: LinearGradient(
            colors: record.sleepRecordState
                ? SleepChart.gradientColorHealthy
                : SleepChart.gradientColorUnHealthy,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(5),
        );
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: rod != null ? [rod] : [BarChartRodData(fromY: 0, toY: 0)],
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
              reservedSize: 36,
              getTitlesWidget: (double val, _) {
                if (val.toInt() >= 0 && val.toInt() < days.length) {
                  if (!showWeek && val % 4 != 0) return const SizedBox.shrink();

                  final day = days[val.toInt()];
                  final label = showWeek
                      ? DateFormat.E().format(day)
                      : DateFormat.Md().format(day);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
