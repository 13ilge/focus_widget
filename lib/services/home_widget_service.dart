import 'package:home_widget/home_widget.dart';
import '../models/aliskanlik_model.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  if (uri == null) return;

  if (uri.host == 'widget') {
    final action = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    final habitId = uri.queryParameters['id'];

    if (action != null && habitId != null) {
      final aliskanliklar = await StorageService.aliskanliklarYukle() ?? [];
      final habitIndex = aliskanliklar.indexWhere((h) => h.id == habitId);

      if (habitIndex != -1) {
        final habit = aliskanliklar[habitIndex];
        int bugunku = await StorageService.gunlukSayiYukle(
          habitId,
          DateTime.now(),
        );

        if (action == 'increment') {
          bugunku++;
        } else if (action == 'decrement') {
          if (bugunku > 0) bugunku--;
        } else if (action == 'toggle') {
          bugunku = bugunku >= 1 ? 0 : 1;
        }

        await StorageService.gunlukSayiKaydet(habitId, DateTime.now(), bugunku);
        final gecmis = await StorageService.gecmisVeriYukle(
          habitId,
          habit.gunSayisi,
        );

        await HomeWidgetService.widgetVerisiGuncelle(
          aliskanlik: habit,
          bugunSayi: bugunku,
          gecmisVeriler: gecmis,
        );
      }
    }
  }
}

class HomeWidgetService {
  // Alıcının tam sınıf adı — Glance render tetiklemesi için kritik
  static const String _androidWidgetName = 'AliskanlikWidgetReceiver';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId('group.focus_widget');
    await HomeWidget.registerBackgroundCallback(interactiveCallback);
  }

  static Future<void> widgetVerisiGuncelle({
    required Aliskanlik aliskanlik,
    required int bugunSayi,
    required List<int> gecmisVeriler,
  }) async {
    final prefix = aliskanlik.id;

    // Tüm verileri önce kaydet
    await Future.wait([
      HomeWidget.saveWidgetData<String>('${prefix}_baslik', aliskanlik.baslik),
      HomeWidget.saveWidgetData<int>('${prefix}_hedef', aliskanlik.hedef),
      HomeWidget.saveWidgetData<int>('${prefix}_bugun', bugunSayi),
      HomeWidget.saveWidgetData<bool>(
        '${prefix}_isIncreasing',
        aliskanlik.isIncreasing,
      ),
      HomeWidget.saveWidgetData<String>('${prefix}_tur', aliskanlik.tur.name),
      HomeWidget.saveWidgetData<int>(
        '${prefix}_gunSayisi',
        aliskanlik.gunSayisi,
      ),
      HomeWidget.saveWidgetData<String>(
        '${prefix}_gecmis',
        gecmisVeriler.join(','),
      ),
    ]);

    await HomeWidget.saveWidgetData<String>('aktif_habit_id', prefix);

    // Kısa bekleme — SharedPreferences flush süresini tamamlamak için
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Glance widget'ını yenile
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  static Future<void> aliskanlikListesiGuncelle(List<Aliskanlik> liste) async {
    final idler = liste.map((a) => a.id).join(',');
    final basliklar = liste.map((a) => a.baslik).join(',');

    await HomeWidget.saveWidgetData<String>('tum_idler', idler);
    await HomeWidget.saveWidgetData<String>('tum_basliklar', basliklar);
  }
}
