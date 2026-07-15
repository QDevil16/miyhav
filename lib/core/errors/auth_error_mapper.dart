import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Kullanıcıya gösterilebilir, Türkçe ve güvenli bir kimlik doğrulama hatası.
///
/// Ham Supabase/ağ hataları asla doğrudan arayüze gösterilmez (CLAUDE.md kural 6);
/// repository katmanı yakaladığı her hatayı [AuthErrorMapper.map] ile buna çevirir.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  /// Türkçe, kullanıcıya uygun mesaj.
  final String message;

  @override
  String toString() => 'AuthFailure(message: $message)';
}

/// Supabase Auth ve ağ hatalarını merkezî olarak Türkçe mesajlara çevirir.
///
/// Token, e-posta gibi hassas bilgi mesaja konmaz; yalnızca anlaşılır bir
/// yönlendirme verilir.
abstract final class AuthErrorMapper {
  static const String generic =
      'İşlem sırasında bir sorun oluştu. Lütfen tekrar dene.';
  static const String network =
      'İnternet bağlantını kontrol et ve tekrar dene.';
  static const String emailNotConfirmed =
      'E-posta adresin henüz doğrulanmadı. Gelen kutunu kontrol et.';

  /// Herhangi bir hatayı güvenli [AuthFailure]'a çevirir.
  static AuthFailure map(Object error) {
    if (error is AuthFailure) return error;
    return AuthFailure(_message(error));
  }

  static String _message(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return network;
    }
    if (error is AuthException) return _fromAuth(error);
    return generic;
  }

  static String _fromAuth(AuthException e) {
    final String code = (e.code ?? '').toLowerCase();
    final String msg = e.message.toLowerCase();

    bool has(String needle) => msg.contains(needle);

    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        has('already registered') ||
        has('already been registered')) {
      return 'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.';
    }
    if (code == 'invalid_credentials' || has('invalid login credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (code == 'email_not_confirmed' || has('email not confirmed')) {
      return emailNotConfirmed;
    }
    if (code == 'weak_password' ||
        code == 'password_too_short' ||
        (has('password') && (has('should be') || has('at least')))) {
      return 'Şifre yeterince güçlü değil. En az 8 karakter kullan.';
    }
    if (code == 'over_email_send_rate_limit' ||
        code == 'over_request_rate_limit' ||
        has('rate limit') ||
        has('for security purposes')) {
      return 'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar dene.';
    }
    if (code == 'validation_failed' ||
        has('unable to validate email') ||
        has('invalid email')) {
      return 'Geçerli bir e-posta adresi gir.';
    }
    if (has('network') || has('connection') || has('failed host lookup')) {
      return network;
    }
    return generic;
  }
}
