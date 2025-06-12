import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:deepsleep/friend_page.dart';
import 'package:deepsleep/internet.dart';
import 'package:deepsleep/notification.dart';
import 'package:deepsleep/setting_page.dart';
import 'package:deepsleep/stat_page.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'tent_page.dart';
import 'storage.dart';
import 'statistic.dart';
import 'shop_page.dart';
import 'sleeptracker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _userId = '';
  String _formattedTime = '';
  bool _isSleeping = false;
  int _currency = 0;
  int _sleepConsistantly = 0;
  DateTime _start = DateTime(0);
  DateTime _end = DateTime(0);
  final PageController _pageController = PageController();
  late SleepTracker sleepTracker;
  @override
  void initState() {
    super.initState();
    sleepTracker = SleepTracker(onSleepCancelled: _handleSleepCancelled);
    _updateTime();
    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    _loadInitialSleepState();
    _notifyServer();
    _listenForAndroidIntent();

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

  void _handleSleepCancelled() {
    _showSnackBar('you leave the app');
    _endSleep();
  }

  // Update and format the current time
  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    setState(() => _formattedTime = formatter.format(now));
  }

  // Navigate to tent_page
  void _goToTentPage() {
    Navigator.of(context).push(_createFadeRouteToTentPage());
  }

  // Create a fade transition route to the tent_page
  Route _createFadeRouteToTentPage() => PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => TentPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  // Navigate to friend_page
  void _goToFriendPage() {
    Navigator.of(context).push(_createFadeRouteToFriendPage());
  }

  // Create a fade transition route to the friend_page
  Route _createFadeRouteToFriendPage() => PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => FriendPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );

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

  // Navigate to setting_page
  void _goToShopPage() {
    Navigator.of(context).push(_createFadeRouteToShopPage());
  }

  // Create a fade transition route to the setting_page
  Route _createFadeRouteToShopPage() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => ShopPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void dispose() {
    sleepTracker.stop();
    super.dispose();
  }

  // Load the initial sleep state from storage
  Future<void> _loadInitialSleepState() async {
    String id = await SleepStorage.loadUserId();
    bool sleeping = await SleepStorage.loadIsSleeping();
    int currency = await SleepStorage.loadCurrency();
    String targetSleepTime = await SleepStorage.loadTargetSleepTime();
    String targetWakeUpTime = await SleepStorage.loadTargetWakeUpTime();
    List<SleepRecord> record = await SleepStorage.loadRecords();
    if (_isSleeping) {
      sleepTracker.start();
    }

    setState(() {
      _userId = id;
      _isSleeping = sleeping;
      _currency = currency;
      _sleepConsistantly = _calculateStreak(record);
      _start = DateTime.parse(targetSleepTime);
      _end = DateTime.parse(targetWakeUpTime);
    });
  }

  int _calculateStreak(List<SleepRecord> records) {
    int streak = 0;
    for (int i = records.length - 1; i >= 0; i--) {
      if (!records[i].sleepRecordState) {
        break;
      }
      streak += 1;
    }
    SleepStorage.saveStreak(streak);
    return streak;
  }

  Future<void> _notifyServer() async {
    bool timeout = false;
    if (_isSleeping && _userId.isNotEmpty) {
      await Internet.setAsleep(_userId).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          timeout = true;
        },
      );
    } else if (_userId.isNotEmpty) {
      await Internet.setAwake(_userId).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          timeout = true;
        },
      );
      await Internet.setStreak(_userId, _sleepConsistantly).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          timeout = true;
        },
      );
      await Internet.setEnergy(_userId, _currency).timeout(
        const Duration(seconds: 60),
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
      return;
    }
    final now = DateTime.now().toIso8601String();
    await SleepStorage.saveStartTime(now);
    await SleepStorage.saveIsSleeping(true);
    sleepTracker.start();
    setState(() => _isSleeping = true);

    _notifyServer();
    _notifyDesktopWidget();
  }

  Future<void> _endSleep() async {
    if (!_isSleeping) {
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
    sleepTracker.stop();

    setState(() {
      _isSleeping = false;
      _currency = goodSleep;
      // _currency += 500;
    });

    await SleepStorage.saveCurrency(_currency);

    _notifyServer();
    _notifyDesktopWidget();
  }

  Future<void> _notifyDesktopWidget() async {
    if (Platform.isAndroid) {
      final AndroidIntent intent = AndroidIntent(
        action: 'io.github.deepsleep.REFRESH_WIDGET',
        package: 'io.github.deepsleep',
      );
      await intent.sendBroadcast();
    }
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

  Widget _timeBox(String label, String time) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SizedBox(
        width: screenHeight * 0.06, // Fixed width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _durationString(String start, String end) {
    final startTime = DateTime.parse(start);
    final endTime = DateTime.parse(end);
    final duration = endTime.difference(startTime);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _viewHistory() async {
    final records = await SleepStorage.loadRecords();
    // final records = exampleRecords;
    if (!context.mounted) return;
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sleep history'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[records.length - index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: r.sleepRecordState
                        ? Colors.green[200]
                        : Colors.orange[200],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(DateTime.parse(r.date)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _timeBox(
                            "Slept",
                            DateFormat('HH:mm').format(DateTime.parse(r.start)),
                          ),
                          Text(
                            _durationString(r.start, r.end),
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                          _timeBox(
                            "Awake",
                            DateFormat('HH:mm').format(DateTime.parse(r.end)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
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
    _loadInitialSleepState();
    final screenHeight = MediaQuery.of(context).size.height;
    if (_isSleeping) {
      AppNotification.cancelTodaySleepReminder();
    }
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _isSleeping
          ? _buildSleepingView(screenHeight)
          : _buildAwakeView(screenHeight),
    );
  }

  Widget _buildSleepingView(double screenHeight) {
    return Scaffold(
      key: ValueKey("asleep"),
      body: PageView(
        scrollDirection: Axis.vertical,
        physics: _isSleeping
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/night.png',
                  fit: BoxFit.fitHeight,
                  height: screenHeight,
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
                      _buildButton('Get up', _endSleep),
                      const SizedBox(height: 80),
                    ],
                  ),
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
            ],
          ),
          FutureBuilder<List<SleepRecord>>(
            future: SleepStorage.loadRecords(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StatPage(
                  // Uncomment this line to show charts using real sleep data
                  sleepRecords: snapshot.data!,
                  // sleepRecords: _exampleRecords,
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

  Widget _buildAwakeView(double screenHeight) {
    return Scaffold(
      key: ValueKey("awake"),
      body: Scaffold(
        body: PageView(
          controller: _pageController,
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
                    width: 250,
                    height: 55,
                    child: Row(
                      children: [
                        Icon(Icons.bolt, size: 30, color: Colors.yellow),
                        Text(
                          _currency.toString(),
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(
                          Icons.local_fire_department,
                          size: 30,
                          color: Colors.deepOrange,
                        ),
                        Text(
                          ' ${_sleepConsistantly.toString()}',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                      SizedBox(height: screenHeight * 0.01),
                      GestureDetector(
                        onTap: _goToShopPage,
                        child: Icon(
                          Icons.shopping_cart,
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
                // Invisible button to navigate to statistic
                Positioned(
                  bottom: screenHeight * 0.03,
                  left: screenHeight * 0.15,
                  right: screenHeight * 0.15,
                  height: screenHeight * 0.1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(0, 0, 0, 0),
                        ),
                      ),
                    ),
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
                    sleepRecords: snapshot.data!,
                    // sleepRecords: _exampleRecords,
                  );
                } else {
                  return Center(child: Text('loading'));
                }
              },
            ),
          ],
        ),
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

  Future<void> _listenForAndroidIntent() async {
    if (!Platform.isAndroid) {
      return;
    }
    const channel = MethodChannel('io.github.deepsleep/channel');

    channel.setMethodCallHandler((call) async {
      if (call.method == 'onRefresh') {
        debugPrint("✅ 通过原生通道收到刷新广播");
        debugPrint("newStatus: ${call.arguments as bool}");
        setState(() => _isSleeping = call.arguments as bool);
      }
      return Future.value(null);
    });
    debugPrint("正在监听广播");
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

    return Image.asset(imagePath, fit: BoxFit.fill, height: screenHeight);
  }
}
