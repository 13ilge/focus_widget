package com.example.focus_widget.glance

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
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

        val bgColor = ColorProvider(android.graphics.Color.parseColor("#11144C"))
        val textWhite = ColorProvider(android.graphics.Color.WHITE)
        val textGrey = ColorProvider(android.graphics.Color.parseColor("#B0B0B0"))

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

                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    val gosterilecek = gecmisVeriler.takeLast(15)
                    for ((i, sayi) in gosterilecek.withIndex()) {
                        val renk = noktaRengiSec(sayi, hedef, isIncreasing, tur)
                        Box(
                            modifier = GlanceModifier
                                .size(8.dp)
                                .background(ColorProvider(renk))
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

    private fun noktaRengiSec(
        sayi: Int,
        hedef: Int,
        isIncreasing: Boolean,
        tur: String
    ): Int {
        val dotGreen = android.graphics.Color.parseColor("#3A9679")
        val dotGold = android.graphics.Color.parseColor("#FABC60")
        val dotRed = android.graphics.Color.parseColor("#E16262")
        val dotGrey = android.graphics.Color.parseColor("#888888")

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
