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

## D-004 · Enum stratejisi
MVP'de `text` + `check` constraint (Postgres enum yerine). Gerekçe: migration ile
kolay genişleme, daha az kilitlenme; ihtiyaç olursa enum'a geçilir.

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

## Retention notu
Şikâyet/moderasyon (reports, content_reports) verisi hesap silmede tamamen
silinmeyebilir (kötüye kullanım önleme). Kesin retention politikası ilgili
moderasyon görevinde netleştirilecek ve buraya yazılacak.
