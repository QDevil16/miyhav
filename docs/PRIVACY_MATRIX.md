# PRIVACY_MATRIX — Miyhav Görünürlük ve Engelleme Matrisi

Bu doküman gözlemlenebilir davranışı özetler. Uygulama seçenekleri Türkçe;
veritabanı değerleri parantezte.

## Profil Gizliliği
Seçenekler: **Herkese Açık** (public), **Sadece Arkadaşlar** (friends_only),
**Gizli / Sadece Ben** (private).

| Yetenek | public | friends_only | private |
|---|---|---|---|
| Aramada görünür | ✅ | ✅ | ❌ |
| Keşfette görünür | ✅ | ✅ | ❌ |
| Sınırlı ön izleme (arkadaş değil) | ✅ (tam) | ✅ (sınırlı) | ❌ |
| Tam profil (arkadaş değil) | ✅ | ❌ | ❌ |
| Tam profil (kabul edilmiş arkadaş) | ✅ | ✅ | ❌ |
| Tam profil (sahibi) | ✅ | ✅ | ✅ |

Notlar:
- **Pending** istek arkadaşlık SAYILMAZ.
- Arama görünürlüğü ile tam profil erişimi ayrıdır (friends_only aramada görünür,
  tam profil arkadaşa açılır).
- Pasif/askıya alınmış/silinmiş (suspended/deleted, aktif değil) hesaplar hiçbir
  aramada/keşifte görünmez.

## Uygulanan Erişim Matrisi (PRIVACY-001)
Aşağıdaki tablo **şu an kod/RLS ile fiilen uygulanan** davranıştır (gerçek
PostgreSQL 16 RLS testleriyle doğrulandı). Satırlar erişimi isteyen kişiyi,
sütunlar veri gruplarını gösterir.

| Erişen ↓ / Veri → | Sınırlı discovery | Tam profil | E-posta/auth | Pet sosyal | Pet sağlık |
|---|---|---|---|---|---|
| Kendi profili | ✅ | ✅ | (auth kendi) | (ileride) | ✅ yalnız sahip |
| Public (aktif) kullanıcı → başkası | ✅ | ✅ (public+aktif) | ❌ | (ileride) | ❌ |
| Friends-only'ye **arkadaş** | ✅ | ⛔ ertelendi¹ | ❌ | (ileride) | ❌ |
| Friends-only'ye **arkadaş olmayan** | ✅ (sınırlı) | ❌ | ❌ | (ileride) | ❌ |
| Private kullanıcı → başkası | ❌ | ❌ | ❌ | (ileride) | ❌ |
| Discovery projection (public_profiles/search) | ✅ 5 kolon² | ❌ | ❌ | ❌ | ❌ |

¹ **Ertelendi:** friends_only *tam profil* erişimi arkadaşlık altyapısı (friendships
tablosu/`are_friends`) gerektirir; henüz migration yok → **deny-by-default**. Policy
FRIEND görevinde eklenecek. Şu an friends_only tam profili yalnızca sahibine açık.
² Discovery projeksiyonu yalnızca `id, username, display_name, profile_photo_path,
profile_visibility` döndürür; `membership_type/account_status/e-posta/short_bio/city/
username_normalized` gibi alanlar projeksiyonda YOKTUR. Kaynak filtresi:
`profile_visibility IN ('public','friends_only') AND account_status='active'` (private
ve aktif olmayanlar hariç). **Aramada bulunma ≠ tam profil erişimi.**

Pet sosyal/pet sağlık sütunları: pet tabloları henüz yok (PET görevleri). Ürün/
güvenlik kuralı: **pet sağlık verisi her koşulda yalnızca pet sahibine ait özel
veridir** — hiçbir discovery/sosyal/arkadaş/analytics katmanına çıkmaz.

## Post Gizliliği
Gerçek görünürlük = en kısıtlayıcı birleşim: profil gizliliği ∧ post gizliliği ∧
arkadaşlık ∧ engel yok ∧ hesap aktif ∧ moderation=visible.

| profil \ post | public | friends_only | private |
|---|---|---|---|
| public | herkes | arkadaş | sahibi |
| friends_only | arkadaş | arkadaş | sahibi |
| private | sahibi | sahibi | sahibi |

→ **Private profile ait public post dışarı açılmaz.**

## Engelleme (iki yönlü etki)
Bir kullanıcı diğerini engellediğinde, çiftin her iki yönünde:
- Aramada/keşfette görünmez.
- Sınırlı ön izleme ve tam profil görünmez.
- Paylaşımlar görünmez.
- Arkadaşlık isteği gönderilemez; beğeni/yorum yapılamaz.
- Mevcut arkadaşlık güvenli şekilde kaldırılır.
- Bekleyen istekler iki yönde iptal edilir.

Engelleme yalnızca UI'da filtrelenmez; SQL view/RPC/RLS bunu uygular.

## İlişki Durumları ve Buton Davranışı
Durumlar: none, outgoing_pending, incoming_pending, friends, blocked. Tek
canonical relationship resolver hesaplar.

| Durum | Gösterilen aksiyonlar |
|---|---|
| none | Arkadaşlık İsteği Gönder |
| outgoing_pending | İstek Gönderildi · İsteği İptal Et |
| incoming_pending | Kabul Et · Reddet |
| friends | Arkadaş · Tam Profili Gör · Arkadaşlıktan Çıkar |
| blocked | Arkadaşlık aksiyonları gösterilmez |

Kurallar:
- State yüklenmeden "Arkadaşlık İsteği Gönder" gösterilmez.
- State sorgusunda hata olursa `none` fallback YAPILMAZ; hata durumu güvenli ve
  anlaşılır gösterilir.

## Sağlık Verisi (mutlak özel)
public/friends_only seçeneği yoktur. Yalnızca pet sahibi erişir. Sağlık verisi
sosyal akış/arama/keşfe, arkadaşa, analytics'e, loglara, crash raporuna ve push
payload'ına çıkmaz; ekler public URL ile sunulmaz (kısa ömürlü signed URL).
