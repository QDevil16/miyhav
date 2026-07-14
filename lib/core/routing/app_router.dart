import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_shell.dart';

/// Uygulamanın GoRouter yapılandırmasını sağlar.
///
/// İskelet: uygulama kabuğu (alt navigasyon) tek rota olarak bağlanır. Gerçek
/// rotalar (splash, auth, pet detay vb.) ilgili görevlerde eklenecektir.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const MainShell(),
      ),
    ],
  );
});
