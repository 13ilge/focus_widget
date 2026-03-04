import 'dart:convert';

enum AliskanlikTuru { sayac, boolean }

class Aliskanlik {
  final String id;
  final String baslik;
  final int hedef;
  final bool isIncreasing;
  final AliskanlikTuru tur;
  final int gunSayisi;

  Aliskanlik({
    required this.id,
    required this.baslik,
    required this.hedef,
    required this.isIncreasing,
    this.tur = AliskanlikTuru.sayac,
    this.gunSayisi = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'hedef': hedef,
      'isIncreasing': isIncreasing,
      'tur': tur.name,
      'gunSayisi': gunSayisi,
    };
  }

  factory Aliskanlik.fromJson(Map<String, dynamic> json) {
    return Aliskanlik(
      id: json['id'] as String,
      baslik: json['baslik'] as String,
      hedef: json['hedef'] as int,
      isIncreasing: json['isIncreasing'] as bool,
      tur: AliskanlikTuru.values.firstWhere(
        (t) => t.name == json['tur'],
        orElse: () => AliskanlikTuru.sayac,
      ),
      gunSayisi: (json['gunSayisi'] as int?) ?? 30,
    );
  }

  static String listeToJson(List<Aliskanlik> liste) {
    return jsonEncode(liste.map((a) => a.toJson()).toList());
  }

  static List<Aliskanlik> listeFromJson(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded
        .map((item) => Aliskanlik.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
