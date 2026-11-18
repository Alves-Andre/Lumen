package com.example.devocional

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget da tela inicial. Os dados são gravados pelo app (home_widget) em
 * SharedPreferences; o "já leu hoje" é recalculado aqui comparando a data,
 * para virar corretamente à meia-noite mesmo sem abrir o app.
 */
class DevocionalWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val readToday = widgetData.getString("read_today_date", "") == today
        val streak = widgetData.getString("streak", "0") ?: "0"
        val streakSuffix = widgetData.getString("streak_suffix", "dias") ?: "dias"
        val shields = widgetData.getString("shields", "0") ?: "0"
        val nextLabel = widgetData.getString("next_label", null)
        val nextUri = widgetData.getString("next_uri", null) ?: HOME_URI
        val recitativeLabel = widgetData.getString("recitative_label", null)
        val recitativeUri = widgetData.getString("recitative_uri", null) ?: HOME_URI

        val streakColor = if (readToday) Color.parseColor("#F4B355") else Color.parseColor("#61728F")

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.devocional_widget).apply {
                setTextViewText(R.id.streak_text, streak)
                setTextColor(R.id.streak_text, streakColor)
                setTextViewText(R.id.streak_suffix, streakSuffix)
                setTextColor(R.id.streak_suffix, streakColor)
                setTextViewText(R.id.shield_text, shields)
                setTextViewText(
                    R.id.status_text,
                    if (readToday) "Você já leu hoje. Glória a Deus!" else "Leia hoje para manter a ofensiva",
                )
                setTextViewText(R.id.continue_text, nextLabel ?: "Abrir a Bíblia")

                setOnClickPendingIntent(R.id.widget_root, launch(context, HOME_URI))
                setOnClickPendingIntent(R.id.continue_button, launch(context, nextUri))

                if (recitativeLabel.isNullOrEmpty()) {
                    setViewVisibility(R.id.recitative_row, View.GONE)
                } else {
                    setViewVisibility(R.id.recitative_row, View.VISIBLE)
                    setTextViewText(R.id.recitative_text, recitativeLabel)
                    setOnClickPendingIntent(R.id.recitative_row, launch(context, recitativeUri))
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launch(context: Context, uri: String) =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

    companion object {
        const val HOME_URI = "devocional://hoje"
    }
}
