package com.fortune.cooking.fortune

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PieProgramWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.pie_program_widget).apply {
        val launchIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("fortune://app/pie-program"),
        )
        setOnClickPendingIntent(R.id.widget_root, launchIntent)

        val task = widgetData.getString("pie_current_task", null) ?: "No active task"
        val remaining = widgetData.getString("pie_remaining", null) ?: "0m"
        val progress = (widgetData.getFloat("pie_progress", 0f) * 100f).toInt().coerceIn(0, 100)

        setTextViewText(R.id.pie_task, task)
        setTextViewText(R.id.pie_remaining, remaining)
        setProgressBar(R.id.pie_progress, 100, progress, false)
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
