# config/ — Ortam yapılandırması

Bu klasördeki dosyalar `--dart-define-from-file` ile kullanılır ve dev/prod
ortamlarını basit tutar. Değerler `AppConfig` (lib/core/config/app_config.dart)
tarafından okunur.

## Çalıştırma
```
# Geliştirme
flutter run --dart-define-from-file=config/dev.json

# Üretim (release)
flutter build apk   --release --dart-define-from-file=config/prod.json
flutter build ipa   --release --dart-define-from-file=config/prod.json   # Codemagic (macOS)
```

## Güvenlik
- `dev.json` ve `prod.json` yalnızca **public** değerleri taşır: `APP_ENV` ve
  (SETUP-003'te doldurulacak) Supabase **URL** + **anon key**. Bunlar mobil
  uygulamada bulunması kabul edilebilir değerlerdir.
- **Service role key, PostgreSQL şifresi, FCM service account, Apple/Android
  imzalama sırları bu dosyalara KONMAZ.** Onlar yalnızca sunucu (Edge Function/
  Supabase secret) veya CI (Codemagic secret) tarafında tutulur.
- Yerel/kişisel değerleri denemek isterseniz `config/*.local.json` adında bir dosya
  kullanın; bu dosyalar `.gitignore` ile depoya girmez.
