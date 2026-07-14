# UI_DESIGN_SYSTEM — Miyhav Tasarım Sistemi

Referans ekran görüntüleri yalnızca **atmosfer** için ilhamdır. Layout, logo,
illüstrasyon veya telifli karakterler (ör. Hello Kitty) **kopyalanmaz**. Miyhav'ın
özgün tasarım dili oluşturulur.

## Tasarım Yönü
"Özgün pixel-art pet dünyası ile modern, kaliteli, sıcak ve sosyal mobil uygulama
deneyiminin birleşimi." Sıcak, yumuşak, ferah; büyük ve dengeli tipografi;
yuvarlatılmış kartlar; asimetrik ama anlaşılır kompozisyon; petleri öne çıkaran
ekranlar. Jenerik demo / kurumsal / banka / çocuk oyunu / neon / aşırı gradyan
hissinden uzak.

## Renk Paleti (çekirdek)
Material 3 ColorScheme bu tokenlardan türetilir. Değerler `AppColors`'ta merkezi.
| Rol | Ton | Örnek HEX (başlangıç) |
|---|---|---|
| Primary (Soft Coral / Terracotta) | pastel mercan | `#D08D79` |
| Primary dark | koyu terracotta | `#B06B57` |
| Secondary (Warm Amber) | sıcak kehribar | `#E0A96D` |
| Accent (Cacao) | kakao kahvesi | `#7A5240` |
| Background | krem / kırık beyaz | `#F5EFE9` |
| Surface | pudra beyazı | `#FBF7F3` |
| Surface alt (Taupe) | taupe | `#D9CFC6` |
| On-surface / text | koyu kahve-siyah | `#2B2320` (≈ `#020202` tam siyah değil) |
| Muted text | taupe-gri | `#8A7D74` |
| Success | yumuşak yeşil | `#7FA87A` |
| Warning | amber | `#E0A96D` |
| Error | sıcak kırmızı | `#C15B4E` |

- Karanlık tema için her token'ın koyu eşleniği tanımlanır ( leke değil, sıcak koyu
  kahve zeminler). Kontrast WCAG AA hedeflenir; küçük/okunamaz metin yok.
- Beyaz `#FFFFFF` yalnızca vurgu yüzeylerde; ana zemin krem tonlarıdır.

## Tipografi
- Ana font ailesi: **Jost** (SIL OFL, açık lisans) — uygulamaya bundled font olarak
  eklenir; Türkçe karakterler (ç ğ ı İ ö ş ü) desteklenir. PDF için de bundled.
- Ölçek (Material 3 TextTheme eşlemesi):
  | Token | Kullanım | ~boyut/ağırlık |
  |---|---|---|
  | Display | büyük başlık/marka | 32–40 / 600 |
  | H1 | ekran başlığı | 26 / 600 |
  | H2 | bölüm başlığı | 22 / 600 |
  | H3 | kart başlığı | 18 / 600 |
  | Body | gövde metni | 15–16 / 400 |
  | Caption | ikincil/etiket | 12–13 / 500 |
- Büyük, ferah, okunabilir. Küçük metinden kaçınılır.

## Spacing & Radius & Elevation
- Spacing ölçeği (4 tabanlı): 4, 8, 12, 16, 20, 24, 32, 40.
- Border radius: sm 8, md 12, lg 20, xl 28, pill (buton/chip) tam yuvarlak.
- Elevation: yumuşak, düşük; sert gölge yok. Kartlar hafif yükseltili + yumuşak gölge.
- Icon boyutları: 16, 20, 24, 32. Avatar boyutları: sm 32, md 48, lg 72, xl 120
  (pet profil üstü için büyük).

## Bileşenler (ihtiyaç oldukça, `shared/widgets`)
Primary/Secondary/Text button, Input, Password input, Search input, Card, Modal,
Bottom sheet, Snackbar, Dialog, Avatar, PetAvatar, Pet profil üst alanı, Sosyal
paylaşım kartı, Keşfet kartı, Sağlık kartı, Hatırlatma kartı, Boş durum, Hata
durumu, Yükleniyor durumu, Skeleton.

- Varsayılan Flutter bileşenleri özelleştirmesiz bırakılmaz; ama her şey için
  gereksiz custom widget üretilmez — gerçek tekrar kullanım varsa ortak bileşen.

## Pet Asset Sistemi (özgün, telifsiz)
Pixel-art hissi veren özgün placeholder avatar sistemi. Kategori bazlı (kedi,
köpek, kuş, tavşan, balık, sürüngen, diğer) özgün karakterler. Gerçek foto
yüklenene kadar kaliteli placeholder. Telifli/marka görseli kullanılmaz.

## Durum Geri Bildirimi (zorunlu)
Kullanıcı her zaman: nereye basacağını, hangi ekranda olduğunu, işlemin başarılı
olup olmadığını, verinin yüklenip yüklenmediğini anlayabilmelidir (loading /
empty / error / success durumları her ekranda ele alınır).
