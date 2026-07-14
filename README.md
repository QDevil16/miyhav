# Miyhav

Miyhav; evcil hayvan sahiplerinin petlerini takip etmesini, sağlık kayıtlarını
güvenle tutmasını ve diğer pet sahipleriyle sosyalleşmesini sağlayan bir
**Android + iOS** mobil uygulamasıdır.

> Bu depo **private**'tır. Web/masaüstü hedefi yoktur; tek Flutter kod tabanından
> yalnızca Android ve iOS üretilir.

## Ne yapar?
- **Pet profilleri:** Birden fazla pet ekleme, düzenleme, silme.
- **Sağlık takibi:** Aşı, parazit, ilaç, veteriner ziyareti, alerji, teşhis,
  ameliyat, kilo, muayene kayıtları; tekrarlayan hatırlatmalar.
- **Sağlık karnesi PDF'i:** Cihaz üzerinde oluşturma, ön izleme, paylaşma.
- **Sosyalleşme:** Pet paylaşımları, beğeni, yorum, arkadaşlık, keşfet.
- **Gizlilik:** Herkese açık / sadece arkadaşlar / gizli profil ve paylaşım.
- **Bildirimler:** Yaklaşan sağlık hatırlatmaları için push (FCM).

## Teknoloji
| Katman | Seçim |
|---|---|
| Mobil | Flutter, Dart, Material 3, Riverpod, GoRouter |
| Backend | Supabase (Postgres, Auth, Storage, Realtime, Edge Functions, Cron, RLS) |
| Push | Firebase Cloud Messaging (yalnızca bildirim) |
| iOS CI/CD | Codemagic (cloud macOS build → TestFlight → App Store) |
| PDF | Cihaz üzerinde (`pdf` + `printing`) |

## Depo Yapısı (planlanan)
```
lib/                 Flutter uygulama kodu (feature-first)
supabase/migrations/ Versiyonlanmış SQL şema + RLS
supabase/functions/  Edge Functions
docs/                Ürün, mimari ve güvenlik dokümanları
codemagic.yaml       iOS/Android cloud build (ilgili görevde)
.env.example         Örnek ortam değişkenleri (gerçek secret içermez)
```

## Geliştirme Durumu
Proje küçük, test edilebilir görevlerle ilerler. Güncel plan ve durum için:
- Görev listesi: [`docs/TASKS.md`](docs/TASKS.md)
- Tamamlananlar: [`docs/COMPLETED.md`](docs/COMPLETED.md)
- Mimari: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

## Kurulum (geliştirici notu)
Ortam kurulumu ve gizli değerler: [`docs/ENVIRONMENT_SETUP.md`](docs/ENVIRONMENT_SETUP.md).
Uygulama, gizli değerler `--dart-define` ile verilerek çalıştırılır. Depoda gerçek
secret bulunmaz.

## Güvenlik & Gizlilik
Pet sağlık verileri kesinlikle özeldir ve yalnızca pet sahibine görünür. Erişim
kontrolü Supabase Row Level Security ile veritabanı seviyesinde uygulanır. Ayrıntı:
[`docs/RLS_SECURITY_MODEL.md`](docs/RLS_SECURITY_MODEL.md),
[`docs/PRIVACY_MATRIX.md`](docs/PRIVACY_MATRIX.md).

## Lisans
Özel/kapalı kaynak. Tüm hakları saklıdır.
