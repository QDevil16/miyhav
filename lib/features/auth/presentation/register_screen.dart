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
import '../data/auth_repository.dart';
import 'widgets/auth_shell.dart';

/// Kayıt ekranı — e-posta + şifre + şifre tekrarı.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;
  String? _formError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirm = _confirmController.text;

    final String? emailError = AuthValidators.email(email);
    final String? passwordError = AuthValidators.password(password);
    final String? confirmError = AuthValidators.passwordConfirm(
      confirm,
      password,
    );
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (emailError != null || passwordError != null || confirmError != null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final SignUpOutcome outcome = await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password);
      if (!mounted) return;
      if (outcome == SignUpOutcome.verificationRequired) {
        ref.read(pendingVerificationEmailProvider.notifier).state = email
            .trim();
        context.go(AppRoutes.verifyEmail);
      }
      // signedIn ise auth durumu değişir → router ana ekrana yönlendirir.
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Aramıza katıl',
      subtitle: 'Pet dostların için bir Miyhav hesabı oluştur.',
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
          hint: 'En az 8 karakter',
          controller: _passwordController,
          obscure: true,
          prefixIcon: Icons.lock_outline_rounded,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Şifre (tekrar)',
          hint: '••••••••',
          controller: _confirmController,
          obscure: true,
          prefixIcon: Icons.lock_outline_rounded,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthErrorText(_formError),
        PrimaryButton(
          label: 'Kayıt Ol',
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Zaten hesabın var mı?'),
            TextButton(
              onPressed: _loading ? null : () => context.go(AppRoutes.login),
              child: const Text('Giriş yap'),
            ),
          ],
        ),
      ],
    );
  }
}
