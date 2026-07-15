import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/core/theme/app_theme.dart';
import 'package:miyhav/shared/widgets/app_button.dart';
import 'package:miyhav/shared/widgets/app_card.dart';
import 'package:miyhav/shared/widgets/default_profile_avatar.dart';
import 'package:miyhav/shared/widgets/empty_state.dart';
import 'package:miyhav/shared/widgets/pet_type_icon.dart';

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

  testWidgets('PetTypeIcon tüm türler için ikon gösterir', (
    WidgetTester tester,
  ) async {
    for (final PetType type in PetType.values) {
      await tester.pumpWidget(_wrap(PetTypeIcon(type: type, size: 64)));
      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, petTypeIconData(type));
    }
  });

  testWidgets('PetTypeIcon seçiliyken coral vurgu uygular', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const PetTypeIcon(type: PetType.cat, size: 64, selected: true)),
    );
    final Container box = tester.widget<Container>(
      find
          .ancestor(of: find.byType(Icon), matching: find.byType(Container))
          .first,
    );
    final BoxDecoration decoration = box.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('DefaultProfileAvatar pati ikonu gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(const DefaultProfileAvatar(size: 64)));
    expect(find.byType(Icon), findsOneWidget);
  });

  test('petTypeFromSpecies tür eşlemesi doğru', () {
    expect(petTypeFromSpecies('cat'), PetType.cat);
    expect(petTypeFromSpecies('dog'), PetType.dog);
    expect(petTypeFromSpecies('bird'), PetType.bird);
    expect(petTypeFromSpecies('rabbit'), PetType.rabbit);
    expect(petTypeFromSpecies('fish'), PetType.fish);
    expect(petTypeFromSpecies('reptile'), PetType.reptile);
    expect(petTypeFromSpecies('unknown'), PetType.other);
    expect(petTypeFromSpecies(null), PetType.other);
  });

  test('petTypeLabel Türkçe etiketler döner', () {
    expect(petTypeLabel(PetType.cat), 'Kedi');
    expect(petTypeLabel(PetType.reptile), 'Sürüngen');
    expect(petTypeLabel(PetType.other), 'Diğer');
  });
}
