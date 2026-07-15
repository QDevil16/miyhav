# COMPLETED — Tamamlanan Görevler

## AUTH-001 · Kayıt + e-posta doğrulama + giriş/çıkış
- **Tarih:** 2026-07-15
- **Özet:** Supabase Auth ile tam kayıt/giriş/çıkış + e-posta doğrulama kapısı.
  Merkezî Türkçe hata dönüşümü `AuthErrorMapper` (+`AuthFailure`) — ham Supabase/ağ
  hataları kullanıcıya sızmaz (kayıtlı e-posta, hatalı giriş, doğrulanmamış e-posta,
  zayıf şifre, hız sınırı, ağ, genel). Saf `AuthValidators` (e-posta/şifre ≥8/
  şifre tekrar). `AuthRepository` arayüzü + `SupabaseAuthRepository`
  (signUp/signIn/signOut/resend, `onAuthStateChange`'ten `AuthStatus` türetir;
  emailConfirmedAt yoksa `unverified`). `authRepositoryProvider` +
  `pendingVerificationEmailProvider`. GoRouter auth kapısı (`AppRoutes`,
  `GoRouterRefreshStream`, `redirect`): doğrulanmamış → yalnızca `/verify-email`,
  oturumsuz → yalnızca auth ekranları, ana uygulamaya yalnızca `authenticated`.
  Ekranlar `LoginScreen`/`RegisterScreen`/`VerifyEmailScreen` ortak `AuthShell` ile
  (Miyhav tasarım sistemi: pixel avatar, PrimaryButton/SecondaryButton/AppTextField,
  tema renkleri). `MainShell` profil sekmesine "Çıkış Yap". Oturum kalıcılığı
  supabase_flutter otomatik. **profiles migration'ı değiştirilmedi; yeni migration
  oluşturulmadı** — mevcut `handle_new_user` trigger'ı profili kurar.
- **Kararlar:** D-018 (auth yönlendirme kapısı; doğrulama hem client redirect hem
  Dashboard "Confirm email" ile iki katmanlı).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **34 test All passed** (AuthErrorMapper 8, AuthValidators 8,
  auth akış yönlendirmesi + form doğrulama 5, mevcut config/tema/bootstrap/shell).
- **Test borcu:** OPS-002 — gerçek Supabase Auth uçtan uca (kayıt→doğrulama
  e-postası→giriş) canlı testi; bu ortamda egress engeli + cihaz yokluğu nedeniyle
  yapılamadı, client mantığı sahte repo ile test edildi. Ayrıca "Confirm email"
  Dashboard'da AÇIK olmalı (manuel).
- **Commit:** `feat: add Supabase Auth (register, verify email, login/logout)`
- **Durum:** done.

## SETUP-003 · Supabase istemci + ilk profiles migration
- **Tarih:** 2026-07-14
- **Özet:** `supabase_flutter` (2.16.0) eklendi. Merkezi, test edilebilir
  `SupabaseBootstrap.initialize()` — `AppConfig` URL/anon key kullanır, ham hata
  fırlatmaz, `SupabaseStatus{ready,missingConfig,error}` döner; `supabaseClientProvider`
  data katmanı için. Eksik/hatalı config'te kontrollü `SupabaseStatusScreen`
  (geliştirmede kurulum ipucu, üretimde sade mesaj). İlk migration
  `20260714093000_create_profiles.sql`: `profiles` (id = auth.users.id), enum'lar
  (profile_visibility/membership_type/account_status), generated `username_normalized`
  + case-insensitive unique index, format/uzunluk check'leri, `handle_new_user`
  (SECURITY DEFINER + `search_path=''`, idempotent `on conflict do nothing`,
  metadata'dan yalnızca display_name — güvenli), `profiles_before_update` (kritik
  alan değişmezliği + updated_at), deny-by-default RLS (yalnızca kendi profilini
  oku/güncelle; insert/delete kapalı). Kodlama bilmeyenler için Supabase kurulum
  adımları ENVIRONMENT_SETUP.md'ye eklendi.
- **Kararlar:** D-004 (enum stratejisi rafine), D-017 (kritik alan değişmezliği).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **14 test All passed** ✅. **Migration + RLS gerçek PostgreSQL
  16'da koşuldu** (yerel sunucu + Supabase benzeri auth shim): 6 RLS senaryosu
  (varsayılanlar, kendi/başka profil okuma, kritik alan değişmezliği, başkasını
  güncelleyememe, insert deny, case-insensitive username benzersizliği) TÜMÜ GEÇTİ.
- **Not:** Testler tam Supabase yerine yerel PG 16 + minimal auth shim (`auth.uid()`,
  `authenticated` rolü) ile koştu; migration SQL'i gerçek ve davranış doğrulandı.
- **Canlı doğrulama (2026-07-14):** Gerçek development Supabase projesi bağlandı
  (URL + publishable/anon key yalnızca gitignored `config/dev.local.json`'da).
  Migration gerçek projeye uygulandı; salt-okunur `supabase/checks/
  verify_remote_profiles.sql` Bölüm 1'in **tüm kontrolleri OK** döndü (profiles
  tablosu, 3 enum, generated kolon, default'lar, unique index, `handle_new_user`
  + `profiles_before_update` fonksiyon/trigger'ları, RLS aktif, 2 politika).
  Migration history baseline'ı açık borç olarak kaldı → **OPS-001**
  (`docs/SUPABASE_MIGRATION_BASELINE.md`). Cloud ortamının egress'i
  `*.supabase.co`'yu engellediğinden bağlantının in-app testi bu ortamda değil,
  kullanıcı cihazı/CI'da yapılır.
- **Commit:** `feat: add Supabase client bootstrap and profiles migration with RLS`
- **Durum:** done (şema canlı doğrulandı).

## DESIGN-001 · Tasarım sistemi (tema, font, bileşenler, alt navigasyon)
- **Tarih:** 2026-07-14
- **Özet:** Miyhav'ın özgün tasarım sistemi kuruldu. Token dosyaları
  (`lib/core/theme/`): renk paleti + açık/koyu `ColorScheme` (kahve/kakao/taupe/krem
  + soft coral), Jost tipografi ölçeği + `TextTheme`, spacing/radius/shadows/sizes,
  ve `AppTheme.light`/`dark`. **Jost fontu gerçekten bundle edildi**
  (`assets/fonts/Jost-*.ttf`, `pubspec.yaml`'da tanımlı; Google Fonts variable
  font'undan fonttools ile üretildi; Türkçe glyph doğrulandı; SIL OFL lisansı dahil).
  Reusable bileşenler (`lib/shared/widgets/`): PrimaryButton/SecondaryButton,
  AppTextField (şifre göster/gizle), AppCard (accent varyantı), AppAvatar,
  PetPixelAvatar (özgün pixel-art), EmptyState, LoadingState, MiyhavAppBar,
  MiyhavBottomNav. `MainShell` 5 geçici sekmeyle alt navigasyon iskeleti (gerçek
  feature/backend yok). Kök tema `MiyhavApp`'te bağlandı.
- **Kararlar:** D-015 (font instancing), D-016 (pixel-art asset sistemi).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **11 test All passed** (AppConfig, AppTheme, bileşenler,
  pixel avatar render, navigasyon geçişi) ✅.
- **Test borcu:** Canlı cihaz/emülatör görsel doğrulaması TD-001 kapsamında
  (Android SDK erişimi yok); widget ağacı render'ı testlerle doğrulandı.
- **Commit:** `feat: add Miyhav design system, Jost font and bottom nav skeleton`
- **Durum:** done.

## SETUP-002 · Merkezi config + package/bundle id + dev/prod
- **Tarih:** 2026-07-14
- **Özet:** Merkezi `AppConfig` oluşturuldu (appName/brandName "Miyhav",
  applicationId `com.miyhav.app`, `AppFlavor` enum, `displayTitle`, Supabase
  URL/anon key için `--dart-define` okuma). Kalıcı kimlik her iki platformda
  `com.miyhav.app` olarak uygulandı: Android namespace + applicationId, MainActivity
  `com.miyhav.app` paketine taşındı, manifest label "Miyhav"; iOS bundle id
  (+RunnerTests) ve CFBundleName güncellendi. Dev/prod için `config/dev.json` +
  `config/prod.json` (dart-define-from-file, secret içermez) ve `config/README.md`
  eklendi; `.gitignore`'a `config/*.local.json`. `MiyhavApp` başlığı
  `AppConfig.displayTitle`'a bağlandı.
- **Karar:** D-014 (dart-define tabanlı ortam; gradle/iOS flavor eklenmedi — basitlik).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → 4 test *All tests passed* (yeni AppConfig testleri dahil) ✅.
- **Test borcu:** Native build kimlik doğrulaması TD-001 kapsamında (Android SDK yok;
  iOS yalnızca Codemagic'te doğrulanır).
- **Commit:** `chore: set com.miyhav.app id and add central AppConfig with dev/prod`
- **Durum:** done.

## SETUP-001 · Flutter iskeleti (android + ios)
- **Tarih:** 2026-07-14
- **Özet:** `flutter create --platforms android,ios` ile proje oluşturuldu (yalnızca
  android + ios; web/masaüstü yok). Feature-first klasör iskeleti kuruldu
  (core/config, core/routing, core/theme, features/*, shared/*, l10n). `pubspec.yaml`
  temel bağımlılıklarla güncellendi: flutter_riverpod, go_router, intl,
  flutter_localizations. `MiyhavApp` (ConsumerWidget, MaterialApp.router, Türkçe
  varsayılan locale, geçici Material 3 tema) + `ProviderScope` + minimal GoRouter
  (geçici karşılama ekranı) eklendi. Varsayılan sayaç demo ve testi kaldırıldı.
- **Ortam kurulumu:** Flutter 3.44.6 stable (Dart 3.12.2) kuruldu (repo dışında,
  `/opt/flutter`).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → *All tests passed* ✅.
- **Test borcu:** TD-001 — Android debug build. Android SDK yok ve `dl.google.com`
  egress politikası ile engelli (403), gerçek `flutter build apk --debug`
  koşulamadı. Ayrıntı ve kapatma adımları: `docs/TASKS.md` → Test Borcu.
- **Commit:** `chore: scaffold Flutter app (android, ios) with Riverpod and GoRouter`
- **Durum:** done (Android build test borcu ile).

## PLAN-001 · Planlama ve dokümantasyon
- **Tarih:** 2026-07-14
- **Özet:** Şartname ve referans tasarım analiz edildi. Özgün tasarım yönü, teknik
  mimari, servis dağılımı, PostgreSQL tablo tasarımı, ilişkiler ve constraint
  yaklaşımı, RLS güvenlik modeli, profil gizlilik modeli, arama/keşif projeksiyonu,
  arkadaşlık RPC ve engelleme modeli, sağlık veri güvenliği, auth/e-posta, medya
  storage, FCM/Cron/Edge bildirim modeli, PDF modeli, dev/prod ortam, Codemagic
  iOS planı ve GitHub sürüm kontrol planı belirlendi. Tüm dokümanlar oluşturuldu;
  proje küçük görevlere bölündü; ilk görev SETUP-001 olarak belirlendi.
- **Çıktı dosyaları:** README.md, CLAUDE.md, docs/* (18 doküman), .gitignore,
  .env.example.
- **Test:** Yok (doküman/planlama görevi).
- **Commit:** `chore: initialize Miyhav project planning and documentation`
- **Durum:** done.
