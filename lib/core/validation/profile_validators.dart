/// Profil formları için saf (ağsız) doğrulamalar. Geçerliyse `null` döner.
///
/// Bu yalnızca ön kontroldür; kullanıcı adı benzersizliği asıl olarak veritabanı
/// unique constraint'i ile güvence altındadır.
abstract final class ProfileValidators {
  static const int usernameMin = 3;
  static const int usernameMax = 30;
  static const int displayNameMax = 60;
  static const int bioMax = 160;
  static const int cityMax = 80;

  /// Yalnızca harf, rakam ve alt çizgi (Türkçe karakter / boşluk yok).
  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9_]+$');

  /// Kullanıcı adı opsiyoneldir: boş → geçerli (kaydedilince null olur).
  /// Doluysa 3–30 karakter ve yalnızca `[A-Za-z0-9_]`.
  static String? username(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length < usernameMin || v.length > usernameMax) {
      return 'Kullanıcı adı $usernameMin-$usernameMax karakter olmalı.';
    }
    if (!_usernamePattern.hasMatch(v)) {
      return 'Yalnızca harf, rakam ve alt çizgi kullanılabilir.';
    }
    return null;
  }

  static String? displayName(String? value) {
    final int length = (value ?? '').trim().runes.length;
    if (length > displayNameMax) {
      return 'Görünen ad en fazla $displayNameMax karakter olabilir.';
    }
    return null;
  }

  static String? bio(String? value) {
    final int length = (value ?? '').trim().runes.length;
    if (length > bioMax) {
      return 'Biyografi en fazla $bioMax karakter olabilir.';
    }
    return null;
  }

  static String? city(String? value) {
    final int length = (value ?? '').trim().runes.length;
    if (length > cityMax) {
      return 'Şehir en fazla $cityMax karakter olabilir.';
    }
    return null;
  }
}
