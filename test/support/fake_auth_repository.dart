import 'dart:async';

import 'package:miyhav/features/auth/data/auth_repository.dart';

/// Testlerde Supabase'e bağlanmadan kullanılan sahte [AuthRepository].
///
/// Başlangıç durumu verilir; [emit] ile durum, [emitEvent] ile auth olayı
/// (ör. şifre kurtarma) tetiklenebilir. Çağrılar kaydedilir.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._status, {String? email}) {
    _email = email;
  }

  AuthStatus _status;
  String? _email;
  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast();
  final StreamController<AuthEventKind> _eventController =
      StreamController<AuthEventKind>.broadcast();

  final List<String> calls = <String>[];
  SignUpOutcome signUpOutcome = SignUpOutcome.verificationRequired;
  Object? throwOnSignIn;
  Object? throwOnUpdatePassword;

  void emit(AuthStatus status, {String? email}) {
    _status = status;
    if (email != null) _email = email;
    _statusController.add(status);
  }

  void emitEvent(AuthEventKind event) => _eventController.add(event);

  @override
  AuthStatus get currentStatus => _status;

  @override
  String? get currentEmail => _email;

  @override
  Stream<AuthStatus> statusChanges() => _statusController.stream;

  @override
  Stream<AuthEventKind> authEvents() => _eventController.stream;

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp:$email');
    return signUpOutcome;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    calls.add('signIn:$email');
    final Object? err = throwOnSignIn;
    if (err != null) throw err;
    emit(AuthStatus.authenticated, email: email);
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emitEvent(AuthEventKind.signedOut);
    emit(AuthStatus.unauthenticated);
  }

  @override
  Future<void> resendVerification(String email) async {
    calls.add('resend:$email');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    calls.add('sendPasswordReset:$email');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    calls.add('updatePassword');
    final Object? err = throwOnUpdatePassword;
    if (err != null) throw err;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    calls.add('updateEmail:$newEmail');
  }

  void dispose() {
    _statusController.close();
    _eventController.close();
  }
}
