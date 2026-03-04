# 🔗 Zinciri Kırma — Alışkanlık Takip Uygulaması

İyi alışkanlıkları kazanmak ve kötü alışkanlıkları bırakmak için günlük sayaç uygulaması.

## Özellikler

- ✅ Günlük sayaç (artırma / azaltma)
- ✅ İyi ve kötü alışkanlık ayrımı
- ✅ Son 30 günlük ilerleme gösterimi (nokta grafiği)
- ✅ Kaydırarak silme + geri alma
- ✅ Verileri yerel olarak kaydetme (SharedPreferences)

## Kurulum

```bash
flutter pub get
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                        # Uygulama giriş noktası
├── constants/
│   └── theme.dart                   # Tema sabitleri
├── models/
│   └── aliskanlik_model.dart        # Veri modeli
├── screens/
│   └── ana_ekran.dart               # Ana ekran
├── services/
│   └── storage_service.dart         # Veri kaydetme/yükleme
├── utils/
│   └── tarih_helper.dart            # Tarih formatlama
└── widgets/
    └── aliskanlik_karti.dart        # Alışkanlık kartı
```
