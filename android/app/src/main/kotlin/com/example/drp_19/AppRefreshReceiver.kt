package com.example.drp_19

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AppRefreshReceiver : BroadcastReceiver() {
    // 静态变量持有FlutterEngine引用
    companion object {
        var flutterEngine: FlutterEngine? = null
        const val CHANNEL = "com.example.drp_19/channel"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.drp_19.REFRESH_APP") {
            val status = intent.getBooleanExtra("status", false)
            Log.d("AppRefreshReceiver", "收到应用刷新广播")
            // 确保FlutterEngine已初始化
            flutterEngine?.let { engine ->
                // 通过MethodChannel通知Flutter
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).apply {
                    invokeMethod("onRefresh", status)
                }
            }
        }
    }
}
