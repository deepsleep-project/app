import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:screen_state/screen_state.dart';

class SleepTracker with WidgetsBindingObserver {
  bool isSleeping = false;
  bool _isScreenOff = false;

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
    print("开始进入睡眠状态");
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSubscription?.cancel();
    isSleeping = false;
    print("结束睡眠状态");
  }

  void _startMonitoringScreen() async {
    try {
      final stream = await _screen.screenStateStream;
      _screenSubscription = stream.listen((event) {
        if (event == ScreenStateEvent.SCREEN_OFF) {
          _isScreenOff = true;
          print("屏幕关闭（锁屏）");
        } else {
          _isScreenOff = false;
          print("屏幕开启");
        }
      });
    } catch (e) {
      print("无法初始化屏幕状态监听: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isSleeping) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // 应用进入后台或非活动状态（锁屏或切出）
      if (!_isScreenOff) {
        // 不是锁屏，而是切出去玩手机
        print("检测到切出 app，自动退出睡眠状态");
        cancelSleep();
      } else {
        print("屏幕关闭时暂停，不取消睡眠状态");
      }
    }
  }

  void cancelSleep() {
    stop();
    onSleepCancelled();
  }
}
