import 'package:drp_19/friend_page.dart';
import 'package:drp_19/setting_page.dart';
import 'package:drp_19/stat_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'tent_page.dart';
import 'storage.dart';
import 'statistic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _formattedTime = '';
  bool _isSleeping = false;
  int _currency = 0;
  DateTime _start = DateTime(0);
  DateTime _end = DateTime(0);

  final DateTime _exampleTime = DateTime.utc(2025, 6, 2, 0, 0);

  // Example sleep records for the past 7 days with varied times
  final List<SleepRecord> _exampleRecords = [
    // Most recent night
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 0, hours: 2)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).add(Duration(days: 0, hours: 6, minutes: 30)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 0)).toIso8601String(),
    ),
    // 1 day ago, short sleep
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 1, hours: 1)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 1, hours: -5)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 1)).toIso8601String(),
    ),
    // 2 days ago, late night
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 2, hours: 2, minutes: 30)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 2, hours: -4, minutes: 15)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 2)).toIso8601String(),
    ),
    // 3 days ago, long sleep
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 3, hours: 22)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 3, hours: 14)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 3)).toIso8601String(),
    ),
    // 4 days ago, nap only
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 4, hours: 23)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 4, hours: 17, minutes: 15)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 4)).toIso8601String(),
    ),
    // 5 days ago, normal sleep
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 5, hours: 23, minutes: 30)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 5, hours: 14)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 5)).toIso8601String(),
    ),
    // 6 days ago, early sleep
    SleepRecord(
      start: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 6, hours: 21, minutes: 45)).toIso8601String(),
      end: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 6, hours: 11, minutes: 30)).toIso8601String(),
      date: DateTime.utc(
        2025,
        6,
        2,
        0,
        0,
      ).subtract(Duration(days: 6)).toIso8601String(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    _loadInitialSleepState();
  }

  // Update and format the current time
  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    setState(() {
      _formattedTime = formatter.format(now);
    });
  }

  // Navigate to tent_page
  void _goToTentPage() {
    Navigator.of(context).push(_createFadeRouteToTentPage());
  }

  // Create a fade transition route to the tent_page
  Route _createFadeRouteToTentPage() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => TentPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Navigate to friend_page
  void _goToFriendPage() {
    Navigator.of(context).push(_createFadeRouteToFriendPage());
  }

  // Create a fade transition route to the friend_page
  Route _createFadeRouteToFriendPage() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => FriendPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Navigate to setting_page
  void _goToSettingPage() {
    Navigator.of(context).push(_createFadeRouteToSettingPage());
  }

  // Create a fade transition route to the setting_page
  Route _createFadeRouteToSettingPage() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Load the initial sleep state from storage
  Future<void> _loadInitialSleepState() async {
    bool sleeping = await SleepStorage.loadIsSleeping();
    int currency = await SleepStorage.loadCurrency();
    String targetSleepTime = await SleepStorage.loadTargetSleepTime();
    String targetWakeUpTime = await SleepStorage.loadTargetWakeUpTime();
    setState(() {
      _isSleeping = sleeping;
      _currency = currency;
      _start = DateTime.parse(targetSleepTime);
      _end = DateTime.parse(targetWakeUpTime);
    });
  }

  Future<void> _startSleep() async {
    if (_isSleeping) {
      _showSnackBar('already asleep');
      return;
    }
    final now = DateTime.now().toIso8601String();
    await SleepStorage.saveStartTime(now);
    await SleepStorage.saveIsSleeping(true);
    setState(() {
      _isSleeping = true;
    });
    _showSnackBar('start sleep, current time: $_formattedTime');
  }

  Future<void> _endSleep() async {
    if (!_isSleeping) {
      _showSnackBar('not current sleeping');
      return;
    }
    final end = DateTime.now().toIso8601String();
    final start = await SleepStorage.loadStartTime();

    if (start == null) {
      _showSnackBar('Error: start time not found');
      return;
    }

    int goodSleep = _currency + pendingGoodsleep(start, end);
    
    await SleepStorage.saveCurrency(goodSleep);

    final date = getAdjustedDate(DateTime.parse(start)).toIso8601String();

    final records = await SleepStorage.loadRecords();
    records.add(SleepRecord(start: start, end: end, date: date));
    await SleepStorage.saveRecords(records);
    await SleepStorage.saveIsSleeping(false);

    setState(() {
      _isSleeping = false;
      _currency = goodSleep;
    });

    _showSnackBar('wake up, curent time: $_formattedTime');
  }

  int pendingGoodsleep(String start, String end) {
    DateTime startA = DateTime.parse(start);
    DateTime endA = DateTime.parse(end);
    Duration difference = endA.difference(startA); 
    if (_end.isBefore(_start)) {
      _end = _end.add(Duration(days: 1));
    }
    DateTime startTime = DateTime(
      startA.year,
      startA.month,
      startA.day,
      _start.hour,
      _start.minute,
      _start.second,
      _start.millisecond,
      _start.microsecond,
    );
    Duration diff = _end.difference(_start);

    if (startA.isBefore(startTime)){
      if (diff <= difference) {
        return 100;
      }
    }
    return 0;
  }

  Future<void> _viewHistory() async {
    final records = await SleepStorage.loadRecords();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(r.date))}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.start))}\n'
                          'End: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.end))}',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Shut down'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/day.png',
                  fit: BoxFit.fitHeight,
                  height: screenHeight,
                ),
              ),
              Positioned(
                top: 70,
                left: 20,
                child:Container(
                  width: 50,  // 宽度
                  height: 50, // 高度
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 110, 189, 254),          // 背景颜色
                    shape: BoxShape.circle,      // 设置为圆形
                  ),
                  alignment: Alignment.center,   // 居中对齐文字
                  child: Text(
                    '\$:${_currency.toString()}',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                )
              ),
              Transform.translate(
                offset: Offset(0, -screenHeight * 0.20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          fontFamily: "Digital",
                          letterSpacing: -2,
                          fontSize: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!_isSleeping)
                        _buildButton('Go to bed', _startSleep)
                      else
                        _buildButton('Get up', _endSleep),
                      const SizedBox(height: 20),
                      _buildButton('Sleep history', _viewHistory),
                    ],
                  ),
                ),
              ),

              // Toolbar friends icon to navigate to friends page
              Positioned(
                top: screenHeight * 0.07,
                right: screenHeight * 0.03,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _goToFriendPage,
                      child: Icon(
                        Icons.people,
                        size: 40,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    GestureDetector(
                      onTap: _goToSettingPage,
                      child: Icon(
                        Icons.settings,
                        size: 40,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),

              // Invisible button to navigate to tent_page
              Positioned(
                bottom: screenHeight * 0.2,
                left: screenHeight * 0.08,
                right: screenHeight * 0.1,
                height: screenHeight * 0.19,
                child: GestureDetector(
                  onTap: _goToTentPage,
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Text "statistics" at bottom
              Positioned(
                bottom: screenHeight * 0.03,
                left: screenHeight * 0.1,
                right: screenHeight * 0.1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'statistics',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withAlpha(230),
                      size: 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
          FutureBuilder<List<SleepRecord>>(
            future: SleepStorage.loadRecords(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StatPage(
                  // Uncomment this line to show charts using real sleep data
                  // sleepRecords: snapshot.data!,
                  sleepRecords: _exampleRecords.reversed.toList(),
                );
              } else {
                return Center(child: Text('loading'));
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build a button widget with common styles
  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
