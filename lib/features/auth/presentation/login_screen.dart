import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/auth_error_mapper.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_shell.dart';

/// Giriş ekranı — e-posta + şifre.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String? _formError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final String? emailError = AuthValidators.email(email);
    final String? passwordError = AuthValidators.password(password);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      // Başarılıysa auth durumu değişir → router otomatik ana ekrana yönlendirir.
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToVerify() {
    final String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      ref.read(pendingVerificationEmailProvider.notifier).state = email;
    }
    context.go(AppRoutes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Tekrar hoş geldin',
      subtitle: 'Hesabına giriş yap.',
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
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Şifre',
          hint: '••••••••',
          controller: _passwordController,
          obscure: true,
          prefixIcon: Icons.lock_outline_rounded,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthErrorText(_formError),
        PrimaryButton(
          label: 'Giriş Yap',
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: _loading
              ? null
              : () => context.go(AppRoutes.forgotPassword),
          child: const Text('Şifremi unuttum'),
        ),
        TextButton(
          onPressed: _loading ? null : _goToVerify,
          child: const Text('E-postamı doğrulayacağım'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Hesabın yok mu?'),
            TextButton(
              onPressed: _loading ? null : () => context.go(AppRoutes.register),
              child: const Text('Kayıt ol'),
            ),
          ],
        ),
      ],
    );
  }
}
