import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/auth_error_mapper.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_shell.dart';

/// Şifremi unuttum ekranı — e-posta ile sıfırlama bağlantısı ister.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String? _formError;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailController.text;
    final String? emailError = AuthValidators.email(email);
    setState(() {
      _emailError = emailError;
      _formError = null;
    });
    if (emailError != null) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (_sent) {
      return AuthShell(
        title: 'Bağlantı gönderildi',
        subtitle: 'Gelen kutunu kontrol et.',
        children: <Widget>[
          Icon(Icons.mark_email_read_rounded, size: 48, color: scheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${_emailController.text.trim()} adresine bir şifre sıfırlama '
            'bağlantısı gönderdik. Bağlantıya tıklayıp yeni şifreni belirle.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Giriş ekranına dön',
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      );
    }

    return AuthShell(
      title: 'Şifreni mi unuttun?',
      subtitle: 'E-postanı gir, sıfırlama bağlantısı gönderelim.',
      children: <Widget>[
        AppTextField(
          label: 'E-posta',
          hint: 'ornek@eposta.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthErrorText(_formError),
        PrimaryButton(
          label: 'Bağlantı gönder',
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: _loading ? null : () => context.go(AppRoutes.login),
          child: const Text('Girişe dön'),
        ),
      ],
    );
  }
}
