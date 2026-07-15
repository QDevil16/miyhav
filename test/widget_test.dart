import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';
import 'package:miyhav/features/auth/application/auth_providers.dart';
import 'package:miyhav/features/auth/data/auth_repository.dart';
import 'package:miyhav/features/pet/application/pet_providers.dart';
import 'package:miyhav/features/pet/domain/pet.dart';

import 'support/fake_auth_repository.dart';

void main() {
  testWidgets('Girişli kullanıcıda tema ve alt navigasyon render edilir', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.authenticated,
      email: 'test@miyhav.app',
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(auth),
          myPetsProvider.overrideWith((ref) async => <Pet>[]),
        ],
        child: const MiyhavApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Seçili sekme başlığı (app bar + alt navigasyon etiketi) görünür.
    expect(find.text('Ana Sayfa'), findsWidgets);

    // Tema Jost fontunu kullanıyor.
    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.theme?.textTheme.bodyLarge?.fontFamily, 'Jost');

    // Alt navigasyonda sekme geçişi çalışıyor.
    await tester.tap(find.byIcon(Icons.pets_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Henüz pet eklemedin'), findsOneWidget);
    expect(find.text('Petlerim'), findsWidgets);
  });
}
