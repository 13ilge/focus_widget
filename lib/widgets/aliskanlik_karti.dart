import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/aliskanlik_model.dart';
import '../services/storage_service.dart';
import '../services/home_widget_service.dart';

class AliskanlikKarti extends StatefulWidget {
  final String baslik;
  final int hedef;
  final bool isIncreasing;
  final String id;
  final AliskanlikTuru tur;
  final int gunSayisi;

  const AliskanlikKarti({
    super.key,
    required this.baslik,
    required this.hedef,
    required this.isIncreasing,
    required this.id,
    this.tur = AliskanlikTuru.sayac,
    this.gunSayisi = 30,
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
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final bugunSayi = await StorageService.gunlukSayiYukle(
      widget.id,
      DateTime.now(),
    );
    final gecmis = await StorageService.gecmisVeriYukle(
      widget.id,
      widget.gunSayisi,
    );

    if (!mounted) return;
    setState(() {
      anlikSayi = bugunSayi;
      gecmisVeriler = gecmis;
    });
  }

  void _sayiyiArttir() {
    setState(() {
      anlikSayi++;
    });
    _kaydetVeGuncelle();
  }

  void _sayiyiAzalt() {
    if (anlikSayi <= 0) return;
    setState(() {
      anlikSayi--;
    });
    _kaydetVeGuncelle();
  }

  bool get _yapildiMi => anlikSayi >= 1;

  void _durumDegistir(bool yeniDurum) {
    setState(() {
      anlikSayi = yeniDurum ? 1 : 0;
    });
    _kaydetVeGuncelle();
  }

  Future<void> _kaydetVeGuncelle() async {
    await StorageService.gunlukSayiKaydet(widget.id, DateTime.now(), anlikSayi);
    final gecmis = await StorageService.gecmisVeriYukle(
      widget.id,
      widget.gunSayisi,
    );
    if (!mounted) return;
    setState(() {
      gecmisVeriler = gecmis;
    });

    // Android widget’ını güncelle
    HomeWidgetService.widgetVerisiGuncelle(
      aliskanlik: Aliskanlik(
        id: widget.id,
        baslik: widget.baslik,
        hedef: widget.hedef,
        isIncreasing: widget.isIncreasing,
        tur: widget.tur,
        gunSayisi: widget.gunSayisi,
      ),
      bugunSayi: anlikSayi,
      gecmisVeriler: gecmis,
    );
  }

  int _yuzdeHesapla(int sayi) {
    if (widget.hedef == 0) return 0;
    return ((sayi / widget.hedef) * 100).round();
  }

  Color _noktaRengiSec(int sayi) {
    if (sayi == 0) {
      return widget.isIncreasing ? Colors.grey : AppTheme.dotGreen;
    }

    if (widget.tur == AliskanlikTuru.boolean) {
      if (widget.isIncreasing) {
        return sayi >= 1 ? AppTheme.dotGreen : Colors.grey;
      } else {
        return sayi >= 1 ? AppTheme.dotRed : AppTheme.dotGreen;
      }
    }

    final yuzde = _yuzdeHesapla(sayi);
    if (widget.isIncreasing) {
      if (yuzde < 50) return AppTheme.dotRed;
      if (yuzde < 100) return AppTheme.dotGold;
      return AppTheme.dotGreen;
    } else {
      if (yuzde < 50) return AppTheme.dotGreen;
      if (yuzde <= 100) return AppTheme.dotGold;
      return AppTheme.dotRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
                      widget.tur == AliskanlikTuru.boolean
                          ? (_yapildiMi ? 'Yapıldı' : 'Yapılmadı')
                          : 'Bugün: $anlikSayi / ${widget.hedef}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              widget.tur == AliskanlikTuru.boolean
                  ? _booleanAksiyon()
                  : _sayacAksiyon(),
            ],
          ),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Son ${widget.gunSayisi} Gün:',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          const SizedBox(height: 5),

          LayoutBuilder(
            builder: (context, constraints) {
              const double noktaBoyutu = 10;
              const double bosluk = 5;
              final int sutunSayisi =
                  ((constraints.maxWidth + bosluk) / (noktaBoyutu + bosluk))
                      .floor();

              final List<List<int>> satirlar = [];
              for (int i = 0; i < widget.gunSayisi; i += sutunSayisi) {
                final int bitis = (i + sutunSayisi > widget.gunSayisi)
                    ? widget.gunSayisi
                    : i + sutunSayisi;
                satirlar.add(
                  List.generate(bitis - i, (j) {
                    final idx = i + j;
                    return idx < gecmisVeriler.length ? gecmisVeriler[idx] : 0;
                  }),
                );
              }

              return Column(
                children: satirlar.map((satir) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: satir.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: entry.key < satir.length - 1 ? bosluk : 0,
                          ),
                          child: Container(
                            width: noktaBoyutu,
                            height: noktaBoyutu,
                            decoration: BoxDecoration(
                              color: _noktaRengiSec(entry.value),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _booleanAksiyon() {
    if (widget.isIncreasing) {
      return IconButton(
        onPressed: () => _durumDegistir(!_yapildiMi),
        icon: Icon(
          _yapildiMi ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 40,
          color: _yapildiMi ? AppTheme.dotGreen : Colors.white54,
        ),
        tooltip: _yapildiMi ? 'Geri al' : 'Tamamla',
      );
    } else {
      return IconButton(
        onPressed: () => _durumDegistir(!_yapildiMi),
        icon: Icon(
          _yapildiMi ? Icons.cancel : Icons.radio_button_unchecked,
          size: 40,
          color: _yapildiMi ? AppTheme.dotRed : Colors.white54,
        ),
        tooltip: _yapildiMi ? 'Geri al' : 'Yaptım',
      );
    }
  }

  Widget _sayacAksiyon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _sayiyiAzalt,
          icon: const Icon(Icons.remove_circle, size: 36, color: Colors.white),
          tooltip: 'Azalt',
        ),
        IconButton(
          onPressed: _sayiyiArttir,
          icon: const Icon(Icons.add_circle, size: 36, color: Colors.white),
          tooltip: 'Artır',
        ),
      ],
    );
  }
}
