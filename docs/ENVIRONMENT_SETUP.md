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

---

## Supabase Projesi Oluşturma (kodlama bilmeyenler için)
Aşağıdaki adımlar bir kez yapılır. Sonuçta bize **iki değer** lazım:
**Project URL** ve **anon (public) key**. Bunlar gizli sır değildir; uygulamada
bulunabilir. (Service role / secret anahtarı ASLA vermeyin, kullanılmaz.)

1. Tarayıcıda **https://supabase.com** adresine gidin, **Sign in** ile giriş yapın
   (GitHub hesabıyla giriş en kolayı). Hesabınız yoksa ücretsiz oluşturun.
2. Açılan panelde yeşil **New project** düğmesine basın.
3. Formu doldurun:
   - **Name:** Miyhav
   - **Database Password:** Güçlü bir şifre girin ve bir yere **kaydedin**
     (bu şifreyi uygulamaya yazmayacağız; yalnızca sizin için).
   - **Region:** Size en yakın bölge (ör. Frankfurt / EU Central).
4. **Create new project** deyin. Kurulum 1–2 dakika sürebilir; bekleyin.
5. Sol menüde **Settings** (dişli ikon) → **API** bölümüne girin.
6. Şu iki değeri kopyalayın:
   - **Project URL** (ör. `https://xxxx.supabase.co`)
   - **anon public** anahtarı (Project API keys altında; "anon" yazan uzun metin).
7. Bu iki değeri bana iletin **veya** `config/dev.json` dosyasındaki
   `SUPABASE_URL` ve `SUPABASE_ANON_KEY` alanlarına yapıştırın. (Gerçek değerleri
   GitHub'a göndermiyoruz; yerelde denemek için `config/dev.local.json` da
   kullanılabilir — bu dosya depoya girmez.)

**Başarı kontrolü:** Değerler girildikten sonra uygulama açılışta "Kurulum
gerekli" ekranı yerine ana ekranı gösterirse bağlantı hazırdır. Değerler eksikse
uygulama çökmez; anlaşılır bir kurulum ekranı gösterir.

> Not: Bu görevde (SETUP-003) yalnızca istemci altyapısı ve `profiles` migration'ı
> hazırlandı. Migration'ın Supabase projesine uygulanması (Supabase CLI ile
> `supabase db push` veya SQL editöründen çalıştırma) ayrı bir adımdır ve gerçek
> proje bağlandıktan sonra yapılır.
