import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:screen_state/screen_state.dart';

class SleepTracker with WidgetsBindingObserver {
  bool isSleeping = false;
  bool _isScreenOff = false;
  bool _wakeUpDebounce = false;

  final void Function() onSleepCancelled;

  late final Screen _screen;
  StreamSubscription<ScreenStateEvent>? _screenSubscription;

  SleepTracker({required this.onSleepCancelled}) {
    _screen = Screen();
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startMonitoringScreen();
    isSleeping = true;
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSubscription?.cancel();
    isSleeping = false;
  }

void _startMonitoringScreen() async {
  try {
    final stream = _screen.screenStateStream;
    _screenSubscription = stream.listen((event) {
      print("screen event: $event");
      print("isScreenOff: $_isScreenOff");
      print("wakeDebounce: $_wakeUpDebounce");
      if (event == ScreenStateEvent.SCREEN_OFF && !_isScreenOff) {
        _isScreenOff = true;
        print("屏幕关闭（锁屏）");
      } else if (event == ScreenStateEvent.SCREEN_UNLOCKED && _isScreenOff && !_wakeUpDebounce) {
        _wakeUpDebounce = true;
          print("准备开启屏幕");
        Future.delayed(Duration(milliseconds: 800), () {
          _isScreenOff = false;
          print("屏幕开启");
          _wakeUpDebounce = false;
        });
      }
    });
  } catch (e) {
    print("无法初始化屏幕状态监听: $e");
  }
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Future.delayed(Duration(milliseconds: 500), () {
      // print("接收到事件：$state");
      // print("isSleeping: $_isScreenOff");
      // print("isScreenOff: $_isScreenOff");
      if (!isSleeping || _isScreenOff) return;
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
          print(state);
          print("检测到切出 app，自动退出睡眠状态");
          cancelSleep();
      }
    });
  }

  void cancelSleep() {
    stop();
    onSleepCancelled();
  }
}
