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
