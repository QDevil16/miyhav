# COMPLETED — Tamamlanan Görevler

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
