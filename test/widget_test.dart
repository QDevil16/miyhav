import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';

void main() {
  testWidgets('MiyhavApp açılır, tema ve alt navigasyon render edilir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MiyhavApp()));
    await tester.pumpAndSettle();

    // Seçili sekme başlığı (app bar + alt navigasyon etiketi) görünür.
    expect(find.text('Ana Sayfa'), findsWidgets);

    // Tema Jost fontunu kullanıyor.
    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.theme?.textTheme.bodyLarge?.fontFamily, 'Jost');

    // Alt navigasyonda sekme geçişi çalışıyor (seçili olmayan sekme ikonla).
    await tester.tap(find.byIcon(Icons.pets_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Henüz pet eklemedin'), findsOneWidget);
    expect(find.text('Petlerim'), findsWidgets); // seçilince etiket görünür
  });
}
