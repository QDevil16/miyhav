# NOTIFICATION_MODEL — Bildirim Modeli (FCM + Cron + Edge Function)

## Amaç
Yaklaşan sağlık hatırlatmaları için güvenli, tekrarsız push bildirimi. Hassas
sağlık ayrıntısı payload'a **konmaz**.

## Bileşenler
- **Firebase Cloud Messaging (FCM):** Android + iOS teslimat. iOS için APNs'e hazır
  yapı. FCM yalnızca bildirim; veri/auth/storage için kullanılmaz.
- **device_tokens tablosu:** çok cihaz desteği, token yenileme, geçersiz token
  temizliği (bkz. `DATABASE_SCHEMA.md`).
- **Supabase Cron (pg_cron):** periyodik olarak yaklaşan hatırlatmaları tarar.
- **Edge Function (`send-due-reminders`):** due kayıtları alır, kullanıcı bildirim
  tercihlerini kontrol eder, FCM gönderir, `notification_deliveries` yazar.

## Akış
1. Sağlık kaydı `recurrence_enabled` + `next_due_date` + `reminder_offsets` (gün:
   varsayılan 30, 7, 1, 0 — kullanıcı her birini açıp kapatabilir).
2. `health_reminders` planlanmış tetik zamanlarını türetir.
3. Cron aralıklı çalışır → due olanları Edge Function'a verir.
4. Edge Function:
   - kullanıcı tercih/izin kontrolü,
   - `dedupe_key` (ör. `reminder_id + offset`) ile **idempotency** — aynı bildirim
     ikinci kez gönderilmez,
   - FCM gönderimi + güvenli retry,
   - `notification_deliveries` kaydı.
5. Bildirime dokununca ilgili pet / sağlık kaydı açılır (deep link).

## Payload Kuralı
Varsayılan metin: **"Petiniz için yaklaşan bir sağlık hatırlatıcısı var."**
Payload'a KONMAZ: teşhis, ilaç adı, tedavi/veteriner notu, mikroçip, herhangi bir
hassas sağlık verisi. Yalnızca yönlendirme için gerekli (hassas olmayan)
tanımlayıcılar taşınır.

## Güvenlik
- FCM service account / Firebase Admin credentials mobil uygulamada YOK; yalnızca
  Edge Function ortamında (Supabase secret).
- `notification_deliveries` yazımı yalnızca service role (Edge Function).
- İzin kapalıysa Türkçe bilgi: "Bildirim izni kapalı."

## Kapsam Dışı (MVP)
Sosyal etkileşim push'ları (beğeni/yorum/istek bildirimi) MVP çekirdeğinde zorunlu
değil; ileride ayrı görevle eklenebilir. Öncelik sağlık hatırlatmaları.
