# ENVIRONMENT_SETUP — Ortam ve Gizli Değerler

## Ortamlar
- **Development** ve **Production** ayrı.
- Yaklaşım: `--dart-define` (veya `--dart-define-from-file` ile JSON). Merkezi
  `AppConfig` değerleri okur.

## Uygulamada Bulunabilecekler (kabul edilebilir)
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Uygulamada KESİNLİKLE Bulunmayacaklar
Supabase service role key · PostgreSQL şifresi · Resend API key · FCM service
account · Firebase Admin credentials · Cloudflare R2 secret · Apple private key
(.p8) · Android keystore şifresi · Codemagic secret.

Bunlar yalnızca sunucu (Edge Function / Supabase secret) veya CI (Codemagic
environment variable group / secret) tarafında tutulur.

## `--dart-define` Kullanımı (uygulandı: SETUP-002)
Ortam değerleri `config/dev.json` ve `config/prod.json` içinden
`--dart-define-from-file` ile verilir; `AppConfig` okur.
- dev: `flutter run --dart-define-from-file=config/dev.json`
- prod: `flutter build apk --release --dart-define-from-file=config/prod.json`
- `config/*.json` yalnızca public değer taşır (APP_ENV + SETUP-003'te Supabase
  URL/anon key). Yerel/gizli denemeler `config/*.local.json` (gitignored).
- CI'da (Codemagic) değerler secret env olarak da geçilebilir.
- Ayrıntı: `config/README.md`.

## `.env.example`
Gerçek secret İÇERMEZ; yalnızca anahtar isimleri ve boş/örnek değerler. Depoya
`.env.example` girer; `.env` girmez.

## .gitignore Kapsamı
Flutter/Dart build çıktıları, `.env` ve gerçek env dosyaları, Android keystore ve
`key.properties`, iOS/Apple sertifika ve `.p8`, Firebase yapılandırma dosyaları
(google-services.json / GoogleService-Info.plist — SETUP'ta karar/örnek),
Supabase yerel gizli dosyaları, IDE/OS geçici dosyaları.

## Manuel İşlemler (ilgili görevde, basit Türkçe)
Supabase projesi oluşturma → URL + anon key alma; FCM projesi; Codemagic env
grupları; Apple/Google hesap işlemleri. Bu değerler geldikçe güvenli şekilde
(dart-define / CI secret) bağlanır; koda yazılmaz.
