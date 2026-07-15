import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/auth_error_mapper.dart';

/// Kullanıcının oturum + e-posta doğrulama durumu (yönlendirme için sadeleştirilir).
enum AuthStatus {
  /// Oturum yok.
  unauthenticated,

  /// Oturum var ama e-posta doğrulanmamış → ana uygulamaya geçemez.
  unverified,

  /// Oturum var ve e-posta doğrulanmış.
  authenticated,
}

/// Kayıt sonucunun sonucu.
enum SignUpOutcome {
  /// E-posta doğrulaması gerekiyor (doğrulama bağlantısı gönderildi).
  verificationRequired,

  /// Doğrudan oturum açıldı (doğrulama kapalıysa).
  signedIn,
}

/// Kimlik doğrulama işlemleri için soyut arayüz.
///
/// Ekranlar/servisler yalnızca bu arayüze bağlanır; testlerde sahte bir uygulama
/// ile değiştirilebilir. Tüm hatalar Türkçe [AuthFailure] olarak fırlatılır.
abstract interface class AuthRepository {
  /// O anki oturum/doğrulama durumu (senkron; yönlendirme kararında kullanılır).
  AuthStatus get currentStatus;

  /// Aktif kullanıcının e-postası (varsa).
  String? get currentEmail;

  /// Durum değişimlerini yayınlar (GoRouter yenilemesi için).
  Stream<AuthStatus> statusChanges();

  /// E-posta + şifre ile kayıt.
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  });

  /// E-posta + şifre ile giriş.
  Future<void> signIn({required String email, required String password});

  /// Oturumu kapat.
  Future<void> signOut();

  /// Doğrulama e-postasını yeniden gönder.
  Future<void> resendVerification(String email);
}

/// [AuthRepository]'nin Supabase Auth uygulaması.
///
/// Yalnızca public anon/publishable key ile çalışan istemciyi kullanır;
/// `service_role` key bulunmaz. Oturum kalıcılığı supabase_flutter tarafından
/// otomatik sağlanır (uygulama açık kalır).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  AuthStatus get currentStatus => _statusFrom(_auth.currentSession);

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  Stream<AuthStatus> statusChanges() =>
      _auth.onAuthStateChange.map((AuthState s) => _statusFrom(s.session));

  static AuthStatus _statusFrom(Session? session) {
    if (session == null) return AuthStatus.unauthenticated;
    final bool confirmed = session.user.emailConfirmedAt != null;
    return confirmed ? AuthStatus.authenticated : AuthStatus.unverified;
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      final bool confirmed =
          res.session != null && res.user?.emailConfirmedAt != null;
      return confirmed
          ? SignUpOutcome.signedIn
          : SignUpOutcome.verificationRequired;
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(email: email.trim(), password: password);
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email.trim());
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }
}
