package com.example.drp_19

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.FileObserver
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

fun JSONObject.toMap(): Map<String, *> = keys().asSequence().associateWith {
    when (val value = this[it]) {
        is JSONArray -> {
            val map = (0 until value.length()).associate { Pair(it.toString(), value[it]) }
            JSONObject(map).toMap().values.toList()
        }

        is JSONObject -> value.toMap()
        JSONObject.NULL -> null
        else -> value
    }
}


class Widget : AppWidgetProvider() {
    companion object {
        const val ACTION_TOGGLE = "com.example.drp_19.TOGGLE_SLEEP"
        const val PATH = "storage-61f76cb0-842b-4318-a644-e245f50a0b5a.json"

        @SuppressLint("StaticFieldLeak")
        private var fileObserver: WidgetFileObserver? = null


        private fun refreshAndBindAction(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
            val views = RemoteViews(
                context.packageName, if (getSleepingState(context)) R.layout.widget_sleeping else R.layout.widget_awake
            )

            // bind action to ui
            views.setOnClickPendingIntent(
                R.id.btn_toggle, PendingIntent.getBroadcast(context, 0, Intent(context, Widget::class.java).apply {
                    action = ACTION_TOGGLE
                }, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            )

            appWidgetManager.updateAppWidget(appWidgetIds, views)
        }

        // 获取状态
        private fun getSleepingState(context: Context): Boolean {
            val basePath = context.applicationInfo.dataDir
            val file = File("$basePath/$PATH")
            if (file.exists()) {
                val map = JSONObject(file.readText()).toMap()
                return map["isSleeping"] as Boolean
            } else {
                return false
            }
        }

        // 保存状态
        private fun saveSleepingState(context: Context, sleeping: Boolean) {
            val basePath = context.applicationInfo.dataDir
            val file = File("$basePath/$PATH")
            val map =
                (if (file.exists()) JSONObject(file.readText()).toMap() else mapOf<String, String>()).toMutableMap()
            map["isSleeping"] = sleeping
            file.writeText(JSONObject(map).toString())
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    class WidgetFileObserver(
        private val context: Context, private val file: File
    ) : FileObserver(file, CLOSE_WRITE) {
        override fun onEvent(event: Int, path: String?) {
            if (event == CLOSE_WRITE) {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, Widget::class.java))
                refreshAndBindAction(context, appWidgetManager, appWidgetIds)
            }
        }
    }


    @RequiresApi(Build.VERSION_CODES.Q)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        if (fileObserver == null) {
            val basePath = context.applicationInfo.dataDir
            val file = File("$basePath/$PATH")
            fileObserver = WidgetFileObserver(context, file)
            fileObserver?.startWatching()
        }
        refreshAndBindAction(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // filter out our intent
        if (intent.action == ACTION_TOGGLE) {
            saveSleepingState(context, !getSleepingState(context))
        }

        // refresh ui
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, Widget::class.java))
        refreshAndBindAction(context, appWidgetManager, appWidgetIds)
    }

}