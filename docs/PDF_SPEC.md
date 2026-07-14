# PDF_SPEC — Sağlık Karnesi PDF

## İlke
PDF **cihaz üzerinde** oluşturulur (`pdf` + `printing`). Yalnızca seçilen pet ve
authenticated owner verisi kullanılır; sağlık verisi veritabanında değiştirilmez.

## Yetenekler
Oluşturma · ön izleme · telefona kaydetme · native paylaşım menüsü · destekleniyorsa
yazdırma.

## İçerik
- Miyhav adı (merkezi marka), oluşturulma tarihi, gizlilik açıklaması.
- Pet: fotoğraf, ad, tür, cins, cinsiyet, doğum tarihi (+ tahmini göstergesi), renk,
  kilo.
- Kullanıcı isterse: mikroçip, sahip adı (opsiyonel, PDF Ayarları'ndan).
- Bölümler: aşı geçmişi, iç/dış parazit, ilaç, veteriner ziyaretleri, alerjiler,
  teşhisler, ameliyatlar, kilo geçmişi, yaklaşan işlemler, notlar.

## Gereksinimler
- **Türkçe karakter desteği** → güvenli bundled font (Jost veya uyumlu, ç ğ ı İ ö ş ü).
- Doğru sayfalama; okunabilir tablolar; uzun notların satıra sığması (wrap).
- Boş bölümler gösterilmez.
- Yalnızca sahibin verisi; RLS zaten yalnızca sahibe erişim verir.

## PDF Ayarları Ekranı
Mikroçip dahil et (aç/kapat), sahip adı dahil et (aç/kapat) gibi seçenekler; sonra
ön izleme → paylaş/kaydet/yazdır.

## Kapsam Dışı (MVP)
Sunucu tarafı PDF üretimi, premium şablonlar (ileride entitlement ile).
