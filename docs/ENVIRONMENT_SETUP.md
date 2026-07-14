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

## `.dart-define` Örnek Kullanım (dokümantasyon)
- dev: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- prod build: aynı anahtarlar production değerleriyle CI'da secret olarak verilir.
- Gerçek değerler depoda yok; yalnızca `.env.example` örnek anahtar adlarını gösterir.

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
