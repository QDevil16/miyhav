# AUTH_EMAIL_MODEL — Kimlik Doğrulama ve E-posta

## Auth Sağlayıcı
Supabase Auth (e-posta + şifre). Service role key mobil uygulamada **bulunmaz**;
admin işlemleri yalnızca güvenli Edge Function/RPC ile.

## Desteklenen Akışlar (MVP)
- Kayıt (e-posta + şifre)
- E-posta doğrulama
- Giriş / Çıkış
- Şifremi unuttum → şifre sıfırlama
- Şifre değiştirme
- E-posta değiştirme
- Oturumun açık kalması (persistent session)
- Hesap askıya alma kontrolü (account_status)
- Güvenli hesap silme (RPC/Edge Function)
- Türkçe hata mesajları (ErrorMapper)

## İleriye Hazırlık (MVP'de EKLENMEZ)
Google ile giriş, Apple ile giriş — mimari genişlemeye hazır bırakılır, ama MVP'de
implemente edilmez.

## Profil Oluşturma
`auth.users` insert → `handle_new_user` **trigger** ile idempotent `profiles`
kaydı. Yalnızca client başarısına bağlı değil (mobil çökse bile profil oluşur).

## E-posta Modeli
- **MVP:** Supabase Auth varsayılan e-posta sistemi. Türkçe şablonlar planlanır:
  e-posta doğrulama, şifre sıfırlama, e-posta değiştirme onayı.
- Şablon metinleri Türkçe ve Miyhav markasıyla (merkezi marka adı).
- **Production geçişi (ayrı görev, EMAIL-002):** Resend SMTP. Yalnızca production
  e-posta domain'i doğrulandığında uygulanır. Resend API anahtarı mobil uygulamaya
  **konmaz** (SMTP ayarı Supabase Auth tarafında).
- İleride (opsiyonel): hoş geldiniz, hesap silme bildirimi, güvenlik bildirimi.
  MVP'ye marketing e-postası eklenmez.

## Güvenlik Notları
- Şifre gücü kontrolü (Supabase Auth politikası + client ön kontrolü).
- Token'lar (access/refresh) loglanmaz, crash raporuna gitmez.
- Hesap silme kritik işlem → gerekirse yeniden kimlik doğrulama.

## Türkçe Hata Örnekleri (ErrorMapper)
E-posta zaten kayıtlı / Şifre yeterince güçlü değil / Kullanıcı adı kullanılıyor /
İnternet bağlantınızı kontrol edin / İşlem sırasında bir sorun oluştu.
