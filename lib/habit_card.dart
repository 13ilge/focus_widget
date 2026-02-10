import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

String tarihFormatla(DateTime tarih) {
  return "${tarih.year}-${tarih.month}-${tarih.day}";
}

class AliskanlikKarti extends StatefulWidget {
  final String baslik;
  final int hedef;
  final bool isIncreasing;
  final String id;

  const AliskanlikKarti({
    super.key,
    required this.baslik,
    required this.hedef,
    required this.isIncreasing,
    required this.id,
  });

  @override
  State<AliskanlikKarti> createState() => _AliskanlikKartiState();
}

class _AliskanlikKartiState extends State<AliskanlikKarti> {
  int anlikSayi = 0;
  List<int> gecmisVeriler = [];

  @override
  void initState() {
    super.initState();
    veriyiYukle();

    //testVerisiOlustur();

    gecmisiYukle();
  }

  void veriyiYukle() async {
    final prefs = await SharedPreferences.getInstance();

    String bugununAnahtari = "${widget.id}_${tarihFormatla(DateTime.now())}";

    setState(() {
      anlikSayi = prefs.getInt(bugununAnahtari) ?? 0;
    });
  }

  void veriyiKaydet() async {
    final prefs = await SharedPreferences.getInstance();

    String bugununAnahtari = "${widget.id}_${tarihFormatla(DateTime.now())}";

    await prefs.setInt(bugununAnahtari, anlikSayi);
  }

  void gecmisiYukle() async {
    final prefs = await SharedPreferences.getInstance();
    List<int> geciciListe = [];
    DateTime bugun = DateTime.now();

    for (int i = 0; i < 30; i++) {
      DateTime oGun = bugun.subtract(Duration(days: i));

      String anahtar = "${widget.id}_${tarihFormatla(oGun)}";

      int oGununSayisi = prefs.getInt(anahtar) ?? 0;
      geciciListe.add(oGununSayisi);
    }

    setState(() {
      gecmisVeriler = geciciListe.reversed.toList();
    });
  }

  void testVerileriOlustur() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime bugun = DateTime.now();

    for (int i = 0; i < 30; i++) {
      DateTime oGun = bugun.subtract(Duration(days: i));
      String anahtar = "${widget.id}_${tarihFormatla(oGun)}";
      await prefs.setInt(anahtar, (i * 2) % (widget.hedef + 1));
    }
    gecmisiYukle();
  }
  // --------------------------------------------
  void testVerisiOlustur() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random(); // Rastgele sayı üreticisi
    DateTime bugun = DateTime.now();

    // 30 günlük döngü
    for (int i = 0; i < 30; i++) {
      // 1. Tarihi Hesapla: Bugünden 'i' gün geriye git
      DateTime islemGunu = bugun.subtract(Duration(days: i));
      
      // 2. Anahtarı Oluştur: Örn: "su_hedefi_v1_2026-02-08"
      String anahtar = "${widget.id}_${tarihFormatla(islemGunu)}";
      
      // 3. Rastgele Sayı Üret: 0 ile (Hedef + 5) arasında
      // Örn: Hedef 5 ise, 0-10 arası sayı üretir.
      int rastgeleSayi = random.nextInt(widget.hedef + 5);
      
      // 4. Hafızaya Yaz
      await prefs.setInt(anahtar, rastgeleSayi);
    }

    // İşlem bitince ekrandaki tabloyu güncellemek için geçmişi tekrar yükle
    gecmisiYukle();
  }
  // -------------------------------------------------

  Color noktaRengiSec(int sayi) {
    if (sayi == 0) return Colors.grey;
    int yuzde = yuzdeHesapla(sayi);
    return renkSec(yuzde);
  }

  void sayiyiArttir() {
    setState(() {
      anlikSayi++;
    });
    veriyiKaydet();
  }

  int yuzdeHesapla(int sayi) {
    if (widget.hedef == 0) return 0;
    return ((sayi / widget.hedef) * 100).round();
  }

  Color renkSec(int yuzde) {
    if (widget.isIncreasing == false) {
      if (yuzde < 50) return Colors.green;
      if (yuzde <= 100) return Colors.orange;
      return Colors.red;
    } else {
      if (yuzde < 50) return Colors.red;
      if (yuzde < 100) return Colors.orange;
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    int yuzde = yuzdeHesapla(anlikSayi);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: renkSec(yuzde),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.baslik,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Bugün: $anlikSayi / ${widget.hedef}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  sayiyiArttir();
                  gecmisiYukle();
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Son 30 Gün:",
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          const SizedBox(height: 5),

          Wrap(
            spacing: 5, // Noktalar arası yatay boşluk
            runSpacing: 5, // Noktalar arası dikey boşluk (alt satıra geçerse)
            children: gecmisVeriler.map((sayi) {
              return Container(
                width: 10, // Nokta genişliği
                height: 10, // Nokta yüksekliği
                decoration: BoxDecoration(
                  color: noktaRengiSec(sayi), // Her noktanın rengi özel
                  shape: BoxShape.circle, // Yuvarlak olsun
                  border: Border.all(
                    color: Colors.white30,
                    width: 1,
                  ), // İnce bir çerçeve
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
