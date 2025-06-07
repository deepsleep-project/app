package io.github.deepsleep

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import java.net.HttpURLConnection
import java.net.URL

class Widget : AppWidgetProvider() {
    companion object {
        const val ACTION_TOGGLE = "io.github.deepsleep.TOGGLE_SLEEP"
        const val ACTION_REFRESH = "io.github.deepsleep.REFRESH_WIDGET"
        const val ACTION_REFRESH_APP = "io.github.deepsleep.REFRESH_APP"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val SERVER_URL = "http://146.169.26.221:3000"

        private fun postSleepStatus(uid: String, isSleeping: Boolean) {
            Thread {
                Log.d("Widget", "向服务器更新状态: $isSleeping")
                var connection: HttpURLConnection? = null
                try {
                    val dest = if (isSleeping) "wake" else "sleep"
                    val url = URL("$SERVER_URL/$dest")
                    connection = url.openConnection() as HttpURLConnection
                    connection.requestMethod = "POST"
                    connection.setRequestProperty("Content-Type", "application/json")
                    connection.doOutput = true

                    // 写入JSON数据
                    val outputStream = connection.outputStream
                    outputStream.write("{\"uid\":\"$uid\"}".toByteArray())
                    outputStream.flush()
                    outputStream.close()

                    val responseCode = connection.responseCode
                    if (responseCode == HttpURLConnection.HTTP_OK) {
                        Log.d("HttpUtil", "HTTP请求成功")
                    } else {
                        Log.e("HttpUtil", "HTTP请求失败: $responseCode")
                    }
                } catch (e: Exception) {
                    Log.e("HttpUtil", "HTTP请求异常: $e")
                } finally {
                    connection?.disconnect()
                }
            }.start()
        }

        private fun refreshAndBindAction(
            context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray
        ) {
            val isSleeping = getSleepingState(context)
            Log.d("Widget", "刷新小部件，状态: ${if (isSleeping) "睡眠" else "唤醒"}")

            appWidgetIds.forEach { appWidgetId ->
                val views = RemoteViews(
                    context.packageName,
                    if (isSleeping) R.layout.widget_sleeping else R.layout.widget_awake
                )

                // 绑定点击事件
                val toggleIntent = Intent(context, Widget::class.java).apply {
                    action = ACTION_TOGGLE
                }
                val pendingToggle = PendingIntent.getBroadcast(
                    context,
                    appWidgetId,
                    toggleIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )

                views.setOnClickPendingIntent(R.id.btn_toggle, pendingToggle)

                // 更新特定小部件实例
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }

        private fun getSleepingState(context: Context): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getBoolean("flutter.isSleeping", false)
        }

        private fun getUID(context: Context): String {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getString("flutter.userId", "") ?: ""
        }

        private fun saveSleepingState(context: Context, sleeping: Boolean) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            with(prefs.edit()) {
                putBoolean("flutter.isSleeping", sleeping)
                commit()
            }
            postSleepStatus(getUID(context), sleeping)
            context.sendBroadcast(Intent(ACTION_REFRESH_APP).apply {
                `package` = "io.github.deepsleep"
                putExtra("status", sleeping) // 添加额外参数
            })
            Log.d("Widget", "发送状态变化广播: $sleeping")
            Log.d("Widget", "保存睡眠状态: $sleeping")
        }
    }

    override fun onUpdate(
        context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray
    ) {
        Log.d("Widget", "onUpdate 被调用")
        refreshAndBindAction(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("Widget", "接收到的广播动作: ${intent.action}")

        when (intent.action) {
            ACTION_TOGGLE -> {
                Log.d("Widget", "切换睡眠状态")
                saveSleepingState(context, !getSleepingState(context))
                refreshAllWidgets(context)
            }

            ACTION_REFRESH -> {
                Log.d("Widget", "收到刷新请求")
                refreshAllWidgets(context)
            }

            else -> {
                Log.d("Widget", "其他广播: ${intent.action}")
                super.onReceive(context, intent)
            }
        }
    }

    private fun refreshAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, Widget::class.java)
        val ids = manager.getAppWidgetIds(component)
        Log.d("Widget", "刷新所有小部件，找到 ${ids.size} 个实例")
        refreshAndBindAction(context, manager, ids)
    }
}
