import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/app_router.dart';

/// Uygulamanın kök widget'ı.
///
/// Bu aşama (SETUP-001) yalnızca iskelet kurar: GoRouter tabanlı yönlendirme,
/// Türkçe varsayılan dil ve geçici bir Material 3 tema. Tam tasarım sistemi
/// (renkler, tipografi, bileşenler) DESIGN-001 görevinde eklenecektir.
class MiyhavApp extends ConsumerWidget {
  const MiyhavApp({super.key});

  static const String appTitle = 'Miyhav';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: appTitle,
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD08D79), // Miyhav soft coral (geçici seed)
        ),
      ),
    );
  }
}
