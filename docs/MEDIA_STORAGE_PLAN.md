# MEDIA_STORAGE_PLAN — Medya ve Dosya Depolama

## Sağlayıcı
İlk ve aktif sağlayıcı: **Supabase Storage**. Cloudflare R2 bağlanmaz (SDK/anahtar/
hesap yok). Sağlayıcı bağımsızlığı kod düzeyinde kurulur.

## Soyutlama
`MediaStorageRepository` (arayüz) — feature kodları yalnızca bunu kullanır.
Tek implementasyon: `SupabaseMediaStorageRepository`. Storage SDK çağrıları
feature'lara dağıtılmaz. İleride R2 gerekirse yalnızca yeni bir implementasyon +
migration görevi eklenir; feature kodları yeniden yazılmaz. `CloudflareR2...`
şimdi oluşturulmaz.

## Bucket'lar ve Politikalar
| Bucket | Erişim | İçerik |
|---|---|---|
| `avatars` | okuma kontrollü | profil/pet profil fotoğrafları |
| `social-media` | görünürlük kurallarına tabi | post görselleri + thumbnail |
| `health-attachments` | **private** | sağlık ekleri (kesin özel) |

- Sağlık ekleri **public URL kullanmaz**; kısa ömürlü **signed URL** ile sunulur.
  Storage policy kullanıcı kimliği + pet sahipliği doğrular.
- Sosyal fotoğraflar ile sağlık ekleri ayrı bucket + ayrı güvenli policy.
- Path şeması: `{owner_id}/{pet_id}/{uuid}.{ext}` gibi güvenli, benzersiz path.
  Path DB'de saklanır (URL değil).

## Yükleme Kuralları (client)
Yüklemeden önce: dosya türü doğrula; boyut sınırı uygula; uygun sıkıştırma; gereksiz
metadata (EXIF) temizle; güvenli benzersiz path; upload progress göster; kesilen
yüklemeyi yönet; değiştirilen/silinen kayıtta eski dosyayı güvenli sil; thumbnail
yaklaşımı.

## Yasaklar
- Fotoğrafı base64 olarak Postgres'te saklama YOK.
- Video yükleme YOK (MVP).
- Sağlık eki public URL YOK.

## Entitlement Bağı
`maxHealthAttachments` gibi limitler merkezi entitlement service üzerinden
kontrol edilir (MVP'de ücretsiz varsayılan).
