# ARCHITECTURE — Miyhav Teknik Mimari

## 1. Genel Yaklaşım
Feature-first, sade katmanlı mimari. Aşırı abstraction ve gereksiz interface'ten
kaçınılır. İş mantığı widget içine yazılmaz; Supabase çağrıları yalnızca data/
repository katmanında olur.

## 2. Klasör Yapısı
```
lib/
  app/                     # MiyhavApp, root widget, ProviderScope, MaterialApp.router
  core/
    config/                # AppConfig (uygulama adı, env, package id), flavors
    errors/                # AppError modeli, Türkçe hata dönüştürücü (ErrorMapper)
    networking/            # SupabaseClient sağlayıcı, bağlantı yardımcıları
    logging/               # Güvenli logger (hassas veri maskeleme)
    theme/                 # AppColors, AppTypography, AppSpacing, AppTheme
    routing/              # GoRouter yapılandırması, route guard (auth)
    utils/                 # Ortak yardımcılar, tarih/periyot yardımcıları
  features/
    auth/                  # kayıt, giriş, doğrulama, şifre
    profile/               # profil görüntüleme/düzenleme, gizlilik
    pet/                   # pet CRUD
    health/                # sağlık kayıtları, ekler, kilo
    reminder/              # tekrarlayan periyot, yaklaşan hatırlatmalar
    social/                # akış, post, beğeni, yorum, şikâyet
    friendship/            # istek, kabul, engelleme, ilişki çözümleyici
    discovery/             # arama + keşfet
    notifications/         # FCM token yönetimi, bildirim listesi
    pdf/                   # sağlık karnesi PDF
    settings/              # hesap, gizlilik, bildirim ayarları, hesap silme
  shared/
    models/                # ortak strongly-typed modeller
    widgets/               # ortak UI bileşenleri (design system)
    services/              # ortak servisler (entitlement, media storage soyutlaması)
  l10n/                    # Türkçe (varsayılan) + ileride İngilizce

supabase/
  migrations/              # versiyonlanmış SQL şema + RLS + RPC
  functions/               # Edge Functions (bildirim, hesap silme vb.)

test/                      # Flutter unit/widget testleri
integration_test/          # (gerekince) uçtan uca testler
```

Her feature yalnızca ihtiyacı olan katmanları içerir. Gerektiğinde
`presentation / application / domain / data` ayrımı kullanılır; küçük feature'lar
için zorlanmaz.

## 3. Katman Sorumlulukları
- **presentation:** Widget'lar, ekranlar, Riverpod tüketimi. State'i okur, aksiyon
  tetikler. Supabase bilmez.
- **application:** Riverpod notifier/controller; use-case orkestrasyonu, state.
- **domain:** Saf modeller ve saf iş kuralları (ör. periyot hesaplama). Bağımlılık yok.
- **data:** Repository implementasyonları; Supabase client burada. DTO ↔ model
  dönüşümü.

## 4. State & Routing
- **Riverpod:** Bağımlılık enjeksiyonu ve state. `SupabaseClient` bir provider'dan.
- **GoRouter:** Deklaratif routing + auth redirect guard (oturum yok → giriş).

## 5. Hata Yönetimi
Repository'ler ham hata fırlatmaz; `AppError` (kod + Türkçe kullanıcı mesajı)
döner. `ErrorMapper` Supabase/Postgrest/Auth/FCM hatalarını Türkçe mesaja çevirir.
UI ham hata veya stack trace göstermez. Ayrıntı: bkz. hata yönetimi kuralları
(CLAUDE.md) ve `RLS_SECURITY_MODEL.md`.

## 6. Medya Soyutlaması
`MediaStorageRepository` arayüzü; tek implementasyon `SupabaseMediaStorageRepository`.
Feature kodları doğrudan Storage SDK'ya bağımlı dağıtılmaz. Ayrıntı:
`MEDIA_STORAGE_PLAN.md`.

## 7. Paket Seçimi (planlanan, güncel/desteklenen sürümler)
- flutter_riverpod, go_router, supabase_flutter
- firebase_core, firebase_messaging (yalnızca push)
- pdf, printing (cihaz üstü PDF)
- image_picker, image (sıkıştırma/metadata temizliği), path_provider
- intl, flutter_localizations (l10n)
- freezed + json_serializable (immutable modeller) — gerçek ihtiyaç oldukça

> Deprecated paket kullanılmaz; sadece popülerlik için paket eklenmez. Kesin
> sürümler SETUP görevinde `pubspec.yaml`'a yazılır.

## 8. Environment
`--dart-define` ile dev/prod. Uygulamada yalnızca Supabase URL + anon key bulunur.
Service role key ve diğer sunucu sırları asla uygulamada olmaz. Ayrıntı:
`ENVIRONMENT_SETUP.md`.

## 9. Kaçınılanlar
Gereksiz interface, aşırı generic repository, service locator karmaşası, döngüsel
bağımlılık, business logic'in widget'a sızması, Supabase çağrısının ekrana dağılması.
