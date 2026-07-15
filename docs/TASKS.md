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

## SETUP-003 · Supabase istemci bağlama + ilk migration altyapısı — **done**
- Amaç: supabase_flutter init; `supabase/` yapısı; ilk migration; bağlantı
  provider'ı; `handle_new_user` trigger + `profiles` tablosu.
- Yapıldı: `supabase_flutter ^2.8.0` (2.16.0 çözüldü). Merkezi
  `SupabaseBootstrap.initialize()` (AppConfig URL/anon key; ham hata fırlatmaz →
  `SupabaseStatus` döner) + `supabaseClientProvider`. Eksik config'te kontrollü
  `SupabaseStatusScreen` (dev'de kurulum ipucu). Migration
  `supabase/migrations/20260714093000_create_profiles.sql`: profiles + 3 enum +
  generated `username_normalized` + unique index + check'ler + `handle_new_user`
  (SECURITY DEFINER, idempotent, metadata'ya güvenmez) + `profiles_before_update`
  (kritik alan değişmezliği) + deny-by-default RLS (select/update own).
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ ·
  `flutter test` → **14 test** (bootstrap missingConfig/error dahil) ✅.
  **Migration + RLS gerçek Postgres 16'da koşuldu** (auth shim ile):
  `supabase/tests/profiles_rls_test.sql` → 6 senaryo TÜMÜ GEÇTİ.
- Manuel: Supabase projesi (URL + anon key) — kullanıcı (bkz. ENVIRONMENT_SETUP.md).
- **Canlı doğrulama (2026-07-14):** Gerçek development Supabase projesi bağlandı
  (URL + publishable/anon key → gitignored `config/dev.local.json`). Migration
  gerçek projeye uygulandı ve `supabase/checks/verify_remote_profiles.sql`
  Bölüm 1 kontrollerinin **tamamı OK** döndü (tablo, 3 enum, generated kolon,
  default'lar, unique index, 2 fonksiyon, 2 trigger, RLS aktif, 2 politika).
  Kalan: migration history baseline → **OPS-001** (bkz. Test Borcu). Cloud
  geliştirme ortamının egress'i `*.supabase.co`'yu engellediğinden bağlantının
  in-app canlı testi bu ortamda yapılamaz (kullanıcı cihazı/CI'da doğrulanır).
- Bağımlılık: SETUP-002.
- Durum: **done** (şema canlı doğrulandı; history baseline OPS-001'de).

## AUTH-001 · Kayıt + e-posta doğrulama + giriş/çıkış — **done**
- Amaç: Supabase Auth ile kayıt, giriş, çıkış, e-posta doğrulama; doğrulanmamış
  kullanıcı ana uygulamaya geçemez; ham hata yok → Türkçe.
- Yapıldı: `AuthErrorMapper` (+`AuthFailure`) merkezî Türkçe hata dönüşümü;
  `AuthValidators` (e-posta/şifre/şifre tekrar, saf + testli); `AuthRepository`
  arayüzü + `SupabaseAuthRepository` (signUp/signIn/signOut/resend; `AuthStatus`
  türetme); `authRepositoryProvider` + `pendingVerificationEmailProvider`;
  GoRouter auth kapısı (`refreshListenable` + `redirect`, `AppRoutes`);
  `LoginScreen`/`RegisterScreen`/`VerifyEmailScreen` + ortak `AuthShell`
  (Miyhav tasarım sistemi: PrimaryButton/SecondaryButton/AppTextField/pixel
  avatar); `MainShell` profil sekmesine "Çıkış Yap". Oturum kalıcılığı
  supabase_flutter ile otomatik. **profiles migration'ına DOKUNULMADI; yeni
  migration OLUŞTURULMADI** (mevcut `handle_new_user` trigger'ı profili kurar).
- Kararlar: D-018 (auth yönlendirme kapısı).
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ ·
  `flutter test` → **34 test All passed** (hata mapper, validators, auth
  yönlendirme akışı: oturumsuz→login, doğrulanmamış→verify, girişli→ana,
  boş form Türkçe hata, başarılı giriş→ana). Canlı Supabase auth (gerçek kayıt/
  doğrulama e-postası) bu ortamda test EDİLEMEDİ → bkz. Test Borcu OPS-002.
- Manuel (kullanıcı, Supabase Dashboard): **Authentication → Sign In / Providers →
  Email**: "Confirm email" **AÇIK** (doğrulama zorunlu); **URL Configuration →
  Site URL / Redirect URLs** uygulama/deep-link'e göre ayarlanır. Türkçe e-posta
  şablonları EMAIL-001'de.
- Bağımlılık: SETUP-003.
- Durum: **done** (canlı auth doğrulaması OPS-002'de).

## AUTH-002 · Şifre sıfırlama + deep link callback + e-posta değiştirme — **done**
- Amaç: Şifremi unuttum + şifre sıfırlama; mobil deep link callback (e-posta
  doğrulama + şifre sıfırlama) Android & iOS; e-posta değiştirme altyapısı; auth
  hata/loading durumlarının tamamlanması.
- Yapıldı: Merkezî callback URI'leri `AppConfig` (`loginCallbackUrl =
  com.miyhav.app://login-callback/`, `resetPasswordCallbackUrl =
  com.miyhav.app://reset-password/`). Repository: `sendPasswordReset`,
  `updatePassword`, `updateEmail`, `authEvents()` (AuthEventKind); `signUp`/
  `resend` artık `emailRedirectTo` ile deep link'i tetikler. `AuthRouterState`
  (status + **passwordRecovery** modu) → GoRouter redirect: kurtarma modunda
  yalnızca `/reset-password`. Ekranlar: `ForgotPasswordScreen`,
  `ResetPasswordScreen` (yeni şifre ≥8 + tekrar + Türkçe validasyon; başarıda
  oturum kapatılıp girişe döner — kurtarma oturumu normal giriş sanılmaz).
  Login'e "Şifremi unuttum". Native: Android intent-filter (manifest) + iOS
  CFBundleURLTypes (Info.plist). Deep link'i supabase_flutter (PKCE) işler;
  tekrar işlenme idempotent (recovery guard + declarative redirect).
  `PrimaryButton/SecondaryButton` uzun etiketlerde taşmayı önleyecek şekilde
  sağlamlaştırıldı.
- SQL/RLS etkisi: **yok** (yeni migration oluşturulmadı; profiles'a dokunulmadı).
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ ·
  `flutter test` → **43 test All passed** (kurtarma yönlendirmesi, yeni şifre
  validasyon + güncelle/çıkış, şifremi unuttum gönderimi, login→forgot navigasyon,
  callback URI'leri). Native deep link'in cihazda uçtan uca doğrulaması → OPS-004.
- Manuel: Supabase Dashboard **Redirect URLs** (bkz. görev sonu notu).
- Bağımlılık: AUTH-001.
- Durum: **done** (native deep link cihaz doğrulaması OPS-004'te).

## PROFILE-001 · Profil görüntüleme/düzenleme + username uniqueness — **done**
- Amaç: Kullanıcının yalnızca KENDİ profilini görüntülemesi/düzenlemesi (sosyal/
  arkadaş/keşfet/pet profili KAPSAM DIŞI).
- Yapıldı: `Profile` modeli + `ProfileVisibility` enum (wire↔Türkçe etiket/açıklama);
  `ProfileRepository` + `SupabaseProfileRepository` (fetchMyProfile/updateMyProfile;
  id her zaman auth oturumundan; `buildProfileUpdate` yalnızca düzenlenebilir alanlar);
  `profileRepositoryProvider` + `myProfileProvider` (auth değişince tazelenir);
  merkezî Türkçe hata `ProfileErrorMapper` (23505→"Bu kullanıcı adı zaten kullanılıyor.");
  `ProfileValidators` (username 3-30 [A-Za-z0-9_] opsiyonel, display≤60, bio≤160,
  city≤80). Ekranlar: `ProfileScreen` (MainShell profil sekmesi — DefaultProfileAvatar,
  ad, @kullanıcıadı/"Kullanıcı adı belirlenmedi", bio/şehir yalnızca varsa, gizlilik
  etiketi, Profili Düzenle, Çıkış Yap; loading/error+retry) ve `ProfileEditScreen`
  (5 alan + bio sayacı + gizlilik seçici; `/profile-edit`). `AppTextField`'a `maxLines`.
- Profil fotoğrafı: **upload YOK** (storage/seçici/R2 bağlanmadı); UI'da
  DefaultProfileAvatar; `profile_photo_path` update payload'una konmaz → korunur.
- SQL/RLS etkisi: **yok** (mevcut şema + RLS yeterli; yeni migration yok, profiles
  migration'ına dokunulmadı). Benzersizlik DB unique index ile; RLS yalnızca kendi
  satırını okut/güncelletir.
- Test yapıldı: `dart format` ✅ · `flutter analyze` (No issues) ✅ · `flutter test`
  → **66 test All passed** (model parse, gizlilik etiketleri, username/bio/city
  validasyon, buildProfileUpdate kritik alan hariç, 23505→Türkçe, loading, error+retry,
  repo yalnızca current id + provider tazeleme, düzenleme kaydı). Auth testleri korunur.
- Manuel: yok.
- Bağımlılık: AUTH-001.
- Durum: **done**.

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
- **OPS-001 · Uzak migration history baseline (SETUP-003 canlı):** Migration
  `20260714093000_create_profiles` uzak development DB'sine **SQL Editor**
  üzerinden uygulandı; bu yüzden `supabase_migrations.schema_migrations`
  history'si bu sürümü **içermiyor** (yerel migrations ↔ uzak history uyumsuz).
  Bu ortamın egress politikası `*.supabase.co`'yu engellediğinden CLI baseline'ı
  burada yapılamıyor. **Nasıl kapatılır:** (a) SALT OKUNUR ön doğrulama —
  `supabase/checks/verify_remote_profiles.sql` SQL Editor'da koşulur, Bölüm 1'in
  tüm satırları `OK`; (b) CLI erişimi olan makinede `supabase link --project-ref
  ckocodjkvwzqyyilbqli` → `supabase migration repair --status applied
  20260714093000` → `supabase migration list` (Local+Remote senkron) →
  (opsiyonel) `supabase db diff` (fark yok). **Kapatma koşulu:** `migration list`
  çıktısında sürüm hem Local hem Remote'ta görünür ve `db diff` fark üretmez.
  Ayrıntılı plan: `docs/SUPABASE_MIGRATION_BASELINE.md`. **Kural:** repair
  yapılmadan `supabase db push` çalıştırılmaz.
- **OPS-002 · Canlı Supabase Auth doğrulaması (AUTH-001):** Kayıt → doğrulama
  e-postası → doğrulama → giriş → çıkış akışının gerçek Supabase projesinde uçtan
  uca testi bu geliştirme ortamında yapılamadı (egress `*.supabase.co`'yu engelliyor
  + Android SDK/gerçek cihaz yok). Client mantığı ve yönlendirme widget testleriyle
  doğrulandı (sahte repo). **Nasıl kapatılır:** (a) Dashboard'da "Confirm email"
  AÇIK; (b) gerçek cihaz/emülatör veya CI'da `--dart-define-from-file=config/
  dev.local.json` ile uygulama çalıştırılıp gerçek e-posta ile kayıt/doğrulama/
  giriş/çıkış denenir; doğrulanmadan ana ekrana geçilemediği görülür.
- **OPS-004 · Native deep link uçtan uca (AUTH-002):** Android intent-filter ve
  iOS URL scheme (`com.miyhav.app://login-callback/`, `.../reset-password/`)
  eklendi; ancak bu ortamda Android SDK/gerçek cihaz olmadığından e-posta
  doğrulama ve şifre sıfırlama bağlantısının uygulamayı açması cihazda test
  edilemedi (client mantığı + yönlendirme widget testleriyle doğrulandı).
  **Nasıl kapatılır:** (a) Supabase Dashboard'da Redirect URL'ler eklenir; (b)
  gerçek cihaz/emülatörde kayıt → doğrulama linki → uygulama açılır → ana ekran;
  (c) şifre sıfırlama linki → yeni şifre ekranı açılır → güncelle → giriş.
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
**PRIVACY-001** (profil gizliliği + public_profiles view/RPC). Ayrı ve onaylı bir
adımda başlanacak; PROFILE-001 burada durur.
