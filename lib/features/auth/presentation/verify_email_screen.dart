import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/auth_error_mapper.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';
import 'widgets/auth_shell.dart';

/// E-posta doğrulama bekleme ekranı.
///
/// Kayıt sonrası gösterilir: kullanıcı gelen kutusundaki bağlantıya tıklamadan
/// ana uygulamaya geçemez. Doğrulama e-postasını tekrar gönderebilir.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _sending = false;

  String? get _email {
    final String? pending = ref.read(pendingVerificationEmailProvider);
    if (pending != null && pending.isNotEmpty) return pending;
    return ref.read(authRepositoryProvider).currentEmail;
  }

  Future<void> _resend() async {
    final String? email = _email;
    if (email == null || email.isEmpty) {
      _snack('Önce e-posta adresinle kayıt ol veya giriş yap.');
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).resendVerification(email);
      if (mounted) _snack('Doğrulama e-postası tekrar gönderildi.');
    } on AuthFailure catch (failure) {
      if (mounted) _snack(failure.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _backToLogin() async {
    final AuthRepository auth = ref.read(authRepositoryProvider);
    // Doğrulanmamış bir oturum varsa önce kapat (yönlendirme login'e döner).
    if (auth.currentStatus == AuthStatus.unverified) {
      await auth.signOut();
      return;
    }
    if (mounted) context.go(AppRoutes.login);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String? email = ref.watch(pendingVerificationEmailProvider);

    final String description = (email != null && email.isNotEmpty)
        ? 'Doğrulama bağlantısını $email adresine gönderdik. '
              'Bağlantıya tıkladıktan sonra giriş yapabilirsin.'
        : 'Doğrulama bağlantısını e-posta adresine gönderdik. '
              'Bağlantıya tıkladıktan sonra giriş yapabilirsin.';

    return AuthShell(
      title: 'E-postanı doğrula',
      subtitle: 'Neredeyse hazırsın!',
      children: <Widget>[
        Icon(Icons.mark_email_unread_rounded, size: 48, color: scheme.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Giriş ekranına dön',
          onPressed: _sending ? null : _backToLogin,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: _sending ? 'Gönderiliyor…' : 'E-postayı tekrar gönder',
          onPressed: _sending ? null : _resend,
        ),
      ],
    );
  }
}
