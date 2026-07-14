import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';

void main() {
  testWidgets('MiyhavApp iskeleti karşılama ekranını gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MiyhavApp()));
    await tester.pumpAndSettle();

    // Marka adı ve pet ikonu görünmeli.
    expect(find.text('Miyhav'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });
}
