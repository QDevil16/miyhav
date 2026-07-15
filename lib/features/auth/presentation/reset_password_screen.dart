import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/auth_error_mapper.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/auth_validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_shell.dart';

/// Yeni şifre ekranı — şifre sıfırlama deep link'i (kurtarma modu) sonrası açılır.
///
/// Kurtarma oturumu normal giriş gibi yorumlanmaz: başarıyla güncellendikten
/// sonra oturum kapatılır ve kullanıcı yeni şifresiyle giriş yapar.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;
  String? _formError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String password = _passwordController.text;
    final String confirm = _confirmController.text;

    final String? passwordError = AuthValidators.password(password);
    final String? confirmError = AuthValidators.passwordConfirm(
      confirm,
      password,
    );
    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (passwordError != null || confirmError != null) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(password);
      if (!mounted) return;
      // Kurtarma oturumunu kapat → kullanıcı yeni şifresiyle giriş yapar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.',
            ),
          ),
        );
      await ref.read(authRepositoryProvider).signOut();
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
      title: 'Yeni şifre belirle',
      subtitle: 'Hesabın için yeni bir şifre oluştur.',
      children: <Widget>[
        AppTextField(
          label: 'Yeni şifre',
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
          label: 'Yeni şifre (tekrar)',
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
          label: 'Şifreyi güncelle',
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
      ],
    );
  }
}
