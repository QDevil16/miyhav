/// Kimlik doğrulama formları için saf (ağsız) ön doğrulamalar.
///
/// Ağ isteğinden önce çalışır; Türkçe hata döner, geçerliyse `null`.
abstract final class AuthValidators {
  /// Şifrenin en az uzunluğu (Supabase politikasıyla uyumlu ön kontrol).
  static const int minPasswordLength = 8;

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  /// E-posta biçimi. Boş veya geçersizse Türkçe mesaj döner.
  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'E-posta adresini gir.';
    if (!_emailPattern.hasMatch(v)) return 'Geçerli bir e-posta adresi gir.';
    return null;
  }

  /// Şifre uzunluğu. Boş veya kısa ise Türkçe mesaj döner.
  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Şifreni gir.';
    if (v.length < minPasswordLength) {
      return 'Şifre en az $minPasswordLength karakter olmalı.';
    }
    return null;
  }

  /// Şifre tekrarı; [original] ile eşleşmeli.
  static String? passwordConfirm(String? value, String original) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Şifreni tekrar gir.';
    if (v != original) return 'Şifreler eşleşmiyor.';
    return null;
  }
}
