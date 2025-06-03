import 'package:flutter/material.dart';
import 'storage.dart';
import 'package:flutter/cupertino.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          TimePickerWithTap(),
          // Back button
          Positioned(
            top: screenHeight * 0.08, // adjust for padding/status bar
            left: screenHeight * 0.03,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimePickerWithTap extends StatefulWidget {
  @override
  _TimePickerWithTapState createState() => _TimePickerWithTapState();
}

class _TimePickerWithTapState extends State<TimePickerWithTap> {
  int startHour = 0;
  int startMinute = 0;
  int endHour = 0;
  int endMinute = 0;

  Future<void> _loadInitialTargetState() async {
    String targetSleepTime = await SleepStorage.loadTargetSleepTime();
    String targetWakeUpTime = await SleepStorage.loadTargetWakeUpTime();
    setState(() {
      startHour = DateTime.parse(targetSleepTime).hour;
      startMinute = DateTime.parse(targetSleepTime).minute;
      endHour = DateTime.parse(targetWakeUpTime).hour;
      endMinute = DateTime.parse(targetWakeUpTime).minute;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInitialTargetState();
  }

  void _showStartTime() {
    _showTimePickerDialog(
      initialHour: startHour,
      initialMinute: startMinute,
      onConfirm: (h, m) {
        setState(() {
          startHour = h;
          startMinute = m;
        });
      },
    );
  }

  void _showEndTime() {
    _showTimePickerDialog(
      initialHour: endHour,
      initialMinute: endMinute,
      onConfirm: (h, m) {
        setState(() {
          endHour = h;
          endMinute = m;
        });
      },
    );
  }

  void _saveStartTime() {
    String time = DateTime(
      2025,
      0,
      0,
      startHour,
      startMinute,
    ).toIso8601String();
    print(time);
    SleepStorage.saveTargetSleepTime(time);
  }

  void _saveEndTime() {
    String time = DateTime(2025, 0, 0, endHour, endMinute).toIso8601String();
    print(time);
    SleepStorage.saveTargetWakeUpTime(time);
  }

  void _showTimePickerDialog({
    required int initialHour,
    required int initialMinute,
    required Function(int, int) onConfirm,
  }) {
    int tempHour = initialHour;
    int tempMinute = initialMinute;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      onConfirm(tempHour, tempMinute);
                      Navigator.pop(context);
                      _saveStartTime();
                      _saveEndTime();
                    },
                    child: Text("Confirm"),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: initialHour,
                        ),
                        onSelectedItemChanged: (index) {
                          tempHour = index;
                        },
                        children: List.generate(
                          24,
                          (i) => Center(child: Text('$i')),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: initialMinute,
                        ),
                        onSelectedItemChanged: (index) {
                          tempMinute = index;
                        },
                        children: List.generate(
                          60,
                          (i) => Center(child: Text('$i')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int h, int m) {
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Target Schedule",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text("Start Time", style: TextStyle(fontSize: 20)),
                      GestureDetector(
                        onTap: _showStartTime,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTime(startHour, startMinute),
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("End Time", style: TextStyle(fontSize: 20)),
                      GestureDetector(
                        onTap: _showEndTime,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTime(endHour, endMinute),
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SleepTimeBar(startHour: startHour, startMinute: startMinute),
              SleepDuration(
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute,
              ),
              SizedBox(height: screenHeight * 0.25),
            ],
          ),
        ),
      ),
    );
  }
}

class SleepTimeBar extends StatelessWidget {
  final int startHour;
  final int startMinute;

  const SleepTimeBar({
    super.key,
    required this.startHour,
    required this.startMinute,
  });

  @override
  Widget build(BuildContext context) {
    // Show the time to go to sleep in a styled bar
    String formattedTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Bed Time",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              int adjustedStartHour = startHour % 24 + 24;
              double startTime = (startHour * 60 + startMinute) / 60;

              // Bar settings
              double minTime = 20.0;
              double maxTime = 27.0;
              double barWidth = constraints.maxWidth;
              double pos = ((startTime - minTime) / (maxTime - minTime)).clamp(
                0.0,
                1.0,
              );

              // Healthy range: 8pm(20.0) - 0am(24.0)
              double healthyStart = (20.0 - minTime) / (maxTime - minTime);
              double healthyEnd = (24.0 - minTime) / (maxTime - minTime);

              Color barColor = (startTime >= 20 && startTime <= 24)
                  ? Colors.green
                  : Colors.redAccent;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background bar
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      // Healthy range highlight
                      Positioned(
                        left: barWidth * healthyStart,
                        child: Container(
                          height: 18,
                          width: barWidth * (healthyEnd - healthyStart),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                      // User's duration marker
                      Positioned(
                        left: barWidth * pos - 8,
                        child: Container(
                          width: 22,
                          height: 28,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26, width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_drop_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("20:00", style: TextStyle(fontSize: 14)),
                      Text("03:00", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 6),
                  if (startTime < 20 || startTime > 24)
                    Text(
                      "Unhealthy bed time",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      "Healthy bed time",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SleepDuration extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const SleepDuration({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  @override
  Widget build(BuildContext context) {
    // Sleep duration bar
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Sleep Duration",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate sleep duration in hours (handle overnight)
              int startTotal = startHour * 60 + startMinute;
              int endTotal = endHour * 60 + endMinute;
              int durationMinutes = endTotal - startTotal;
              if (durationMinutes <= 0) durationMinutes += 24 * 60;
              double durationHours = durationMinutes / 60.0;

              // Bar settings
              double minHours = 5.0;
              double maxHours = 11.0;
              double barWidth = constraints.maxWidth;
              double pos = ((durationHours - minHours) / (maxHours - minHours))
                  .clamp(0.0, 1.0);

              // Healthy range: 7-10 hours
              double healthyStart = (7.0 - minHours) / (maxHours - minHours);
              double healthyEnd = (10.0 - minHours) / (maxHours - minHours);

              Color barColor = (durationHours >= 7 && durationHours <= 10)
                  ? Colors.green
                  : Colors.redAccent;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background bar
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      // Healthy range highlight
                      Positioned(
                        left: barWidth * healthyStart,
                        child: Container(
                          height: 18,
                          width: barWidth * (healthyEnd - healthyStart),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                      // User's duration marker
                      Positioned(
                        left: barWidth * pos - 8,
                        child: Container(
                          width: 22,
                          height: 28,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26, width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_drop_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("5h", style: TextStyle(fontSize: 14)),
                      Text("11h", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "${durationHours.toStringAsFixed(1)} hours",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (durationHours < 7 || durationHours > 10)
                    Text(
                      "Unhealthy sleep duration",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      "Healthy sleep duration",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
