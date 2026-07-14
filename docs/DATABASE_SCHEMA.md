# DATABASE_SCHEMA — Miyhav Veritabanı Tasarımı (Supabase / PostgreSQL)

Bu doküman tablo tasarımını, ilişkileri ve constraint yaklaşımını tanımlar. RLS
politikaları `RLS_SECURITY_MODEL.md`'dedir. Tüm public tablolarda RLS açıktır
(deny-by-default). Şema versiyonlanmış migration dosyalarıyla kurulur
(`supabase/migrations/`), Dashboard'da manuel bırakılmaz.

## Genel Kurallar
- PK: `uuid` (default `gen_random_uuid()`), aksi belirtilmedikçe.
- Zaman: `timestamptz`, `created_at`/`updated_at` default `now()`; `updated_at`
  trigger ile güncellenir.
- Kullanıcı referansları `auth.users(id)`'e FK; genelde `on delete cascade` —
  ancak hesap silme, güvenli bir Edge Function/RPC ile yönetilir (bkz. §Hesap Silme).
- Enum'lar Postgres `enum` veya `text` + `check`. Basitlik için MVP'de `text` +
  `check` tercih edilir (migration ile kolay genişler).

---

## 1. profiles
Kullanıcı profili. `id` = `auth.users.id`.
| kolon | tip | not |
|---|---|---|
| id | uuid PK | FK auth.users(id) on delete cascade |
| display_name | text | |
| username | text | görünen kullanıcı adı |
| username_normalized | text | lower(trim(username)); **UNIQUE** |
| profile_photo_path | text null | Storage path (URL değil) |
| short_bio | text null | |
| city | text null | |
| profile_visibility | text | check in (public, friends_only, private), default private |
| membership_type | text | check in (free, premium, family), default free — **client değiştiremez** |
| account_status | text | check in (active, suspended, deleted), default active — **client değiştiremez** |
| created_at | timestamptz | |
| updated_at | timestamptz | |

- **UNIQUE(username_normalized)** → case-insensitive benzersizlik, yarış durumuna
  dayanıklı (yalnızca client kontrolüne güvenilmez).
- Profil, `auth.users` insert olduğunda **trigger** (`handle_new_user`) ile
  idempotent oluşturulur; yalnızca client başarısına bağlı değildir.
- `membership_type` ve `account_status` RLS + kolon bazlı koruma ile client
  update'inden çıkarılır; değişimi yalnızca güvenli RPC/Edge Function ile.

## 2. pets
Petin özel verisi; yalnızca sahibe.
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| owner_id | uuid | FK profiles(id) on delete cascade; **değiştirilemez** |
| name | text | |
| species | text | check in (cat,dog,bird,rabbit,fish,reptile,other) |
| breed | text null | |
| sex | text null | check in (male,female,unknown) |
| birth_date | date null | |
| is_birth_date_estimated | bool | default false |
| color | text null | |
| current_weight | numeric null | kg |
| profile_photo_path | text null | |
| short_description | text null | |
| microchip_number | text null | hassas; yalnızca sahibe |
| is_neutered | bool null | |
| created_at / updated_at | timestamptz | |

- `owner_id` insert'te `auth.uid()`'e eşit olmalı (RLS + trigger koruması).
- Sosyal görünüm ayrı bir güvenli projeksiyondan verilir (bkz. `pet_public_view`,
  `RLS_SECURITY_MODEL.md`). Mikroçip/özel alanlar projeksiyona dahil edilmez.

## 3. friend_requests
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| sender_id | uuid | FK profiles(id) |
| receiver_id | uuid | FK profiles(id) |
| status | text | check in (pending, accepted, rejected, cancelled), default pending |
| created_at / updated_at | timestamptz | |

- `check (sender_id <> receiver_id)` — kendine istek yok.
- **Partial UNIQUE index**: `(sender_id, receiver_id) where status='pending'` —
  aynı yönde ikinci pending yok.
- Ters yön pending engeli ve kabulün atomikliği RPC + constraint ile (bkz.
  `RLS_SECURITY_MODEL.md` §Arkadaşlık RPC).

## 4. friendships
Kabul edilmiş tek arkadaşlık.
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| user_one_id | uuid | FK profiles(id) |
| user_two_id | uuid | FK profiles(id) |
| created_at | timestamptz | |

- Kanonik sıra: `check (user_one_id < user_two_id)` → aynı çift için tek satır.
- **UNIQUE(user_one_id, user_two_id)**.
- `are_friends(a,b)` yardımcı fonksiyonu bu tabloyu kanonik sırayla sorgular.

## 5. blocks
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| blocker_id | uuid | FK profiles(id) |
| blocked_id | uuid | FK profiles(id) |
| created_at | timestamptz | |

- `check (blocker_id <> blocked_id)`, **UNIQUE(blocker_id, blocked_id)**.
- Engelleme çift yönlü etki eder; view/RPC/RLS `is_blocked_between(a,b)` ile filtreler.

## 6. reports (kullanıcı şikâyeti)
| kolon | tip | not |
|---|---|---|
| id | uuid PK | reporter_id, reported_user_id, reason, details null, status, created_at |

## 7. posts
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| owner_id | uuid | FK profiles(id); yalnızca kendi petine post |
| pet_id | uuid | FK pets(id); owner doğrulaması RLS/trigger |
| image_path | text | Storage path |
| thumbnail_path | text null | |
| caption | text null | |
| visibility | text | check in (public, friends_only, private), default public |
| moderation_status | text | check in (visible, hidden, under_review), default visible |
| created_at / updated_at | timestamptz | |

## 8. post_likes
`id, post_id FK posts, user_id FK profiles, created_at`; **UNIQUE(post_id, user_id)**.

## 9. post_comments
`id, post_id FK posts, user_id FK profiles, body text, created_at`. Kullanıcı yalnızca
kendi yorumunu siler.

## 10. content_reports
`id, post_id FK posts, reporter_id, reason, details null, status, created_at`.

## 11. health_records (KESİN ÖZEL)
| kolon | tip | not |
|---|---|---|
| id | uuid PK | |
| pet_id | uuid | FK pets(id) on delete cascade |
| owner_id | uuid | FK profiles(id); = pets.owner_id |
| record_type | text | check in (vaccination, internal_parasite, external_parasite, medication, veterinary_visit, allergy, diagnosis, surgery, weight_measurement, examination, other) |
| title | text | |
| event_date | date | |
| notes | text null | |
| veterinarian_name | text null | |
| clinic_name | text null | |
| medication_name | text null | |
| dose | text null | |
| recurrence_enabled | bool | default false |
| recurrence_value | int null | |
| recurrence_unit | text null | check in (day,week,month,year) |
| next_due_date | date null | domain service hesaplar |
| reminder_offsets | int[] null | gün cinsinden ofsetler (ör. {30,7,1,0}) |
| created_at / updated_at | timestamptz | |

- Yalnızca ilgili record_type için gereken alanlar doldurulur.
- RLS: yalnızca `owner_id = auth.uid()` okur/yazar. Sosyal/arama/keşfe **hiç** çıkmaz.

## 12. health_attachments
`id, health_record_id FK health_records on delete cascade, pet_id, owner_id,
storage_path (private bucket), file_type, size_bytes, created_at`. Erişim signed URL
+ sahiplik doğrulaması. Ayrıntı: `MEDIA_STORAGE_PLAN.md`.

## 13. weight_measurements
`id, pet_id FK pets, owner_id, weight_kg numeric, measured_on date, created_at`.
(Kilo geçmişi ayrı tutulur; PDF ve grafik için.)

## 14. health_reminders
Yaklaşan hatırlatmaların türetilmiş/planlanmış görünümü.
`id, health_record_id FK, pet_id, owner_id, due_date, offset_days, scheduled_at,
status (pending,sent,cancelled), created_at`. Cron/Edge Function bunları işler.

## 15. notification_deliveries (idempotency)
`id, user_id, health_reminder_id null, dedupe_key text UNIQUE, channel (push),
status (sent,failed), sent_at, created_at`. Aynı bildirimi ikinci kez göndermeyi
engeller.

## 16. device_tokens (FCM)
| kolon | tip | not |
|---|---|---|
| id | uuid PK | user_id FK profiles |
| token | text | |
| platform | text | check in (android, ios) |
| device_id_hash | text null | |
| is_active | bool | default true |
| created_at / updated_at / last_seen_at | timestamptz | |

- **UNIQUE(token)**; yenileme upsert; geçersizler pasif/temizlenir.

## İlişki Özeti
- `profiles 1—* pets 1—* health_records 1—* health_attachments`
- `pets 1—* weight_measurements`, `pets 1—* posts 1—* {post_likes, post_comments}`
- `profiles *—* profiles` (friend_requests, friendships, blocks üzerinden)
- `profiles 1—* device_tokens`

## Constraint Felsefesi
Kritik ve atomik davranışlar client'a bırakılmaz: unique index, check constraint,
transaction ve RPC ile veritabanı seviyesinde garanti edilir (kendine istek yok,
duplicate/ters-duplicate pending yok, tek friendship, atomik kabul, tek beğeni,
tek device token).

## Hesap Silme
Kısmi client-side cascade YOK. Güvenli Edge Function/RPC tüm ilişkili veriyi
(profil, petler, sağlık, ekler, hatırlatmalar, token, post/yorum/beğeni, arkadaşlık,
engel, auth hesabı) yönetir. Şikâyet/moderasyon retention kararı: `DECISIONS.md`.
