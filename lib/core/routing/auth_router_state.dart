import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';

/// GoRouter'ın yönlendirmesini besleyen auth durumu.
///
/// Hem oturum/doğrulama durumunu ([status]) hem de şifre kurtarma modunu
/// ([recovery]) izler. Şifre sıfırlama deep link'i geldiğinde
/// [AuthEventKind.passwordRecovery] yakalanır ve kurtarma modu açılır; bu oturum
/// normal giriş gibi yorumlanmaz (yalnızca yeni şifre ekranına gidilir).
/// Değişince [notifyListeners] ile router yeniden değerlendirilir.
class AuthRouterState extends ChangeNotifier {
  AuthRouterState(this._repo) : _status = _repo.currentStatus {
    _statusSub = _repo.statusChanges().listen((AuthStatus s) {
      if (s == _status) return;
      _status = s;
      notifyListeners();
    });
    _eventSub = _repo.authEvents().listen((AuthEventKind e) {
      if (e == AuthEventKind.passwordRecovery && !_recovery) {
        _recovery = true;
        notifyListeners();
      } else if (e == AuthEventKind.signedOut && _recovery) {
        _recovery = false;
        notifyListeners();
      }
    });
  }

  final AuthRepository _repo;
  AuthStatus _status;
  bool _recovery = false;

  late final StreamSubscription<AuthStatus> _statusSub;
  late final StreamSubscription<AuthEventKind> _eventSub;

  AuthStatus get status => _status;

  /// Şifre kurtarma modu aktif mi? (yalnızca yeni şifre ekranı gösterilir)
  bool get recovery => _recovery;

  @override
  void dispose() {
    _statusSub.cancel();
    _eventSub.cancel();
    super.dispose();
  }
}
