import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/networking/supabase_bootstrap.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import 'supabase_status_screen.dart';

/// Uygulamanın kök widget'ı.
///
/// GoRouter tabanlı yönlendirme, Türkçe varsayılan dil ve Miyhav'ın özgün
/// tasarım sistemi (AppTheme) burada bağlanır. Supabase hazır değilse ham hata
/// yerine kontrollü bir durum ekranı gösterilir.
class MiyhavApp extends ConsumerWidget {
  const MiyhavApp({super.key, this.supabaseStatus = SupabaseStatus.ready});

  final SupabaseStatus supabaseStatus;

  static const List<LocalizationsDelegate<dynamic>> _localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const List<Locale> _supportedLocales = <Locale>[Locale('tr')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Supabase hazır değilse router'a girmeden kontrollü ekran göster.
    if (supabaseStatus != SupabaseStatus.ready) {
      return MaterialApp(
        title: AppConfig.displayTitle,
        debugShowCheckedModeBanner: false,
        locale: const Locale('tr'),
        supportedLocales: _supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: SupabaseStatusScreen(status: supabaseStatus),
      );
    }

    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppConfig.displayTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: const Locale('tr'),
      supportedLocales: _supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
