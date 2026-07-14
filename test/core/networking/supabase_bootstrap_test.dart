import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';
import 'package:miyhav/core/networking/supabase_bootstrap.dart';

void main() {
  test(
    'config yokken initialize missingConfig döner (ham hata fırlatmaz)',
    () async {
      // Testlerde dart-define verilmez → AppConfig.hasSupabaseConfig == false.
      final SupabaseStatus status = await SupabaseBootstrap.initialize();
      expect(status, SupabaseStatus.missingConfig);
    },
  );

  testWidgets('missingConfig durumunda kontrollü kurulum ekranı gösterilir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MiyhavApp(supabaseStatus: SupabaseStatus.missingConfig),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kurulum gerekli'), findsOneWidget);
    // Ana uygulama (alt navigasyon) gösterilmez.
    expect(find.text('Ana Sayfa'), findsNothing);
  });

  testWidgets('error durumunda kontrollü bağlantı ekranı gösterilir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MiyhavApp(supabaseStatus: SupabaseStatus.error),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bağlantı kurulamadı'), findsOneWidget);
  });
}
