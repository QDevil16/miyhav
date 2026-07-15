# COMPLETED — Tamamlanan Görevler

## PET-001 · Pet ekleme/düzenleme/silme (özel; yalnızca sahibe)
- **Tarih:** 2026-07-15
- **Özet:** Kullanıcı yalnızca kendi adına pet ekler/düzenler/siler; pet özel verisi
  yalnızca sahibe. **Yeni migration** `20260715140000_create_pets.sql` (mevcut
  migration'lara dokunulmadı): `pets` tablosu (owner_id FK profiles on delete cascade;
  name/species/breed/sex/birth_date/is_birth_date_estimated/color/current_weight/
  profile_photo_path/short_description/microchip_number/is_neutered; species+sex+uzunluk+
  ağırlık check'leri), `pets_before_update` trigger (owner_id/id/created_at değişmez),
  deny-by-default RLS (select/insert/update/delete yalnız `owner_id=auth.uid()`, insert
  WITH CHECK), owner index. Flutter: `Pet`/`PetSex`/`PetDraft`, `PetValidators`,
  `PetErrorMapper` (ham hata sızmaz), `PetRepository`+`SupabasePetRepository`
  (`buildPetWrite` owner_id/id hariç; owner_id insert'te auth oturumundan),
  `myPetsProvider`, `PetsScreen` (Petlerim: liste/boş/loading/error+retry) ve
  `PetFormScreen` (ekle/düzenle/sil onaylı; `/pet-form`). PetTypeIcon kullanıldı;
  foto upload/Storage/sağlık/sosyal YOK.
- **owner_id güvenliği:** insert'te owner_id yalnız `auth.uid()` (repo + RLS WITH CHECK);
  update'te owner_id payload'a KONMAZ + BEFORE UPDATE trigger eski değere sabitler →
  başka kullanıcıya devredilemez. RLS başkasının petini okutmaz/güncelletmez/sildirmez.
- **SQL/RLS testi (gerçekten koştu):** Yerel **PostgreSQL 16** `pets_rls_test.sql` 8
  senaryo → **TÜMÜ GEÇTİ** (owner_id spoof insert reddi, cross-user read/update/delete
  reddi, owner_id devri engeli, species check, sahip CRUD).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **81 test All passed** (Pet parse, PetSex, validatorlar,
  buildPetWrite owner_id-hariç, liste loading/empty/data/error+retry, form create+delete).
- **Test borcu:** OPS-006 — pets migration'ının canlı Supabase'e uygulanması.
- **Commit:** `feat: add pets table, RLS and own-pet CRUD (PET-001)`
- **Durum:** done (canlıya uygulama OPS-006).

## PRIVACY-001 · Profil gizliliği + güvenli keşif projeksiyonu (RLS)
- **Tarih:** 2026-07-15
- **Özet:** 3 seviyeli gizlilik modeli backend+RLS seviyesinde uygulandı (UI/arkadaşlık/
  keşfet ekranı kapsam dışı). **Yeni migration** `20260715120000_privacy_discovery.sql`
  (mevcut `20260714093000_create_profiles.sql` DEĞİŞTİRİLMEDİ): full-profile SELECT'e
  `profiles_select_public` (public+aktif → aktif authenticated okur; friends_only/private
  yalnız sahibi), `is_account_active(uuid)` güvenli helper, **SECURITY DEFINER** keşif
  projeksiyonu `public_profiles` view (yalnız 5 güvenli kolon: id/username/display_name/
  profile_photo_path/profile_visibility; filtre `visibility IN (public,friends_only) AND
  account_status='active'`), `search_profiles(text)` SECURITY DEFINER RPC (username prefix,
  self hariç, private/inaktif hariç, limit 30) + `username_normalized text_pattern_ops`
  index. anon revoke, authenticated grant; deny-by-default + before_update trigger +
  INSERT/DELETE kapalılığı korundu; RLS gevşetilmedi; service_role kullanılmadı.
- **Ürün kuralı doğrulandı:** private aramada/keşifte bulunmaz; public+friends_only
  bulunabilir; ama **"bulunabilirlik ≠ tam profil"** — friends_only tam profili arkadaş
  olmayana kapalı. friends_only *tam profil (arkadaşa)* erişimi friendships altyapısı
  gerektirdiğinden **ertelendi (deny-by-default)** → FRIEND görevi (D-022).
- **Flutter temeli (UI YOK):** `DiscoveryProfile` modeli + `DiscoveryRepository`/
  `SupabaseDiscoveryRepository` (`search_profiles` RPC) + provider — sonraki DISCOVERY
  görevleri için güvenli veri erişim temeli.
- **Kararlar:** D-005 rafine → **D-022** (keşif projeksiyonu neden SECURITY DEFINER;
  SECURITY INVOKER view friends_only'i gösterirken tam profili sızdırırdı — Firestore
  hatası). `docs/PRIVACY_MATRIX.md` uygulanan davranışla hizalandı.
- **SQL/RLS testi (gerçekten koştu):** Yerel **PostgreSQL 16** üzerinde
  `run_local_tests.sh` ile shim + iki migration + `profiles_rls_test.sql` +
  `privacy_rls_test.sql` → **profiles + PRIVACY-001 (16 senaryo) TÜMÜ GEÇTİ**. Flutter:
  `dart format` ✅ · `flutter analyze` → *No issues found* ✅ · `flutter test` →
  **68 test All passed**.
- **Canlı doğrulama (2026-07-15):** `20260715120000_privacy_discovery.sql` gerçek
  Supabase development projesine SQL Editor ile uygulandı ve doğrulandı: `public_profiles`
  view, `search_profiles` + `is_account_active` fonksiyonları, `profiles_select_public`
  policy mevcut; profiles'ta RLS açık. Wildcard/LIKE kaçırma güvenlik düzeltmesi
  commit `7016215`. Migration history baseline (bu sürüm + 20260714093000) → OPS-001.
- **Test borcu:** OPS-001 — uzak migration history baseline (iki sürüm birlikte;
  repair ile işaretlenecek, canlıda zaten uygulanmış olduğundan `db push` YOK).
- **Commit:** `feat: add profile privacy RLS and secure discovery projection (PRIVACY-001)`
  (+ güvenlik düzeltmesi `7016215`).
- **Durum:** done (canlı doğrulandı).

## PROFILE-001 · Kendi profil görüntüleme/düzenleme + username uniqueness
- **Tarih:** 2026-07-15
- **Özet:** Kullanıcının yalnızca kendi profilini görüntülemesi/düzenlemesi tamamlandı
  (sosyal/arkadaş/keşfet/pet profili kapsam dışı). `Profile` modeli + `ProfileVisibility`
  enum (private/friends_only/public ↔ Sadece Ben/Sadece Arkadaşlar/Herkese Açık +
  kısa açıklamalar). Veri katmanı: `ProfileRepository` arayüzü + `SupabaseProfileRepository`
  (fetchMyProfile/updateMyProfile; id daima auth oturumundan `.eq('id', uid)`; saf
  `buildProfileUpdate` yalnızca düzenlenebilir alanlar). Riverpod: `profileRepositoryProvider`,
  `myProfileProvider` (auth durumu değişince tazelenir), güncelleme sonrası `invalidate`.
  Merkezî Türkçe hata `ProfileErrorMapper` (PostgREST 23505 → "Bu kullanıcı adı zaten
  kullanılıyor.", ham hata sızmaz). `ProfileValidators` (username 3-30 [A-Za-z0-9_]
  opsiyonel, Türkçe/boşluk yok; display≤60; bio≤160; city≤80; trim). Ekranlar:
  `ProfileScreen` (DefaultProfileAvatar, görünen ad/"İsim eklenmemiş", @kullanıcıadı/
  "Kullanıcı adı belirlenmedi", bio+şehir yalnızca doluysa, gizlilik etiketi, Profili
  Düzenle, Çıkış Yap; loading + hata/retry — sahte profil üretmez, "Profil bilgilerine
  şu anda ulaşılamıyor."), `ProfileEditScreen` (5 alan + canlı bio sayacı + gizlilik
  seçici, Türkçe validasyon/loading/başarı geri bildirimi). `AppTextField`'a `maxLines`
  eklendi; MainShell profil sekmesi gerçek profile bağlandı; `/profile-edit` rotası.
  Tasarım sistemi (Jost, krem/taupe/cacao/coral, AppCard/Buttons/AppTextField,
  DefaultProfileAvatar) korundu; pixel-art/hayvan çizimi/gradient yok.
- **Profil fotoğrafı:** upload sistemi kurulmadı (storage/seçici/R2 bağlanmadı);
  `profile_photo_path` update payload'una konmaz → mevcut değer korunur.
- **Kararlar:** D-021 (profil okuma/yazma modeli).
- **SQL/RLS:** değişmedi; yeni migration YOK (mevcut şema + RLS yeterli — benzersizlik
  DB unique index, RLS yalnızca kendi satırı select/update).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **66 test All passed** (model parse, gizlilik etiketleri 3, username
  validasyon 6, bio/city/display uzunluk, buildProfileUpdate kritik-alan-hariç, 23505→
  Türkçe + ağ/genel, loading, error+retry, repo current-id + provider tazeleme, düzenleme
  kaydı; mevcut auth/tema/config testleri korunur).
- **Commit:** `feat: add own-profile view and edit (PROFILE-001)`
- **Durum:** done.

## AUTH-002 · Şifre sıfırlama + mobil deep link callback + e-posta değiştirme
- **Tarih:** 2026-07-15
- **Özet:** Şifremi unuttum → şifre sıfırlama akışı ve mobil deep link callback'leri
  (e-posta doğrulama + şifre sıfırlama) Android & iOS için eklendi. Merkezî callback
  URI'leri `AppConfig` (`loginCallbackUrl`, `resetPasswordCallbackUrl` =
  `com.miyhav.app://login-callback/` ve `.../reset-password/`). `AuthRepository`
  genişletildi: `sendPasswordReset`, `updatePassword`, `updateEmail`, `authEvents()`
  (AuthEventKind — passwordRecovery dahil); `signUp`/`resend` artık `emailRedirectTo`
  ile uygulamayı deep link'le açar. `AuthRouterState` (ChangeNotifier) oturum durumu
  + **passwordRecovery** modunu izler; GoRouter redirect kurtarma modunda yalnızca
  `/reset-password` gösterir (kurtarma oturumu normal giriş sanılmaz; şifre
  güncellenince oturum kapatılır → girişe döner). Yeni ekranlar:
  `ForgotPasswordScreen` (e-posta → bağlantı gönderildi durumu),
  `ResetPasswordScreen` (yeni şifre ≥8 + tekrar + Türkçe validasyon, loading, Türkçe
  başarı geri bildirimi). Login'e "Şifremi unuttum" bağlantısı. Native yapılandırma:
  Android `AndroidManifest.xml` intent-filter (VIEW/BROWSABLE, scheme com.miyhav.app,
  host login-callback + reset-password), iOS `Info.plist` CFBundleURLTypes. Deep
  link'i supabase_flutter (PKCE) işler; tekrar işlenme idempotent. `PrimaryButton`/
  `SecondaryButton` uzun etiket taşmasına karşı sağlamlaştırıldı. Ham hata yok →
  Türkçe (`AuthErrorMapper`). Web/localhost/PWA/WebView eklenmedi; profiles
  migration'ına dokunulmadı, yeni migration oluşturulmadı.
- **Kararlar:** D-020 (mobil deep link auth callback).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **43 test All passed** (passwordRecovery deep link yönlendirmesi,
  yeni şifre validasyon + updatePassword/signOut, şifremi unuttum gönderimi,
  login→forgot navigasyon, callback URI doğrulaması; mevcut auth/tema/config testleri).
- **Test borcu:** OPS-004 — native deep link'in gerçek cihazda uçtan uca doğrulaması
  (bu ortamda Android SDK/cihaz yok).
- **Commit:** `feat: add password reset and mobile deep link auth callbacks`
- **Durum:** done.

## DESIGN-002 · Pet türü görselleri: hazır ikon sistemine geçiş
- **Tarih:** 2026-07-15
- **Özet:** Elle çizilen pet görselleri (önce pixel-art, ardından denenen özgün
  illüstrasyon/line-art yaklaşımları) yeterince premium/tanınabilir bulunmadığı için
  tamamen kaldırıldı. Yerine hazır, profesyonel ve tanınabilir tek bir ikon ailesi
  (**Lucide**, `lucide_icons_flutter` — tek icon package, ince/tutarlı çizgi) kullanıldı.
  Silinen: `pet_pixel_avatar.dart` ve tüm `CustomPainter` hayvan çizim kodu. Yeni:
  `pet_type_icon.dart` — `PetType` (cat/dog/bird/rabbit/fish/reptile/other),
  `petTypeFromSpecies`, `petTypeLabel` (Türkçe), `petTypeIconData` (tür→Lucide ikon:
  reptile→turtle, other→pawPrint), ve merkezî `PetTypeIcon(type, size, selected)`
  (yuvarlak sade zemin; seçili iken ince coral çerçeve + çok hafif coral zemin +
  belirgin ikon). `default_profile_avatar.dart` sadeleştirildi: pastel coral yüzey +
  Lucide pati (custom painter kaldırıldı). Ana ekran "Türler" bölümü
  (`_PetTypeGallery`/`_PetTypeTile`) `PetTypeIcon`'un seçili durumunu kullanır +
  Türkçe etiket. Hero ve `app_avatar.dart` yorumu güncellendi. Aynı `PetTypeIcon`
  fotoğrafsız pet avatarı (fallback) olarak da kullanılır. Görsel çıktı (Lucide fontu
  teste yüklenerek) render edilip doğrulandı: 7 tür + profil ilk bakışta tanınıyor.
- **Kararlar:** D-016 geçersiz kılındı; D-019 hazır ikon sistemi olarak yeniden yazıldı.
- **Bağımlılık:** `lucide_icons_flutter` (tek yeni paket; ISC lisans, Flutter uyumlu).
- **Test yapıldı:** `dart format` ✅ · `flutter analyze` → *No issues found* ✅ ·
  `flutter test` → **37 test All passed** (PetTypeIcon tür→ikon eşlemesi + seçili
  vurgu, DefaultProfileAvatar, petTypeFromSpecies + petTypeLabel; mevcut auth/config/
  tema testleri korunur).
- **Temizlik:** lib/test'te pixel/PetPixelAvatar/PetTypeAvatar/PetIllustrationPainter/
  CustomPainter hayvan çizim referansı kalmadı; UI_DESIGN_SYSTEM.md + DECISIONS.md güncel.
- **Commit:** `feat: use Lucide icon system for pet types and default avatar`
- **Durum:** done.

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
