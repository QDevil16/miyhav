# UI_DESIGN_SYSTEM — Miyhav Tasarım Sistemi

Referans ekran görüntüleri yalnızca **atmosfer** için ilhamdır. Layout, logo,
illüstrasyon veya telifli karakterler (ör. Hello Kitty) **kopyalanmaz**. Miyhav'ın
özgün tasarım dili oluşturulur.

## Tasarım Yönü
"Modern, sıcak, premium ve sevimli bir pet uygulaması deneyimi." Sıcak, yumuşak,
ferah; büyük ve dengeli tipografi;
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

## Pet Asset Sistemi (hazır ikon, temiz + premium)
Elle hayvan çizimi YOK. Pet türleri için hazır, tanınabilir tek bir ikon ailesi
(**Lucide**) kullanılır. Merkezî widget `PetTypeIcon(type, size, selected)`: yuvarlak
sade zemin + ortada tür ikonu (kedi, köpek, kuş, tavşan, balık, sürüngen→kaplumbağa,
diğer→pati). Seçili iken soft coral vurgu (ince coral çerçeve + çok hafif coral zemin).
Varsayılan kullanıcı profili `DefaultProfileAvatar` (pastel coral yüzey + Lucide pati)
pet ikonlarından ayrışır. Aynı `PetTypeIcon`, fotoğrafsız pet avatarı (fallback) olarak
kullanılır; foto varsa gerçek foto gösterilir. Gradient/3D yok, gölge minimum, Miyhav
paletiyle uyumlu. Pixel-art/emoji/maskot/telifli görsel kullanılmaz (bkz. D-019).

## Durum Geri Bildirimi (zorunlu)
Kullanıcı her zaman: nereye basacağını, hangi ekranda olduğunu, işlemin başarılı
olup olmadığını, verinin yüklenip yüklenmediğini anlayabilmelidir (loading /
empty / error / success durumları her ekranda ele alınır).

---

## Uygulama Durumu (DESIGN-001)
Tasarım sistemi kodda hayata geçirildi. Tokenlar tek merkezden gelir; widget'larda
magic number / ham HEX kullanılmaz.

**Token dosyaları (`lib/core/theme/`):**
- `app_colors.dart` — palet + açık/koyu `ColorScheme`.
- `app_typography.dart` — Jost tabanlı ölçek (display/h1/h2/h3/body/caption) + `TextTheme`.
- `app_spacing.dart` — 4 tabanlı boşluk ölçeği.
- `app_radius.dart` — köşe yarıçapları + `BorderRadius` sabitleri.
- `app_shadows.dart` — yumuşak kart/yükselti/buton gölgeleri.
- `app_sizes.dart` — ikon ve avatar boyutları.
- `app_theme.dart` — tokenlardan `AppTheme.light` / `AppTheme.dark`.

**Font:** Jost gerçekten bundle edildi (`assets/fonts/Jost-{Regular,Medium,SemiBold,
Bold}.ttf`), `pubspec.yaml` `fonts:` altında tanımlı. Çalışma zamanında indirilmez.
Google Fonts variable font'undan `fonttools` ile statik ağırlıklar üretildi; Türkçe
karakter kapsamı doğrulandı (ç ğ ı İ ö ş ü). Lisans: `assets/fonts/Jost-OFL.txt` (SIL OFL).

**Reusable bileşenler (`lib/shared/widgets/`):**
`app_button.dart` (PrimaryButton/SecondaryButton), `app_text_field.dart` (şifre
göster/gizle dahil), `app_card.dart` (imza yuvarlatılmış yüzey + accent varyantı),
`app_avatar.dart` (kullanıcı, baş harf/ikon), `default_profile_avatar.dart`
(varsayılan pati profil avatarı), `pet_type_icon.dart` (hazır Lucide pet türü
ikonları — aşağıya bak), `empty_state.dart`, `loading_state.dart`,
`miyhav_app_bar.dart`, `miyhav_bottom_nav.dart` (özel yüzen pill navigasyon).

**Alt navigasyon:** `MainShell` (`lib/app/main_shell.dart`) 5 geçici sekme —
Ana Sayfa · Keşfet · Paylaş · Petlerim · Profil. Gerçek feature/backend YOK;
sekmeler tasarım sistemini sergileyen geçici içerik gösterir.

**Pet asset sistemi (DESIGN-002 ile hazır ikonlara geçti):** `PetTypeIcon` —
elle çizim YOK, pixel/emoji/maskot YOK. 7 tür (cat/dog/bird/rabbit/fish/reptile→
turtle/other→paw) hazır **Lucide** ikonlarıyla, yuvarlak sade zeminde gösterilir.
Seçili iken soft coral vurgu (ince coral çerçeve + çok hafif coral zemin + belirgin
ikon/yazı). Varsayılan kullanıcı profili `DefaultProfileAvatar` (pastel coral yüzey +
Lucide pati). Aynı `PetTypeIcon` fotoğrafsız pet avatarı olarak da kullanılır (foto
varsa gerçek foto). Ana ekran "Türler" bölümü bu ikonlarla seçilebilir + Türkçe
etiketli. Tek icon package (`lucide_icons_flutter`); gradient/3D yok, gölge minimum.
