
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
      appBar: AppBar(title: Text('Setting')),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
          TimePickerWithTap(),
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

  void _saveStartTime(){
    String time = DateTime(2025, 0, 0, startHour, startMinute).toIso8601String();
    print(time);
    SleepStorage.saveTargetSleepTime(time);
  }

  void _saveEndTime(){
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
        return Container(
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
                        scrollController: FixedExtentScrollController(initialItem: initialHour),
                        onSelectedItemChanged: (index) {
                          tempHour = index;
                        },
                        children: List.generate(24, (i) => Center(child: Text('$i'))),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: initialMinute),
                        onSelectedItemChanged: (index) {
                          tempMinute = index;
                        },
                        children: List.generate(60, (i) => Center(child: Text('$i'))),
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
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text("Target Schedule", style: TextStyle(fontSize: 40)),
            Text("Start Time            End Time", style: TextStyle(fontSize: 20)),
            Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showStartTime,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatTime(startHour, startMinute),
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showEndTime,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatTime(endHour, endMinute),
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ],
          ),]
        ),
      ),
    );
  }
}