import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Uygulamanın GoRouter yapılandırmasını sağlar.
///
/// SETUP-001 iskeleti: yalnızca tek bir geçici karşılama rotası içerir.
/// Gerçek rotalar (splash, auth, ana akış vb.) ilgili görevlerde eklenecektir.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const _HomePlaceholderScreen(),
      ),
    ],
  );
});

/// Geçici karşılama ekranı. DESIGN-001 ve sonraki feature görevlerinde
/// gerçek ekranlarla değiştirilecektir.
class _HomePlaceholderScreen extends StatelessWidget {
  const _HomePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.pets, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Miyhav',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('Kurulum tamamlandı', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
