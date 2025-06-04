import 'dart:io';

import 'package:drp_19/friend_page.dart';
import 'package:drp_19/internet.dart';
import 'package:drp_19/notification.dart';
import 'package:drp_19/setting_page.dart';
import 'package:drp_19/stat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'tent_page.dart';
import 'storage.dart';
import 'statistic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userId = '';
  String _formattedTime = '';
  bool _isSleeping = false;
  int _currency = 0;
  int _sleepConsistantly = 0;
  DateTime _start = DateTime(0);
  DateTime _end = DateTime(0);

  // Example sleep records with varied times
  final List<SleepRecord> _exampleRecords = [
    // Wednesday, May 28, 2025
    SleepRecord(
      start: DateTime.utc(2025, 5, 28, 21, 27).toIso8601String(),
      end: DateTime.utc(2025, 5, 29, 7, 18).toIso8601String(),
      date: DateTime.utc(2025, 5, 28, 0, 0).toIso8601String(),
      sleepRecordState: true,
    ),
    // Thursday, May 29, 2025
    SleepRecord(
      start: DateTime.utc(2025, 5, 29, 22, 45).toIso8601String(),
      end: DateTime.utc(2025, 5, 30, 7, 54).toIso8601String(),
      date: DateTime.utc(2025, 5, 29, 0, 0).toIso8601String(),
      sleepRecordState: true,
    ),

    // Friday, May 30, 2025
    SleepRecord(
      start: DateTime.utc(2025, 5, 30, 23, 09).toIso8601String(),
      end: DateTime.utc(2025, 5, 31, 8, 12).toIso8601String(),
      date: DateTime.utc(2025, 5, 30, 0, 0).toIso8601String(),
      sleepRecordState: true,
    ),
    // Saturday, May 31, 2025
    SleepRecord(
      start: DateTime.utc(2025, 6, 1, 1, 27).toIso8601String(),
      end: DateTime.utc(2025, 6, 1, 7, 36).toIso8601String(),
      date: DateTime.utc(2025, 5, 31, 0, 0).toIso8601String(),
      sleepRecordState: false,
    ),
    // Sunday, June 1, 2025
    SleepRecord(
      start: DateTime.utc(2025, 6, 1, 21, 58).toIso8601String(),
      end: DateTime.utc(2025, 6, 2, 6, 43).toIso8601String(),
      date: DateTime.utc(2025, 6, 1, 0, 0).toIso8601String(),
      sleepRecordState: true,
    ),
    // Monday, June 2, 2025
    SleepRecord(
      start: DateTime.utc(2025, 6, 2, 23, 02).toIso8601String(),
      end: DateTime.utc(2025, 6, 3, 7, 00).toIso8601String(),
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
    _uploadAsleep();

    if (Platform.isIOS) {
      AppNotification.instance
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      AppNotification.instance
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    AppNotification.instance.show(
      0,
      'plain title',
      'plain body',
      AppNotification.details,
      payload: 'item x',
    );
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
    String id = await SleepStorage.loadUserId();
    bool sleeping = await SleepStorage.loadIsSleeping();
    int currency = await SleepStorage.loadCurrency();
    String targetSleepTime = await SleepStorage.loadTargetSleepTime();
    String targetWakeUpTime = await SleepStorage.loadTargetWakeUpTime();
    List<SleepRecord> record = await SleepStorage.loadRecords();
    setState(() {
      _userId = id;
      _isSleeping = sleeping;
      _currency = currency;
      _sleepConsistantly = _calculateStrike(_exampleRecords);
      _start = DateTime.parse(targetSleepTime);
      _end = DateTime.parse(targetWakeUpTime);
    });
  }

  int _calculateStrike(List<SleepRecord> records) {
    int strike = 0;
    for (int i = 0; i < records.length; i++) {
      if (!records[i].sleepRecordState) {
        break;
      }
      strike += 1;
    }
    SleepStorage.saveStreak(strike);
    Internet.setstrike(_userId, strike);
    return strike;
  }

  Future<void> _uploadAsleep() async {
    bool timeout = false;
    if (_isSleeping && _userId.isNotEmpty) {
      await Internet.setAsleep(_userId).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          timeout = true;
        },
      );
    } else if (_userId.isNotEmpty) {
      await Internet.setAwake(_userId).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          timeout = true;
        },
      );
    }

    if (timeout) {
      _showSnackBar('Network timeout: failed to reach server.');
      return;
    }
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

    _uploadAsleep();

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

    bool pending = pendingGoodsleep(start, end);
    int goodSleep = 0;
    if (pending) {
      goodSleep = _currency + 100;
    } else {
      goodSleep = _currency;
    }

    await SleepStorage.saveCurrency(goodSleep);

    final date = getAdjustedDate(DateTime.parse(start)).toIso8601String();

    final records = await SleepStorage.loadRecords();
    records.add(
      SleepRecord(
        start: start,
        end: end,
        date: date,
        sleepRecordState: pending,
      ),
    );
    await SleepStorage.saveRecords(records);
    await SleepStorage.saveIsSleeping(false);

    setState(() {
      _isSleeping = false;
      _currency = goodSleep;
    });

    _uploadAsleep();

    _showSnackBar('wake up, curent time: $_formattedTime');
  }

  bool pendingGoodsleep(String start, String end) {
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

    if (startA.isBefore(startTime)) {
      if (diff <= difference) {
        return true;
      }
    }
    return false;
  }

  Future<void> _viewHistory() async {
    final records = _exampleRecords; //await SleepStorage.loadRecords();
    if (!context.mounted) return;
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[records.length - index - 1];
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(r.date))} State: ${r.sleepRecordState ? "Good" : "Bad"}',
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
                child: DayNightImage(screenHeight: screenHeight),
              ),
              Positioned(
                top: screenHeight * 0.07,
                left: screenHeight * 0.03,
                child: SizedBox(
                  width: 100,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, size: 25),
                        Text(
                          _currency.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.07,
                left: screenHeight * 0.15,
                child: SizedBox(
                  width: 100,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 25),
                        Text(
                          _sleepConsistantly.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -screenHeight * 0.19),
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
                  sleepRecords: _exampleRecords,
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}

class DayNightImage extends StatelessWidget {
  final double screenHeight;

  const DayNightImage({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour; // day: 6am - 6pm
    String imagePath = 'assets/day.png';

    if (hour < 6 || hour >= 20) {
      imagePath = 'assets/night.png';
    } else if (hour >= 6 && hour <= 9) {
      imagePath = 'assets/sunrise.png';
    } else if (hour >= 17 && hour < 20) {
      imagePath = 'assets/sunset.png';
    }

    return Image.asset(imagePath, fit: BoxFit.fitHeight, height: screenHeight);
  }
}
