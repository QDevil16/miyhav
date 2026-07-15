import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
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

/// Yönlendirme için önemli auth olay türleri (deep link callback'leri dahil).
enum AuthEventKind {
  /// Şifre sıfırlama bağlantısı ile gelen kurtarma oturumu (normal giriş DEĞİL).
  passwordRecovery,

  /// Oturum açıldı (giriş veya e-posta doğrulama deep link'i).
  signedIn,

  /// Oturum kapandı.
  signedOut,

  /// Kullanıcı güncellendi (ör. şifre/e-posta değişimi).
  userUpdated,

  /// Diğer (initial session, token refresh vb.).
  other,
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

  /// Auth olaylarını yayınlar (şifre kurtarma deep link'i tespiti için).
  Stream<AuthEventKind> authEvents();

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

  /// Şifre sıfırlama bağlantısı gönder (deep link callback ile döner).
  Future<void> sendPasswordReset(String email);

  /// Aktif (kurtarma veya normal) oturumda yeni şifreyi ayarla.
  Future<void> updatePassword(String newPassword);

  /// Aktif oturumda e-posta adresini değiştir (yeni adrese onay gönderilir).
  Future<void> updateEmail(String newEmail);
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

  @override
  Stream<AuthEventKind> authEvents() =>
      _auth.onAuthStateChange.map((AuthState s) => _eventFrom(s.event));

  static AuthStatus _statusFrom(Session? session) {
    if (session == null) return AuthStatus.unauthenticated;
    final bool confirmed = session.user.emailConfirmedAt != null;
    return confirmed ? AuthStatus.authenticated : AuthStatus.unverified;
  }

  static AuthEventKind _eventFrom(AuthChangeEvent event) {
    switch (event) {
      case AuthChangeEvent.passwordRecovery:
        return AuthEventKind.passwordRecovery;
      case AuthChangeEvent.signedIn:
        return AuthEventKind.signedIn;
      case AuthChangeEvent.signedOut:
        return AuthEventKind.signedOut;
      case AuthChangeEvent.userUpdated:
        return AuthEventKind.userUpdated;
      default:
        return AuthEventKind.other;
    }
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
        // E-posta doğrulama bağlantısı uygulamayı bu deep link ile açar.
        emailRedirectTo: AppConfig.loginCallbackUrl,
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
      await _auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: AppConfig.loginCallbackUrl,
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: AppConfig.resetPasswordCallbackUrl,
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.updateUser(
        UserAttributes(email: newEmail.trim()),
        emailRedirectTo: AppConfig.loginCallbackUrl,
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }
}
