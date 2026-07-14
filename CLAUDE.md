# CLAUDE.md — Miyhav Çalışma Kuralları

Bu dosya, Miyhav projesinde çalışan geliştirici (Claude) için kalıcı kurallardır.
**Her göreve başlamadan önce bu dosya okunur.** Uzun tarama yapılmaz; yalnızca
aktif görevle ilgili dokümanlar ve dosyalar incelenir.

## Proje Kimliği
- **Ürün adı:** Miyhav
- **Tür:** Pet takip + pet sağlık + pet sosyalleşme mobil uygulaması
- **Platformlar:** Yalnızca Android + iOS (Flutter). Web/Windows/macOS/Linux YOK.
- **Ana dil:** Türkçe (kullanıcı arayüzü). Kod içi teknik isimler İngilizce.
- **Proje sahibi kodlama bilmiyor.** Kod örneği/açıklama isteme; kodu doğrudan
  gerçek dosyalara yaz, komutları kendin çalıştır, hataları kendin düzelt.

## Teknoloji Sınırları (değiştirme)
- Flutter + Dart + Material 3 tabanı + özel tasarım sistemi
- Riverpod (state) + GoRouter (routing) + flutter_localization
- Feature-first mimari + Repository pattern
- Backend: **Supabase** (Postgres, Auth, Storage, Realtime, Edge Functions, Cron, RLS)
- Push: **Firebase Cloud Messaging** (yalnızca bildirim; veri/auth/storage DEĞİL)
- iOS build/yayın: **Codemagic** (Windows'ta çalışılır, Mac/Xcode gerekmez)
- PDF: cihaz üzerinde (`pdf` + `printing`)
- İlk aşamada bağlanmayacak: Cloudflare R2, Resend, Sentry, SES, başka backend/push

## Kesin Kurallar
1. Aynı anda **tek görev** uygula. Görev bitince **DUR**, sonraki göreve geçme.
2. Bir görev ~300 satırdan fazla yeni kod gerektiriyorsa alt görevlere böl ve dur.
3. Placeholder/göstermelik kod, kritik TODO, sahte başarı raporu bırakma.
4. Gerçekten çalıştırmadığın testi "geçti" deme.
5. Secret'ları koda gömme, GitHub'a gönderme. `.gitignore` eksiksiz olsun.
6. Kullanıcıya ham teknik hata gösterme → merkezi Türkçe hata dönüşümü.
7. Büyük mimari değişiklik gerekirse önce `docs/DECISIONS.md`'e öneri yaz, onay bekle.
8. Her görev sonunda `docs/TASKS.md` ve (tamamlanınca) `docs/COMPLETED.md` güncelle.
9. Sadece tamamlanan + testleri geçen görevden sonra commit + push.
10. Git: `git push -u origin claude/miyhav-pet-app-setup-t8vk5q`. Force push / history
    yeniden yazma / `reset --hard` yapma (açıkça istenmedikçe).

## Merkezi Yapılandırma
Uygulama adı, marka adı, package/bundle id gibi değerler tek merkezden yönetilir
(`lib/core/config/app_config.dart` — SETUP görevinde oluşur). Değerleri koda
dağınık sabitleme.

## Güvenlik Özet Kuralları
- RLS deny-by-default. Hiçbir tabloyu genel yazmaya açma.
- Kritik alanlar (membership_type, account_status, owner_id) client update ile
  değiştirilemez → güvenli RPC.
- Sağlık verisi kesinlikle özel: log/analytics/crash/push payload/public URL'de olmaz.
- Arkadaşlık kabul, engelleme, hesap silme gibi kritik işlemler atomik RPC ile.
- "UI zaten göstermiyor" güvenlik gerekçesi değildir.

## Doküman Haritası (nerede ne var)
| Doküman | Sorumluluk |
|---|---|
| `docs/PRODUCT_SPEC.md` | Ürün kapsamı, MVP, ekranlar |
| `docs/ARCHITECTURE.md` | Klasör yapısı, katmanlar, paketler |
| `docs/DATABASE_SCHEMA.md` | Tablolar, kolonlar, ilişkiler, constraint'ler |
| `docs/RLS_SECURITY_MODEL.md` | RLS politikaları, RPC güvenlik yaklaşımı |
| `docs/PRIVACY_MATRIX.md` | Görünürlük/engelleme davranış matrisi |
| `docs/UI_DESIGN_SYSTEM.md` | Renk, tipografi, spacing, bileşenler |
| `docs/AUTH_EMAIL_MODEL.md` | Auth akışları ve e-posta modeli |
| `docs/MEDIA_STORAGE_PLAN.md` | Storage bucket'ları, medya soyutlaması |
| `docs/NOTIFICATION_MODEL.md` | FCM + Cron + Edge Function bildirim akışı |
| `docs/PDF_SPEC.md` | Sağlık karnesi PDF içeriği/kuralları |
| `docs/TEST_STRATEGY.md` | Test türleri, RLS test yaklaşımı |
| `docs/ENVIRONMENT_SETUP.md` | dev/prod, dart-define, gizli değerler |
| `docs/CODEMAGIC_IOS_PLAN.md` | iOS cloud build/yayın planı |
| `docs/STORE_RELEASE_CHECKLIST.md` | Mağaza yayın kontrol listesi |
| `docs/DECISIONS.md` | Mimari kararlar (kısa) |
| `docs/TASKS.md` | Görev listesi, bağımlılık, durum |
| `docs/COMPLETED.md` | Tamamlanan görevler |

## Görev Sonu Raporu (kısa)
Commit oluşturuldu mu? / mesaj / push edildi mi? / secret kontrolü / zorunlu manuel
işlem. Büyük kod bloğu veya doküman içeriğini sohbete kopyalama.
