package com.example.focus_widget.glance

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import androidx.glance.Button
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import androidx.compose.ui.graphics.Color

class AliskanlikWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences

        val habitId = prefs.getString("aktif_habit_id", "") ?: ""
        val baslik = prefs.getString("${habitId}_baslik", "Alışkanlık") ?: "Alışkanlık"
        val hedef = prefs.getInt("${habitId}_hedef", 1)
        val bugun = prefs.getInt("${habitId}_bugun", 0)
        val isIncreasing = prefs.getBoolean("${habitId}_isIncreasing", true)
        val tur = prefs.getString("${habitId}_tur", "sayac") ?: "sayac"
        val gecmisStr = prefs.getString("${habitId}_gecmis", "") ?: ""

        val gecmisVeriler = if (gecmisStr.isNotEmpty()) {
            gecmisStr.split(",").mapNotNull { it.toIntOrNull() }
        } else {
            emptyList()
        }

        // Compose Color nesneleri — ColorProvider doğrudan Color alabilir
        val bgColor = ColorProvider(Color(0xFF11144C))
        val textWhite = ColorProvider(Color.White)
        val textGrey = ColorProvider(Color(0xFFB0B0B0))

        val durumMetni = if (tur == "boolean") {
            if (bugun >= 1) "✅ Yapıldı" else "⬜ Yapılmadı"
        } else {
            "Bugün: $bugun / $hedef"
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(bgColor)
                .padding(16.dp)
                .cornerRadius(16.dp)
        ) {
            Column(
                modifier = GlanceModifier.fillMaxWidth()
            ) {
                Text(
                    text = baslik,
                    style = TextStyle(
                        color = textWhite,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                )

                Spacer(modifier = GlanceModifier.height(4.dp))

                Text(
                    text = durumMetni,
                    style = TextStyle(
                        color = textGrey,
                        fontSize = 12.sp
                    )
                )

                Spacer(modifier = GlanceModifier.height(8.dp))

                // Etkileşim Butonları
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (tur == "boolean") {
                        Button(
                            text = if (bugun >= 1) "Geri Al" else "Tamamla",
                            onClick = actionRunCallback<InteractiveAction>(
                                actionParametersOf(
                                    ActionParameters.Key<String>("uri") to "app://widget/toggle?id=$habitId"
                                )
                            )
                        )
                    } else {
                        Button(
                            text = "-",
                            onClick = actionRunCallback<InteractiveAction>(
                                actionParametersOf(
                                    ActionParameters.Key<String>("uri") to "app://widget/decrement?id=$habitId"
                                )
                            )
                        )
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Button(
                            text = "+",
                            onClick = actionRunCallback<InteractiveAction>(
                                actionParametersOf(
                                    ActionParameters.Key<String>("uri") to "app://widget/increment?id=$habitId"
                                )
                            )
                        )
                    }
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Geçmiş nokta grafiği
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    val gosterilecek = gecmisVeriler.takeLast(15)
                    for ((i, sayi) in gosterilecek.withIndex()) {
                        val noktaRenk = noktaRenginiSec(sayi, hedef, isIncreasing, tur)
                        Box(
                            modifier = GlanceModifier
                                .size(8.dp)
                                .background(noktaRenk)
                                .cornerRadius(4.dp)
                        ) {}
                        if (i < gosterilecek.size - 1) {
                            Spacer(modifier = GlanceModifier.width(3.dp))
                        }
                    }
                }
            }
        }
    }

    // Renk değerlerini compose Color nesnesi olarak döndür (ColorProvider ile uyumlu)
    private fun noktaRenginiSec(
        sayi: Int,
        hedef: Int,
        isIncreasing: Boolean,
        tur: String
    ): ColorProvider {
        val dotGreen = ColorProvider(Color(0xFF3A9679))
        val dotGold = ColorProvider(Color(0xFFFABC60))
        val dotRed = ColorProvider(Color(0xFFE16262))
        val dotGrey = ColorProvider(Color(0xFF888888))

        if (sayi == 0) {
            return if (isIncreasing) dotGrey else dotGreen
        }

        if (tur == "boolean") {
            return if (isIncreasing) {
                if (sayi >= 1) dotGreen else dotGrey
            } else {
                if (sayi >= 1) dotRed else dotGreen
            }
        }

        val yuzde = if (hedef == 0) 0 else (sayi * 100) / hedef
        return if (isIncreasing) {
            when {
                yuzde < 50 -> dotRed
                yuzde < 100 -> dotGold
                else -> dotGreen
            }
        } else {
            when {
                yuzde < 50 -> dotGreen
                yuzde <= 100 -> dotGold
                else -> dotRed
            }
        }
    }
}

class InteractiveAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val uriStr = parameters[ActionParameters.Key<String>("uri")] ?: return
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            android.net.Uri.parse(uriStr)
        )
        backgroundIntent.send()

        // Veri değiştiğinde Glance widget'ını yeniden render et
        AliskanlikWidget().update(context, glanceId)
    }
}
