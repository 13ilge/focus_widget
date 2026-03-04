import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/aliskanlik_model.dart';
import '../services/storage_service.dart';
import '../widgets/aliskanlik_karti.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _hedefController = TextEditingController();
  final TextEditingController _gunController = TextEditingController();

  List<Aliskanlik> aliskanliklar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _listeYukle();
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _hedefController.dispose();
    _gunController.dispose();
    super.dispose();
  }

  Future<void> _listeYukle() async {
    final kayitliListe = await StorageService.aliskanliklarYukle();

    if (!mounted) return;
    setState(() {
      aliskanliklar = kayitliListe ?? [];
      _yukleniyor = false;
    });
  }

  void _yeniAliskanlikEkle() {
    bool isNegative = false;
    AliskanlikTuru secilenTur = AliskanlikTuru.sayac;
    _baslikController.clear();
    _hedefController.clear();
    _gunController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isSayac = secilenTur == AliskanlikTuru.sayac;

            return AlertDialog(
              title: const Text('Yeni Alışkanlık Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _turSecimButonu(
                            baslik: 'Sayaç',
                            aciklama: '+ / −',
                            icon: Icons.pin,
                            seciliMi: isSayac,
                            onTap: () {
                              setDialogState(() {
                                secilenTur = AliskanlikTuru.sayac;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _turSecimButonu(
                            baslik: 'Evet / Hayır',
                            aciklama: '✓ / ✗',
                            icon: Icons.check_circle_outline,
                            seciliMi: !isSayac,
                            onTap: () {
                              setDialogState(() {
                                secilenTur = AliskanlikTuru.boolean;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _baslikController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Alışkanlık Adı',
                        hintStyle: TextStyle(color: AppTheme.textHint),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.textPrimary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accent),
                        ),
                      ),
                    ),

                    if (isSayac) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _hedefController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Günlük Hedef/Limit',
                          hintStyle: TextStyle(color: AppTheme.textHint),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.textPrimary),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accent),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    SwitchListTile(
                      title: const Text(
                        'Kötü Alışkanlık mı?',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: Text(
                        isNegative
                            ? (isSayac
                                  ? 'Limiti aşmamalısın!'
                                  : 'Yapmamalısın!')
                            : (isSayac ? 'Hedefe ulaşmalısın!' : 'Yapmalısın!'),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      value: isNegative,
                      activeThumbColor: AppTheme.danger,
                      onChanged: (yeniDeger) {
                        setDialogState(() {
                          isNegative = yeniDeger;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _gunController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Takip süresi (gün) — varsayılan: 30',
                        hintStyle: TextStyle(color: AppTheme.textHint),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.textPrimary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: AppTheme.textHint),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final baslik = _baslikController.text.trim();
                    if (baslik.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen bir alışkanlık adı girin.'),
                        ),
                      );
                      return;
                    }

                    int hedef = 1;
                    bool isIncreasing = !isNegative;

                    if (isSayac) {
                      final parsedHedef = int.tryParse(_hedefController.text);
                      if (parsedHedef == null || parsedHedef <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lütfen geçerli bir hedef girin (1 veya üzeri).',
                            ),
                          ),
                        );
                        return;
                      }
                      hedef = parsedHedef;
                    }

                    setState(() {
                      aliskanliklar.add(
                        Aliskanlik(
                          id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
                          baslik: baslik,
                          hedef: hedef,
                          isIncreasing: isIncreasing,
                          tur: secilenTur,
                          gunSayisi: int.tryParse(_gunController.text) ?? 30,
                        ),
                      );
                    });
                    StorageService.aliskanliklarKaydet(aliskanliklar);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: AppTheme.accent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _turSecimButonu({
    required String baslik,
    required String aciklama,
    required IconData icon,
    required bool seciliMi,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: seciliMi ? AppTheme.accent.withAlpha(50) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seciliMi ? AppTheme.accent : Colors.grey[600]!,
            width: seciliMi ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: seciliMi ? AppTheme.accent : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              baslik,
              style: TextStyle(
                color: seciliMi ? AppTheme.accent : Colors.grey,
                fontSize: 13,
                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              aciklama,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zinciri Kırma')),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : aliskanliklar.isEmpty
          ? _bosEkran()
          : _aliskanlikListesi(),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniAliskanlikEkle,
        tooltip: 'Yeni Alışkanlık Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bosEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 20),
          Text(
            'Henüz alışkanlık eklemedin',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sağ alttaki + butonuna tıklayarak\nbir alışkanlık ekle!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _aliskanlikListesi() {
    return ListView.builder(
      itemCount: aliskanliklar.length,
      itemBuilder: (context, index) {
        final siradaki = aliskanliklar[index];

        return Dismissible(
          key: Key(siradaki.id),
          background: Container(
            color: AppTheme.scaffoldBackground,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() {
              aliskanliklar.removeAt(index);
            });
            StorageService.aliskanliklarKaydet(aliskanliklar);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${siradaki.baslik} silindi'),
                action: SnackBarAction(
                  label: 'Geri Al',
                  onPressed: () {
                    setState(() {
                      aliskanliklar.insert(index, siradaki);
                    });
                    StorageService.aliskanliklarKaydet(aliskanliklar);
                  },
                ),
              ),
            );
          },
          child: AliskanlikKarti(
            baslik: siradaki.baslik,
            hedef: siradaki.hedef,
            isIncreasing: siradaki.isIncreasing,
            id: siradaki.id,
            tur: siradaki.tur,
            gunSayisi: siradaki.gunSayisi,
          ),
        );
      },
    );
  }
}
