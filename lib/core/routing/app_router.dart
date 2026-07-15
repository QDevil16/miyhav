import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_shell.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import 'auth_router_state.dart';

/// Rota yolları (tek merkez).
abstract final class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  /// Oturum açmamış kullanıcıya izin verilen yollar. (reset-password yalnızca
  /// şifre kurtarma modunda erişilebilir; burada yer almaz.)
  static const Set<String> _public = <String>{
    login,
    register,
    verifyEmail,
    forgotPassword,
  };

  static bool isPublic(String location) => _public.contains(location);
}

/// Uygulamanın GoRouter yapılandırması. Auth durumuna göre yönlendirir:
/// doğrulanmamış kullanıcı ana uygulamaya geçemez; şifre kurtarma modunda yalnızca
/// yeni şifre ekranı gösterilir (CLAUDE.md / AUTH_EMAIL_MODEL).
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final AuthRepository auth = ref.watch(authRepositoryProvider);
  final AuthRouterState authState = AuthRouterState(auth);
  ref.onDispose(authState.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authState,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;

      // Şifre kurtarma her şeyin önündedir: yalnızca yeni şifre ekranı.
      if (authState.recovery) {
        return location == AppRoutes.resetPassword
            ? null
            : AppRoutes.resetPassword;
      }

      switch (authState.status) {
        case AuthStatus.authenticated:
          // Girişli kullanıcı auth/reset ekranlarında kalamaz.
          return (AppRoutes.isPublic(location) ||
                  location == AppRoutes.resetPassword)
              ? AppRoutes.home
              : null;
        case AuthStatus.unverified:
          return location == AppRoutes.verifyEmail
              ? null
              : AppRoutes.verifyEmail;
        case AuthStatus.unauthenticated:
          return AppRoutes.isPublic(location) ? null : AppRoutes.login;
      }
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const MainShell(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verifyEmail',
        builder: (BuildContext context, GoRouterState state) =>
            const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        builder: (BuildContext context, GoRouterState state) =>
            const ResetPasswordScreen(),
      ),
    ],
  );
});
