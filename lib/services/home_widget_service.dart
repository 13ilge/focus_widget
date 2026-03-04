import 'package:home_widget/home_widget.dart';
import '../models/aliskanlik_model.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'AliskanlikWidgetReceiver';

  static Future<void> widgetVerisiGuncelle({
    required Aliskanlik aliskanlik,
    required int bugunSayi,
    required List<int> gecmisVeriler,
  }) async {
    final prefix = aliskanlik.id;

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

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  static Future<void> aliskanlikListesiGuncelle(List<Aliskanlik> liste) async {
    final idler = liste.map((a) => a.id).join(',');
    final basliklar = liste.map((a) => a.baslik).join(',');

    await HomeWidget.saveWidgetData<String>('tum_idler', idler);
    await HomeWidget.saveWidgetData<String>('tum_basliklar', basliklar);
  }
}
