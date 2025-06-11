import 'package:flutter/material.dart';
import 'storage.dart';
import 'notification.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: TimePickerWithTap(),
          ),

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
  const TimePickerWithTap({super.key});

  @override
  State<TimePickerWithTap> createState() => _TimePickerWithTapState();
}

class _TimePickerWithTapState extends State<TimePickerWithTap> {
  double bedtimeValue = 20; // 20:00 (8 PM)
  double wakeTimeValue = 5; // 7:00 (7 AM)

  @override
  void initState() {
    super.initState();
    _loadInitialTargetState();
  }

  Future<void> _loadInitialTargetState() async {
    String targetSleepTime = await SleepStorage.loadTargetSleepTime();
    String targetWakeUpTime = await SleepStorage.loadTargetWakeUpTime();
    final sleep = DateTime.parse(targetSleepTime);
    final wake = DateTime.parse(targetWakeUpTime);

    setState(() {
      bedtimeValue = sleep.hour + sleep.minute / 60.0;
      if (bedtimeValue < 20) bedtimeValue += 24; // Normalize to 20–26

      wakeTimeValue = wake.hour + wake.minute / 60.0;
    });
  }

  void _saveTimes() {
    int sleepHour = bedtimeValue.floor() % 24;
    int sleepMinute = ((bedtimeValue % 1) * 60).round();

    int wakeHour = wakeTimeValue.floor();
    int wakeMinute = ((wakeTimeValue % 1) * 60).round();

    final sleepTime = DateTime(
      2025,
      0,
      0,
      sleepHour,
      sleepMinute,
    ).toIso8601String();
    final wakeTime = DateTime(
      2025,
      0,
      0,
      wakeHour,
      wakeMinute,
    ).toIso8601String();

    SleepStorage.saveTargetSleepTime(sleepTime);
    SleepStorage.saveTargetWakeUpTime(wakeTime);
    // AppNotification.publishSleepReminders(sleepHour, sleepMinute);
  }

  String _formatTime(double value) {
    int hour = value.floor() % 24;
    int minute = ((value % 1) * 60).round();
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  double _calculateSleepDuration() {
    double start = bedtimeValue >= 24 ? bedtimeValue - 24 : bedtimeValue;
    double duration = wakeTimeValue - start;
    if (duration < 0) duration += 24;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    double sleepDuration = _calculateSleepDuration();
    bool isBedTimeHealthy = bedtimeValue >= 21 && bedtimeValue <= 24;
    bool isWakeTimeHealthy = wakeTimeValue >= 6 && wakeTimeValue <= 10;
    bool isDurationHealthy = sleepDuration >= 7 && sleepDuration <= 11;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.005),
            Text(
              "Your sleep goals",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _buildSlider(
              label: "Target bedtime",
              value: bedtimeValue,
              min: 20,
              max: 26,
              onChanged: (val) => setState(() => bedtimeValue = val),
              healthyRange: RangeValues(21, 24),
            ),
            Text(
              "Selected: ${_formatTime(bedtimeValue)}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),
            _buildSlider(
              label: "Target awake time",
              value: wakeTimeValue,
              min: 5,
              max: 12,
              onChanged: (val) => setState(() => wakeTimeValue = val),
              healthyRange: RangeValues(6, 10),
            ),
            Text(
              "Selected: ${_formatTime(wakeTimeValue)}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      (isBedTimeHealthy &&
                          isWakeTimeHealthy &&
                          isDurationHealthy)
                      ? Colors.green[50]
                      : Colors.orange[50],
                  border: Border.all(
                    color:
                        (isBedTimeHealthy &&
                            isWakeTimeHealthy &&
                            isDurationHealthy)
                        ? Colors.green
                        : Colors.orange,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📝 Sleep Goal Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            (isBedTimeHealthy &&
                                isWakeTimeHealthy &&
                                isDurationHealthy)
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      spacing: 5,
                      children: [
                        if (isBedTimeHealthy)
                          Icon(Icons.check_circle, color: Colors.green)
                        else
                          Icon(Icons.warning, color: Colors.orange),
                        Text(
                          isBedTimeHealthy
                              ? "Bedtime is healthy"
                              : "Set a heathier bedtime",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      spacing: 5,
                      children: [
                        if (isWakeTimeHealthy)
                          Icon(Icons.check_circle, color: Colors.green)
                        else
                          Icon(Icons.warning, color: Colors.orange),
                        Text(
                          isWakeTimeHealthy
                              ? "Wake-up time is healthy"
                              : "Set a healthier wake up time",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      spacing: 5,
                      children: [
                        if (isDurationHealthy)
                          Icon(Icons.check_circle, color: Colors.green)
                        else
                          Icon(Icons.warning, color: Colors.orange),

                        if (isDurationHealthy)
                          Text(
                            "Sleep duration is ideal: ${sleepDuration.toStringAsFixed(1)} hrs",
                            style: TextStyle(fontSize: 18),
                          )
                        else
                          Text(
                            sleepDuration <= 7
                                ? "Sleep duration too short: ${sleepDuration.toStringAsFixed(1)} hrs"
                                : "Sleep duration too long: ${sleepDuration.toStringAsFixed(1)} hrs",
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                    if (isBedTimeHealthy &&
                        isWakeTimeHealthy &&
                        isDurationHealthy) ...[
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.emoji_emotions, color: Colors.green[700]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Great job! Your sleep plan is in the healthy range.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: 180,
              height: 50,
              child: IconButton(
                onPressed: () {
                  _saveTimes();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Sleep goals saved!")));
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withAlpha(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Text(
                  "Save goals",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required RangeValues healthyRange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: HealthRangeSliderTrackShape(
              healthyRange: healthyRange,
              min: min,
              max: max,
            ),
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.grey[300], // fallback
            thumbColor:
                (value >= healthyRange.start && value <= healthyRange.end)
                ? const Color.fromARGB(255, 46, 133, 49)
                : const Color.fromARGB(255, 255, 167, 35),
            overlayColor: Colors.deepPurple.withAlpha(32),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
            trackHeight: 30,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 12).toInt(),
            label: _formatTime(value),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class HealthRangeSliderTrackShape extends SliderTrackShape {
  final RangeValues healthyRange;
  final double min;
  final double max;

  HealthRangeSliderTrackShape({
    required this.healthyRange,
    required this.min,
    required this.max,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: true,
      isDiscrete: true,
    );

    final double trackStart = trackRect.left;
    final double trackEnd = trackRect.right;
    final double trackWidth = trackEnd - trackStart;

    double startPx =
        trackStart + ((healthyRange.start - min) / (max - min)) * trackWidth;
    double endPx =
        trackStart + ((healthyRange.end - min) / (max - min)) * trackWidth;

    const Radius radius = Radius.circular(15);

    // Paint full background track with rounded corners (grey)
    final RRect fullTrackRRect = RRect.fromRectAndRadius(trackRect, radius);
    canvas.drawRRect(fullTrackRRect, Paint()..color = Colors.grey[300]!);

    // Paint healthy middle segment with its own rounded corners
    final RRect healthyTrackRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(startPx, trackRect.top, endPx, trackRect.bottom),
      Radius.circular(trackRect.height / 2),
    );
    canvas.drawRRect(
      healthyTrackRRect,
      Paint()..color = Colors.green.withAlpha(100),
    );

    // Paint active segment (left of thumb) — optional highlight
    final RRect activeTrackRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        trackStart,
        trackRect.top,
        thumbCenter.dx,
        trackRect.bottom,
      ),
      radius,
    );
    canvas.drawRRect(
      activeTrackRRect,
      Paint()..color = sliderTheme.activeTrackColor!,
    );
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx + 12;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 24;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
