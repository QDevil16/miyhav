# PRODUCT_SPEC — Miyhav Ürün Şartnamesi

Bu doküman ürün kapsamını ve MVP tanımını tutar. Teknik ayrıntılar diğer
dokümanlardadır.

## 1. Ürün Vizyonu
Pet sahiplerinin petlerinin sağlığını düzenli takip ettiği, hatırlatmalarla
işlemleri kaçırmadığı ve petlerini sosyal bir toplulukta paylaştığı sıcak,
özgün ve güvenli bir mobil uygulama. Sağlık verisi mahremiyeti temel ilkedir.

## 2. Hedef Kullanıcı
Bir veya birden fazla evcil hayvanı olan bireysel kullanıcılar. (MVP'de veteriner
/ klinik / işletme hesabı YOK.)

## 3. Pet Kategorileri
Kedi, Köpek, Kuş, Tavşan, Balık, Sürüngen, Diğer.

## 4. MVP Kapsamı (tamamlanması zorunlu)
**Hesap:** Kayıt, e-posta doğrulama, giriş, çıkış, şifre sıfırlama/değiştirme,
e-posta değiştirme, güvenli hesap silme, Türkçe hata yönetimi.

**Profil:** display_name, username (benzersiz), foto, kısa bio, şehir, gizlilik
(public / friends_only / private). Kritik alanlar (membership_type, account_status)
kullanıcı tarafından değiştirilemez.

**Pet:** Birden fazla pet ekleme/düzenleme/silme; özel alanlar (mikroçip vb.)
yalnızca sahibe. Sosyal pet görünümü sınırlı ve güvenli.

**Sosyal:** Ana akış, paylaşım oluşturma/silme, beğeni/beğeni kaldırma, yorum/
kendi yorumunu silme, içerik şikâyeti, kullanıcı engelleme.

**Arkadaşlık:** İstek gönderme/iptal, kabul/ret, arkadaşlıktan çıkma, listeler,
engelleme/engel kaldırma, şikâyet. Tek canonical ilişki çözümleyici.

**Keşfet & Arama:** Güvenli projeksiyon; yalnızca izinli alanlar; private ve
pasif/askıya alınmış/silinmiş hesaplar görünmez.

**Sağlık:** Kayıt türleri (aşı, iç/dış parazit, ilaç, veteriner ziyareti, alerji,
teşhis, ameliyat, kilo, muayene, diğer), ekler (özel bucket, signed URL),
tekrarlayan periyot + `next_due_date`, yaklaşan hatırlatmalar.

**Bildirim:** FCM ile yaklaşan hatırlatma bildirimi (hassas veri payload'da yok).

**PDF:** Sağlık karnesi — oluştur, ön izle, kaydet, paylaş; Türkçe font.

**Güvenlik/altyapı:** RLS, storage policy, DB constraint, DB + RLS testleri,
Flutter testleri, dev/prod ortam, Android build, Codemagic iOS build, mağaza
dokümanları.

## 5. Ekran Listesi (görev sırası geldikçe gerçek işleviyle üretilir)
Splash, Onboarding, Giriş, Kayıt, Şifremi Unuttum, E-posta Doğrulama, Ana Akış,
Keşfet, Arama, Sınırlı Profil Ön İzleme, Tam Profil, Arkadaşlar, İstekler,
Paylaşım Oluştur, Paylaşım Detayı, Petlerim, Pet Ekle/Düzenle/Detay, Sağlık
Geçmişi, Sağlık Kaydı Ekle/Düzenle, Aşı Takvimi, Yaklaşan Hatırlatmalar, PDF
Ayarları, PDF Ön İzleme, Bildirimler, Gizlilik/Bildirim Ayarları, Engellenenler,
Hesap Ayarları, Hesap Silme.

> İlk görevde tüm ekranlar boş placeholder olarak toplu üretilmez.

## 6. Alt Navigasyon
1. Ana Sayfa  2. Keşfet  3. Paylaş  4. Petlerim  5. Profil

## 7. MVP Dışı (açıkça istenmedikçe eklenmez)
Özel mesajlaşma, video görüşme/yükleme, grup sohbeti, canlı konum, haritada yakın
kullanıcılar, sahiplendirme/ürün pazaryeri, veteriner/klinik hesabı, yapay zekâ,
reklam, ücretli abonelik, kayıp pet canlı alarm, flört/eşleştirme.

## 8. Üyelik / Entitlement (hazırlık)
MVP'de ödeme yok. İleride Free/Premium/Family. Limitler merkezi bir entitlement
service üzerinden (maxPets, canExportPdf, maxHealthAttachments, featureFlags).
Varsayılan ücretsiz üyelik şimdilik sınırsız pet.

## 9. Tamamlanma İlkesi
Bir özelliğin sadece UI ekranı olması onu tamamlanmış yapmaz. Gerçek veri akışı,
güvenlik ve hata durumları çalışmalıdır.
