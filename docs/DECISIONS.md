# DECISIONS — Mimari Kararlar (kısa)

Her karar: bağlam → seçim → gerekçe. Büyük değişiklik önerileri de buraya yazılır
ve onay beklenir.

## D-001 · Platform hedefleri
Yalnızca Android + iOS. Web/Windows/macOS/Linux yok. `flutter create --platforms android,ios`.
Gerekçe: şartname zorunluluğu; tek kod tabanı, mobil odak.

## D-002 · State & Routing
Riverpod + GoRouter. Gerekçe: güncel, bakımı süren, deklaratif, test edilebilir;
şartname zorunluluğu.

## D-003 · Backend
Supabase tek ana backend (Postgres/Auth/Storage/Realtime/Edge/Cron/RLS). Firebase
yalnızca FCM push. Gerekçe: servis sayısını sade tutma; şartname.

## D-004 · Enum stratejisi (rafine edildi — SETUP-003)
Kolon bazında karar: `profiles`'ın kapalı ve durağan kümeleri
(`profile_visibility`, `membership_type`, `account_status`) için **native Postgres
enum** kullanıldı (tip güvenliği; gerektiğinde `ALTER TYPE ADD VALUE` ile genişler).
Daha oynak/uzun kümeler (ör. `pets.species`, `health_records.record_type`) için
`text` + `check` tercih edilebilir. Gerekçe: en güvenli + duruma uygun seçim.

## D-017 · profiles kritik alan değişmezliği
`membership_type`, `account_status`, `id`, `created_at` normal kullanıcı update'inde
BEFORE UPDATE trigger (`profiles_before_update`) ile eski değerine sabitlenir;
`username_normalized` generated kolon (doğrudan set edilemez). Profil INSERT'i
authenticated'a açılmaz — yalnızca `handle_new_user` trigger'ı oluşturur. Üyelik/
durum değişimleri ileride ayrı güvenli SECURITY DEFINER RPC'lerle yapılacaktır.

## D-005 · Arama/keşif projeksiyonu
SECURITY INVOKER view (`public_profiles`) + SECURITY INVOKER RPC (`search_profiles`,
`discover_profiles`). Ayrı discovery projection tablosu MVP'de yok. Gerekçe:
güvenlik + sadelik + RLS uyumu; ayrı tablo senkron yükü getirir, gerçekten
gerekmedikçe eklenmez.

## D-006 · Arkadaşlık kabulü ve engelleme
Atomik RPC (`accept_friend_request`, `block_user` vb.) + unique/check constraint +
partial unique index (pending). friendships kanonik sıra (`user_one_id<user_two_id`).
Gerekçe: yarış durumu ve güvensiz çok adımlı client akışını önlemek.

## D-007 · Sağlık verisi mahremiyeti
health_* tabloları yalnızca owner (RLS). Ekler private bucket + kısa ömürlü signed
URL. Log/analytics/crash/push payload/public URL'de sağlık verisi yok. Gerekçe:
şartname; mahremiyet temel ilke.

## D-008 · Medya soyutlaması
`MediaStorageRepository` + tek `SupabaseMediaStorageRepository`. R2 yok. Gerekçe:
sağlayıcı bağımsızlığı, gelecekte migration görevi ile değiştirilebilir.

## D-009 · E-posta
MVP: Supabase Auth varsayılan e-posta (Türkçe şablon). Resend production'da ayrı
görev. Gerekçe: servis sadeliği; domain hazır olmadan Resend eklenmez.

## D-010 · Font
Jost (SIL OFL) — uygulama + PDF için bundled; Türkçe karakter desteği. Gerekçe:
referans atmosferi + açık lisans + Türkçe uyum.

## D-011 · Crash reporting
MVP'de Sentry vb. yok. Gerekçe: servis sadeliği; güvenli merkezi logger yeterli.
Production'da ihtiyaç olursa ayrı karar.

## D-012 · Ödeme / entitlement
MVP'de payment SDK yok. Merkezi entitlement service ile hazırlık (maxPets,
canExportPdf, ...). Varsayılan free sınırsız pet. Gerekçe: şartname.

## D-013 · Package name / bundle id (ONAYLANDI)
`com.miyhav.app` (Android package = iOS bundle id). **Kullanıcı onayladı (2026-07-14).**
SETUP-002'de bu değere sabitlenecek.

## D-014 · Dev/prod ortam yaklaşımı
`--dart-define` / `--dart-define-from-file` (config/dev.json, config/prod.json) +
merkezi `AppConfig` (AppFlavor enum). Android gradle product flavor'ları veya iOS
scheme/xcconfig ayrımı MVP'de eklenmedi. Gerekçe: basit, sürdürülebilir,
cross-platform aynı davranış, Windows'ta Xcode gerektirmez, `--flavor` zorunluluğu
getirmez. Tek uygulama kimliği `com.miyhav.app` her iki platformda; ortam ayrımı
Dart/runtime seviyesinde (`AppConfig.displayTitle` dev'de "Miyhav (Dev)"). İleride
dev/prod'un cihazda yan yana kurulabilmesi gerekirse app-id suffix'li gradle flavor
ayrı görevle eklenebilir.

## D-015 · Jost fontu bundle yöntemi
Google Fonts Jost variable font'undan `fonttools varLib.instancer` ile 4 statik
ağırlık (400/500/600/700) üretilip `assets/fonts/`'a konuldu; `pubspec.yaml` ile
tanımlandı. Gerekçe: çalışma zamanı font indirme yasak; statik ağırlıklar Flutter'da
öngörülebilir render verir. Türkçe glyph kapsamı doğrulandı. Lisans (SIL OFL)
`assets/fonts/Jost-OFL.txt` ile birlikte tutulur.

## D-016 · Pixel-art pet asset sistemi — **GEÇERSİZ (D-019 ile değiştirildi)**
~~Placeholder pet avatarları kod içi 12×12 pixel desenlerinden çizilirdi
(`PetPixelAvatar`).~~ Canlı testte pixel-art görünümü eski oyun estetiği verdiği
ve hedeflenen modern/premium kaliteye uymadığı için tamamen kaldırıldı. Yerine
D-019 (hazır ikon sistemi) geçti.

## D-019 · Hazır ikon tabanlı pet türü sistemi (elle çizim yerine)
Pet türleri için elle hayvan çizimi (CustomPainter/SVG/pixel/emoji) YAPILMAZ.
Bunun yerine hazır, profesyonel ve tanınabilir tek bir ikon ailesi kullanılır:
**Lucide** (`lucide_icons_flutter`, tek icon package; ince/tutarlı çizgi, ISC
lisans). Eşleme: cat→cat, dog→dog, bird→bird, rabbit→rabbit, fish→fish,
reptile→turtle, other→pawPrint. Merkezî widget `PetTypeIcon(type, size, selected)`:
yuvarlak sade zemin + ortada tür ikonu; seçili iken soft coral vurgu (ince coral
çerçeve + çok hafif coral zemin). Varsayılan kullanıcı profili `DefaultProfileAvatar`
(pastel coral yüzey + Lucide pati). Aynı `PetTypeIcon`, fotoğrafsız pet avatarı
(fallback) olarak da kullanılır. Gradient/3D/ağır gölge yok; Miyhav paletiyle uyumlu.
Gerekçe: birkaç kez denenen özgün çizim/illüstrasyon yaklaşımları (pixel, flat
silüet, sevimli yüz, line-art) yeterince premium/tanınabilir bulunmadı; hazır kaliteli
ikon seti temiz, tutarlı ve ilk bakışta anlaşılır sonuç verir. Tek paket sınırı korunur.

## D-018 · Auth yönlendirme kapısı (AUTH-001)
Oturum/doğrulama durumu tek bir `AuthStatus` (unauthenticated / unverified /
authenticated) ile modellenir; `AuthRepository` bunu Supabase
`onAuthStateChange`'ten türetir. GoRouter `refreshListenable` (auth stream köprüsü)
+ `redirect` ile: doğrulanmamış kullanıcı yalnızca `/verify-email`, oturumsuz
kullanıcı yalnızca `/login,/register,/verify-email` görebilir; ana uygulamaya
(`/`) yalnızca `authenticated` erişir. E-posta doğrulama zorunluluğu ayrıca
Supabase Dashboard'da **"Confirm email" AÇIK** olmasına bağlıdır (manuel ayar).
Gerekçe: "kullanıcı doğrulanmadan ana uygulamaya geçmesin" kuralını hem client
yönlendirmesi hem sunucu ayarıyla iki katmanlı güvence altına almak. Ham Supabase
hataları `AuthErrorMapper` ile merkezî Türkçe mesaja çevrilir (kural 6).

## D-020 · Mobil deep link auth callback (AUTH-002)
E-posta doğrulama ve şifre sıfırlama, mobil özel şema deep link'i ile döner
(`com.miyhav.app://login-callback/`, `com.miyhav.app://reset-password/`).
localhost/web/PWA/WebView KULLANILMAZ (Miyhav web değildir). URI'ler `AppConfig`'te
tek merkezden; Supabase `emailRedirectTo`/`redirectTo` bunları kullanır. Native:
Android `intent-filter` (manifest), iOS `CFBundleURLTypes` (Info.plist). Gelen
link'i supabase_flutter (PKCE) işler. Şifre kurtarma oturumu `AuthRouterState` ile
ayrı izlenir ve normal giriş sanılmaz: kurtarma modunda yalnızca yeni şifre ekranı
gösterilir, şifre güncellenince oturum kapatılır. Tekrar işlenme (duplicate deep
link) idempotenttir (recovery guard + declarative GoRouter redirect). Gerekçe:
şartname mobil-only; güvenli, öngörülebilir ve platformlar arası tutarlı callback.

## D-021 · Profil okuma/yazma modeli (PROFILE-001)
Kullanıcının kendi profili `ProfileRepository` (Supabase impl) üzerinden okunur/
güncellenir; UI'a Supabase istemcisi sızmaz. Güncelleme yalnızca düzenlenebilir
alanları içeren payload ile ve id her zaman auth oturumundan (`.eq('id', uid)`)
yapılır; kritik alanlar (membership_type, account_status, id, created_at,
username_normalized) payload'a hiç konmaz — DB'de BEFORE UPDATE trigger + RLS ile de
korunur. Kullanıcı adı benzersizliği yalnızca client ön kontrolüne bırakılmaz; asıl
güvence `username_normalized` unique index'idir, ihlal (23505) Türkçe mesaja çevrilir.
Profil satırı yoksa sahte profil üretilmez → "ulaşılamıyor" mesajı. Bu görev yeni
migration/RLS getirmez (mevcut şema yeterli). Profil fotoğrafı upload'u bu görevde
YOK (storage ayrı görevde); `profile_photo_path` korunur. Not: profile_visibility
yalnızca profilin kendi tercihidir; arama/keşif (discovery) görünürlüğü ayrı konudur.

## Retention notu
Şikâyet/moderasyon (reports, content_reports) verisi hesap silmede tamamen
silinmeyebilir (kötüye kullanım önleme). Kesin retention politikası ilgili
moderasyon görevinde netleştirilecek ve buraya yazılacak.
