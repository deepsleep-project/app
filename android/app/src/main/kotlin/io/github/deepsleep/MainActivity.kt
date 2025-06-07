package io.github.deepsleep

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 将FlutterEngine设置给广播接收器
        AppRefreshReceiver.flutterEngine = flutterEngine

        // 可选：注册其他插件
        // GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onDestroy() {
        // 清理引用
        AppRefreshReceiver.flutterEngine = null
        super.onDestroy()
    }
}
