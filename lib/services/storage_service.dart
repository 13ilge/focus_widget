import 'package:shared_preferences/shared_preferences.dart';
import '../models/aliskanlik_model.dart';
import '../utils/tarih_helper.dart';

class StorageService {
  static const String _aliskanlikListeKey = 'aliskanlik_listesi';

  static Future<void> aliskanliklarKaydet(List<Aliskanlik> liste) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aliskanlikListeKey, Aliskanlik.listeToJson(liste));
  }

  static Future<List<Aliskanlik>?> aliskanliklarYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_aliskanlikListeKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return Aliskanlik.listeFromJson(jsonStr);
  }

  static Future<int> gunlukSayiYukle(String id, DateTime tarih) async {
    final prefs = await SharedPreferences.getInstance();
    final anahtar = '${id}_${tarihFormatla(tarih)}';
    return prefs.getInt(anahtar) ?? 0;
  }

  static Future<void> gunlukSayiKaydet(
    String id,
    DateTime tarih,
    int sayi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final anahtar = '${id}_${tarihFormatla(tarih)}';
    await prefs.setInt(anahtar, sayi);
  }

  static Future<List<int>> gecmisVeriYukle(String id, int gunSayisi) async {
    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now();
    List<int> geciciListe = [];

    for (int i = gunSayisi - 1; i >= 0; i--) {
      final oGun = bugun.subtract(Duration(days: i));
      final anahtar = '${id}_${tarihFormatla(oGun)}';
      geciciListe.add(prefs.getInt(anahtar) ?? 0);
    }

    return geciciListe;
  }

  static Future<void> aliskanlikVerileriniSil(String id, int gunSayisi) async {
    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now();
    for (int i = 0; i < gunSayisi + 30; i++) {
      // Just to be safe, search a bit beyond the required days, up to +30 extra days
      final oGun = bugun.subtract(Duration(days: i));
      final anahtar = '${id}_${tarihFormatla(oGun)}';
      await prefs.remove(anahtar);
    }
  }
}
