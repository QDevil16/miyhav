import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/core/theme/app_theme.dart';
import 'package:miyhav/shared/widgets/app_button.dart';
import 'package:miyhav/shared/widgets/app_card.dart';
import 'package:miyhav/shared/widgets/empty_state.dart';
import 'package:miyhav/shared/widgets/pet_pixel_avatar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('PrimaryButton etiket gösterir ve dokunuşu iletir', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Kaydet', onPressed: () => taps++)),
    );
    expect(find.text('Kaydet'), findsOneWidget);
    await tester.tap(find.text('Kaydet'));
    expect(taps, 1);
  });

  testWidgets('AppCard çocuğunu render eder', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const AppCard(child: Text('kart içi'))));
    expect(find.text('kart içi'), findsOneWidget);
  });

  testWidgets('EmptyState başlık ve mesaj gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const EmptyState(title: 'Boş', message: 'içerik yok')),
    );
    expect(find.text('Boş'), findsOneWidget);
    expect(find.text('içerik yok'), findsOneWidget);
  });

  testWidgets('PetPixelAvatar tüm türler için çizilir', (
    WidgetTester tester,
  ) async {
    for (final PixelPetKind kind in PixelPetKind.values) {
      await tester.pumpWidget(_wrap(PetPixelAvatar(kind: kind, size: 64)));
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });

  test('pixelPetKindFromSpecies tür eşlemesi doğru', () {
    expect(pixelPetKindFromSpecies('cat'), PixelPetKind.cat);
    expect(pixelPetKindFromSpecies('dog'), PixelPetKind.dog);
    expect(pixelPetKindFromSpecies('fish'), PixelPetKind.other);
    expect(pixelPetKindFromSpecies(null), PixelPetKind.other);
  });
}
