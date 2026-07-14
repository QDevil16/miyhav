import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

/// Uygulamanın kök widget'ı.
///
/// GoRouter tabanlı yönlendirme, Türkçe varsayılan dil ve Miyhav'ın özgün
/// tasarım sistemi (AppTheme) burada bağlanır.
class MiyhavApp extends ConsumerWidget {
  const MiyhavApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.displayTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // Varsayılan dil Türkçe; ileride İngilizce eklenecek.
      locale: const Locale('tr'),
      supportedLocales: const <Locale>[Locale('tr')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
