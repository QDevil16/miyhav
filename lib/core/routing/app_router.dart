import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_shell.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import 'go_router_refresh_stream.dart';

/// Rota yolları (tek merkez).
abstract final class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';

  /// Oturum açmamış kullanıcıya izin verilen yollar.
  static const Set<String> _public = <String>{login, register, verifyEmail};

  static bool isPublic(String location) => _public.contains(location);
}

/// Uygulamanın GoRouter yapılandırması. Auth durumuna göre yönlendirir:
/// doğrulanmamış kullanıcı ana uygulamaya geçemez (CLAUDE.md / AUTH_EMAIL_MODEL).
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final AuthRepository auth = ref.watch(authRepositoryProvider);
  final GoRouterRefreshStream refresh = GoRouterRefreshStream(
    auth.statusChanges(),
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = auth.currentStatus;
      final String location = state.matchedLocation;

      switch (status) {
        case AuthStatus.authenticated:
          // Girişli kullanıcı auth ekranlarında kalamaz.
          return AppRoutes.isPublic(location) ? AppRoutes.home : null;
        case AuthStatus.unverified:
          // Oturum var ama doğrulanmamış → yalnızca doğrulama ekranı.
          return location == AppRoutes.verifyEmail
              ? null
              : AppRoutes.verifyEmail;
        case AuthStatus.unauthenticated:
          // Oturum yok → yalnızca genel (auth) ekranlar.
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
    ],
  );
});
