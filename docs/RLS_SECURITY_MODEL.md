# RLS_SECURITY_MODEL — Miyhav Güvenlik Modeli

Tüm public şema tablolarında **RLS açık** ve **deny-by-default**. Hiçbir tablo
genel yazmaya açılmaz. Politikalar migration ile gelir. "UI zaten göstermiyor"
bir güvenlik gerekçesi DEĞİLDİR.

## Yardımcı Fonksiyonlar (SECURITY DEFINER, dikkatli)
- `are_friends(a uuid, b uuid) returns bool` — friendships'i kanonik sırayla sorgular.
- `is_blocked_between(a uuid, b uuid) returns bool` — iki yönde blocks kontrolü.
- `is_account_active(uid uuid) returns bool` — account_status='active'.
- Bu fonksiyonlar sadece boolean döner; hassas veri sızdırmaz. `search_path`
  sabitlenir; yalnızca gerekli tabloları okur.

## Görünürlük Kuralları (canonical)
Gerçek erişim her zaman **en kısıtlayıcı** birleşimdir:
profil gizliliği ∧ (post ise) post gizliliği ∧ arkadaşlık ∧ engel yok ∧
hesap aktif ∧ moderasyon durumu.

---

## profiles
- **select (tam profil):** kendi kaydı; VEYA (hedef aktif ∧ engel yok ∧
  (public VEYA (friends_only ∧ are_friends))). private → yalnızca sahibi.
- **insert:** yalnızca `id = auth.uid()` (trigger zaten oluşturur; savunma katmanı).
- **update:** yalnızca `id = auth.uid()` VE `membership_type`/`account_status`
  değiştirilemez. Bunu garanti için: bu iki kolon client update grant'inden çıkarılır
  (kolon-seviyesi privilege) ve/veya `WITH CHECK` + trigger ile eski değere sabitlenir.
  Değişim yalnızca güvenli RPC/Edge Function ile.
- **delete:** doğrudan yok; hesap silme RPC/Edge Function ile.

## Arama & Keşif Projeksiyonu (güvenli)
Karar: **security invoker view + RPC**.
- `public_profiles` — SECURITY INVOKER view; yalnızca güvenli alanları seçer:
  `id, username, display_name, profile_photo_path, profile_visibility` + güvenli
  kısa bio ön izlemesi + güvenli pet özeti. E-posta/telefon/sağlık/mikroçip/token/
  üyelik/ayar **yok**.
- `search_profiles(q text)` ve `discover_profiles(...)` — SECURITY INVOKER RPC;
  çağıran `auth.uid()` bazında: private hariç; suspended/deleted hariç; engelli
  çiftler iki yönde hariç; friends_only aramada görünür ama tam profil yalnızca
  arkadaşa. RPC yalnızca `public_profiles` alanlarını döner.
- **Arama görünürlüğü ≠ tam profil erişimi.** İkisi ayrı ayrı zorlanır.

## pets
- **select:** sahibi (owner_id=auth.uid()). Sosyal pet özeti ayrı güvenli
  projeksiyondan (`pet_public_view`, yalnızca id/name/species/foto gibi güvenli
  alanlar; mikroçip/özel alan YOK), profil görünürlük+engel kurallarına tabi.
- **insert:** `owner_id = auth.uid()` zorunlu.
- **update:** sahibi; `owner_id` değiştirilemez (WITH CHECK + trigger).
- **delete:** sahibi.

## friend_requests
- **select:** yalnızca sender veya receiver. Üçüncü kişi göremez.
- **insert:** `sender_id = auth.uid()`, `sender<>receiver`, engel yok, hedef aktif.
  Duplicate/ters-duplicate constraint + `send_friend_request` RPC ile engellenir.
- **update:** iptal → sender; kabul/ret → receiver. Kritik geçişler RPC ile.

## Arkadaşlık RPC (atomik)
- `send_friend_request(target uuid)` — engel/aktiflik/duplicate/ters-duplicate/
  zaten-arkadaş kontrolü; güvenli insert.
- `accept_friend_request(request_id uuid)` — **transaction içinde**: receiver
  doğrulaması, request'i accepted yap, kanonik `friendships` satırı ekle (yarış
  durumuna karşı `insert ... on conflict do nothing`), varsa ters pending'i kapat.
- `reject_friend_request`, `cancel_friend_request`, `remove_friendship`.
- Client tarafında çok adımlı güvensiz kabul akışı KURULMAZ.

## friendships
- **select:** yalnızca taraflar (user_one/user_two).
- **insert/delete:** doğrudan client YOK; yalnızca RPC (accept/remove/block).

## blocks & block RPC
- **select:** blocker kendi engellerini görür.
- `block_user(target uuid)` — atomik RPC: blocks satırı ekle; mevcut friendship'i
  kaldır; iki yöndeki pending istekleri iptal et.
- `unblock_user(target uuid)`.
- Engelleme YALNIZCA Flutter'da filtrelenmez; view/RPC/RLS `is_blocked_between`'i
  dikkate alır: engelli çift birbirini aramada/keşfette/önizlemede/tam profilde
  görmez, post/beğeni/yorum/istek yapamaz.

## posts / post_likes / post_comments
- **posts select:** sahibi; VEYA (hedef aktif ∧ engel yok ∧ moderation=visible ∧
  görünürlük birleşimi: public → herkes; friends_only → arkadaş; private → yalnızca
  sahibi). Private profile ait public post **dışarı açılmaz** (profil private ise
  yalnızca sahibi).
- **posts insert:** `owner_id=auth.uid()` ∧ ilgili pet sahibi.
- **posts update/delete:** sahibi.
- **likes/comments select:** ilgili postu görebilen kullanıcı; engel yok.
- **like insert:** postu görebilen; UNIQUE ile tek beğeni. **comment insert:**
  postu görebilen. **comment delete:** yalnızca yorum sahibi.

## health_records / health_attachments / weight_measurements / health_reminders
- **Tümü:** select/insert/update/delete yalnızca `owner_id = auth.uid()`.
  Arkadaş/halk/keşif/analytics'e **kapalı**. Ekler private bucket + kısa ömürlü
  signed URL; storage policy sahiplik doğrular.

## notification_deliveries / device_tokens
- **device_tokens:** kullanıcı yalnızca kendi token'ını yönetir.
- **notification_deliveries:** kullanıcı yalnızca kendi kayıtlarını okur; yazma
  yalnızca Edge Function (service role) tarafından.

## Genel Garantiler (mobil değiştirilse bile)
Başka kullanıcı adına pet oluşturulamaz; owner_id değişmez; başka petin sağlık
kaydı okunamaz; başka kullanıcının health attachment'ı açılamaz; membership_type/
account_status değişmez; sahte friendship kurulamaz; private profil aramada
bulunmaz; friends_only tam profil arkadaş olmayana açılmaz; blocked kullanıcı
içeriğe erişemez.

## Test Zorunluluğu
Bu kuralların her biri gerçek RLS testleriyle doğrulanır (bkz. `TEST_STRATEGY.md`).
Test dosyasının varlığı testin çalıştığı anlamına gelmez.
