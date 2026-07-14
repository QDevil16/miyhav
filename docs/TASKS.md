# TASKS — Miyhav Görev Planı

Görevler küçük, bağımsız ve test edilebilir. Aynı anda tek görev uygulanır; biten
görevden sonra DUR. ~300 satırdan fazla yeni kod gerektiren görev alt görevlere
bölünür. Durumlar: `todo` · `in_progress` · `done` · `blocked`.

## Bağımlılık Sırası (özet)
PLAN-001 → SETUP-001 → SETUP-002 → DESIGN-001 → SETUP-003 (Supabase bağlama) →
AUTH-001..002 → PROFILE-001 → PRIVACY-001 → PET-001..002 → FRIEND-001..003 →
DISCOVERY-001 → BLOCK-001 → SOCIAL-001..003 → HEALTH-001..003 → REMINDER-001 →
NOTIFICATION-001..002 → PDF-001..002 → MEDIA-001 → SECURITY-001 → EMAIL-001 →
ANDROID-001 → IOS-001 → RELEASE-001.

---

## PLAN-001 · Planlama ve dokümantasyon — **done**
- Amaç: Şartname + referans analizi; mimari, DB, RLS, gizlilik, bildirim, PDF, iOS,
  GitHub planı; tüm dokümanlar; görev listesi; git init + .gitignore + ilk commit.
- Kapsam dışı: feature kodu, servis bağlama, migration uygulama.
- Kabul: dokümanlar oluşturuldu; .gitignore + .env.example var; commit atıldı.
- Test: yok (doküman görevi).
- Manuel: Package name onayı (P-001) — SETUP-002 için beklemede.
- Durum: **done**.

## SETUP-001 · Flutter iskeleti (android+ios) — **done**
- Amaç: `flutter create --platforms android,ios`; klasör iskeleti (core/features/
  shared/l10n); temel `pubspec.yaml` (riverpod, go_router, intl, flutter_localizations);
  `MiyhavApp` + ProviderScope + boş router; `dart format`, `flutter analyze`,
  `flutter test` yeşil.
- Kapsam dışı: Supabase/Firebase bağlama, feature ekranları, tema detayları.
- Değişti: proje kökü, `lib/`, `pubspec.yaml`, `analysis_options.yaml`, `android/`,
  `ios/`, `test/`.
- SQL/RLS etkisi: yok.
- Kabul: proje derlenir; analyze temiz. **Android debug build — bkz. Test Borcu.**
- Test yapıldı: `dart format` ✅, `flutter analyze` (No issues found) ✅,
  `flutter test` (All tests passed) ✅.
- Manuel: yok.
- Bağımlılık: PLAN-001.
- Durum: **done** (Android build test borcu ile).

## SETUP-002 · Merkezi config + package/bundle id + flavors — **done**
- Amaç: `AppConfig` (uygulama adı "Miyhav", marka, env), dev/prod dart-define,
  package name + bundle id = `com.miyhav.app` (onaylandı, D-013).
- Yapıldı: `lib/core/config/app_config.dart` (appName/brandName/applicationId,
  AppFlavor enum, displayTitle, Supabase URL/anon key define'ları). Android
  namespace + applicationId = `com.miyhav.app`, MainActivity `com.miyhav.app`
  paketine taşındı, manifest label "Miyhav". iOS bundle id (+RunnerTests) =
  `com.miyhav.app`, CFBundleName "Miyhav". `config/dev.json` + `config/prod.json`
  (dart-define-from-file, secret yok) + `config/README.md`. `.gitignore`'a
  `config/*.local.json`. `MiyhavApp` başlığı `AppConfig.displayTitle`.
- Yaklaşım kararı: D-014 (dart-define; gradle/iOS flavor eklenmedi).
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ ·
  `flutter test` (4 test, AppConfig testleri dahil) ✅.
- Test borcu: Android/iOS native build kimlik değişikliğinin derlenme doğrulaması
  TD-001 kapsamında (SDK/erişim yok). iOS build yalnızca Codemagic'te doğrulanabilir.
- Manuel: yok.
- Bağımlılık: SETUP-001.
- Durum: **done**.

## DESIGN-001 · Tasarım sistemi (tema) — **done**
- Amaç: AppColors/Typography/Spacing/Radius/Shadows/Sizes; Jost fontu bundle;
  Material 3 açık/koyu tema; çekirdek bileşenler; özgün pixel-art pet asset sistemi;
  alt navigasyon iskeleti.
- Yapıldı: 7 token dosyası + AppTheme; Jost 4 statik ağırlık bundle (fonttools);
  9 reusable widget (button/text field/card/avatar/pet pixel avatar/empty/loading/
  app bar/bottom nav); `MainShell` 5 sekme; `PetPixelAvatar` (CustomPainter, 12×12).
- Kapsam dışı (uygulanmadı): gerçek feature logic / backend / ekstra platform.
- Kararlar: D-015 (font), D-016 (pixel-art).
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ ·
  `flutter test` → **11 test All passed** (tema, bileşenler, pixel avatar render,
  navigasyon geçişi) ✅.
- Test borcu: cihaz/emülatör üzerinde canlı görsel doğrulama TD-001 kapsamında
  (Android SDK yok). Widget ağacında render doğrulandı.
- Manuel: yok.
- Bağımlılık: SETUP-001.
- Durum: **done**.

## SETUP-003 · Supabase istemci bağlama + ilk migration altyapısı — todo
- Amaç: supabase_flutter init; `supabase/` yapısı; boş/temel migration; bağlantı
  provider'ı; `handle_new_user` trigger + `profiles` tablosu ilk migration.
- Manuel: Supabase projesi (URL + anon key) — kullanıcı.
- Bağımlılık: SETUP-002.

## AUTH-001 · Kayıt + e-posta doğrulama + giriş/çıkış — todo
## AUTH-002 · Şifre sıfırlama/değiştirme + e-posta değiştirme + Türkçe hata — todo
- Bağımlılık: SETUP-003.

## PROFILE-001 · Profil görüntüleme/düzenleme + username uniqueness — todo
- İçerik: profiles CRUD (kritik alanlar hariç), username_normalized unique, foto.
- Bağımlılık: AUTH-001.

## PRIVACY-001 · Profil gizliliği + public_profiles view/RPC — todo
- İçerik: profile_visibility, güvenli projeksiyon, RLS politikaları.
- Bağımlılık: PROFILE-001.

## PET-001 · Pet ekleme/düzenleme/silme (özel alanlar) — todo
## PET-002 · Sosyal pet görünümü (pet_public_view) — todo
- Bağımlılık: PROFILE-001.

## FRIEND-001 · friend_requests + gönder/iptal (RPC + constraint) — todo
## FRIEND-002 · Kabul/ret + friendships (atomik RPC) — todo
## FRIEND-003 · İlişki çözümleyici + istek/arkadaş listeleri — todo
- Bağımlılık: PRIVACY-001.

## DISCOVERY-001 · Arama + Keşfet (search/discover RPC) — todo
- Bağımlılık: PRIVACY-001, FRIEND-003.

## BLOCK-001 · Engelleme/engel kaldırma (atomik RPC) + filtreleme — todo
- Bağımlılık: FRIEND-002, DISCOVERY-001.

## SOCIAL-001 · Post oluştur/sil + akış (görünürlük birleşimi) — todo
## SOCIAL-002 · Beğeni/beğeni kaldırma + yorum/yorum silme — todo
## SOCIAL-003 · İçerik şikâyeti + moderation_status — todo
- Bağımlılık: PET-002, BLOCK-001, MEDIA-001.

## HEALTH-001 · health_records CRUD (RLS owner-only) — todo
## HEALTH-002 · Kilo ölçümleri + sağlık geçmişi görünümü — todo
## HEALTH-003 · health_attachments (private bucket + signed URL) — todo
- Bağımlılık: PET-001.

## REMINDER-001 · Periyot/next_due_date domain service (saf, testli) — todo
- İçerik: kapsamlı unit testler (ay sonları, Şubat, artık yıl, ofsetler).
- Bağımlılık: HEALTH-001.

## NOTIFICATION-001 · device_tokens + FCM entegrasyon (client) — todo
## NOTIFICATION-002 · Cron + Edge Function send-due-reminders (idempotent) — todo
- Manuel: FCM projesi — kullanıcı.
- Bağımlılık: REMINDER-001.

## PDF-001 · Sağlık karnesi PDF oluşturma/ön izleme — todo
## PDF-002 · PDF ayarları (mikroçip/sahip adı) + paylaş/kaydet/yazdır — todo
- Bağımlılık: HEALTH-002.

## MEDIA-001 · MediaStorageRepository + Supabase impl (upload/sıkıştırma/thumbnail) — todo
- Bağımlılık: SETUP-003.

## SECURITY-001 · RLS test paketi (Supabase CLI/Docker) — todo
- İçerik: TEST_STRATEGY zorunlu senaryoları gerçek çalıştırma.
- Bağımlılık: BLOCK-001, HEALTH-001.

## EMAIL-001 · Türkçe Auth e-posta şablonları — todo
- (EMAIL-002 Resend production — ertelendi.)

## ANDROID-001 · Android release yapılandırma + ikon/splash — todo
## IOS-001 · codemagic.yaml + iOS cloud build/signing — todo
## RELEASE-001 · Mağaza dokümanları + Data Safety/App Privacy + yayın hazırlığı — todo
- Manuel: Apple/Google/Codemagic hesap işlemleri — kullanıcı.

---

## Test Borcu
- **TD-001 · Android debug build (SETUP-001):** Bu geliştirme ortamında Android SDK
  yok ve `dl.google.com` organizasyon egress politikası ile engelli (403), bu yüzden
  `sdkmanager`/`build-tools` indirilemiyor ve gerçek `flutter build apk --debug`
  koşulamadı. Flutter iskeleti derlenebilir durumda (analyze + test yeşil); yalnızca
  native APK derlemesi doğrulanamadı. **Nasıl kapatılır:** (a) Android SDK'nın
  erişilebildiği bir ortam/CI (ör. Codemagic Android workflow) veya `dl.google.com`
  izinli bir ağ; (b) `sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"`
  kurulumu + lisans kabulü; (c) `flutter build apk --debug` çıktısının doğrulanması.
  ANDROID-001 görevinde veya ortam açıldığında kapatılacak.

## Sonraki Görev
**SETUP-003** (Supabase istemci bağlama + ilk migration altyapısı: profiles tablosu
+ `handle_new_user` trigger). Ayrı ve onaylı bir adımda başlanacak; DESIGN-001 durur.
