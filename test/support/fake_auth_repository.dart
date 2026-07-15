import 'dart:async';

import 'package:miyhav/features/auth/data/auth_repository.dart';

/// Testlerde Supabase'e bağlanmadan kullanılan sahte [AuthRepository].
///
/// Başlangıç durumu verilir; [emit] ile durum değiştirilip router yönlendirmesi
/// tetiklenebilir. Çağrılar kaydedilir.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._status, {String? email}) {
    _email = email;
  }

  AuthStatus _status;
  String? _email;
  final StreamController<AuthStatus> _controller =
      StreamController<AuthStatus>.broadcast();

  final List<String> calls = <String>[];
  SignUpOutcome signUpOutcome = SignUpOutcome.verificationRequired;
  Object? throwOnSignIn;

  void emit(AuthStatus status, {String? email}) {
    _status = status;
    if (email != null) _email = email;
    _controller.add(status);
  }

  @override
  AuthStatus get currentStatus => _status;

  @override
  String? get currentEmail => _email;

  @override
  Stream<AuthStatus> statusChanges() => _controller.stream;

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
    emit(AuthStatus.unauthenticated);
  }

  @override
  Future<void> resendVerification(String email) async {
    calls.add('resend:$email');
  }

  void dispose() => _controller.close();
}
