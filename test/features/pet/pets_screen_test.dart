import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/core/errors/pet_error_mapper.dart';
import 'package:miyhav/features/pet/application/pet_providers.dart';
import 'package:miyhav/features/pet/domain/pet.dart';
import 'package:miyhav/features/pet/presentation/pet_form_screen.dart';
import 'package:miyhav/features/pet/presentation/pets_screen.dart';
import 'package:miyhav/shared/widgets/pet_type_icon.dart';

import '../../support/fake_pet_repository.dart';

const Pet _sample = Pet(
  id: 'p1',
  ownerId: 'u1',
  name: 'Pamuk',
  type: PetType.cat,
  breed: 'Tekir',
);

void main() {
  testWidgets('petler yüklenirken loading gösterir', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myPetsProvider.overrideWith((ref) => Completer<List<Pet>>().future),
        ],
        child: const MaterialApp(home: Scaffold(body: PetsScreen())),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('pet yoksa boş durum ve Pet Ekle gösterir', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myPetsProvider.overrideWith((ref) async => <Pet>[]),
        ],
        child: const MaterialApp(home: Scaffold(body: PetsScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Henüz pet eklemedin'), findsOneWidget);
    expect(find.text('Pet Ekle'), findsOneWidget);
  });

  testWidgets('petler listelenir (ad + tür)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myPetsProvider.overrideWith((ref) async => <Pet>[_sample]),
        ],
        child: const MaterialApp(home: Scaffold(body: PetsScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pamuk'), findsOneWidget);
    expect(find.textContaining('Kedi'), findsOneWidget);
  });

  testWidgets('hata durumunda retry gösterir ve yeniden dener', (tester) async {
    int calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myPetsProvider.overrideWith((ref) async {
            calls++;
            if (calls == 1) throw const PetFailure(PetErrorMapper.generic);
            return <Pet>[_sample];
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: PetsScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tekrar dene'), findsOneWidget);
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(find.text('Pamuk'), findsOneWidget);
  });

  testWidgets('form: yeni pet oluşturma repository createPet çağırır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final FakePetRepository repo = FakePetRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[petRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PetFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Pamuk');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(repo.lastCreate?.name, 'Pamuk');
    expect(repo.lastCreate?.type, PetType.cat);
  });

  testWidgets('form: düzenlemede Peti Sil onaydan sonra deletePet çağırır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final FakePetRepository repo = FakePetRepository(<Pet>[_sample]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[petRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PetFormScreen(pet: _sample)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Peti Sil'));
    await tester.pumpAndSettle();
    // Onay diyaloğu
    await tester.tap(find.widgetWithText(TextButton, 'Sil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repo.lastDeleteId, 'p1');
  });
}
