import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/features/pet/application/pet_providers.dart';
import 'package:miyhav/features/pet/data/pet_media_repository.dart';
import 'package:miyhav/features/pet/data/pet_photo_picker.dart';
import 'package:miyhav/features/pet/domain/pet.dart';
import 'package:miyhav/features/pet/presentation/pet_form_screen.dart';
import 'package:miyhav/shared/widgets/pet_type_icon.dart';

import '../../support/fake_pet_media.dart';
import '../../support/fake_pet_repository.dart';

const Pet _petNoPhoto = Pet(
  id: 'p1',
  ownerId: 'u1',
  name: 'Pamuk',
  type: PetType.cat,
);
const Pet _petWithPhoto = Pet(
  id: 'p1',
  ownerId: 'u1',
  name: 'Pamuk',
  type: PetType.cat,
  profilePhotoPath: 'u1/p1/profile.jpg',
);

void main() {
  test('petProfilePhotoObjectName tek dosya yolu üretir', () {
    expect(petProfilePhotoObjectName('u1', 'p1'), 'u1/p1/profile.jpg');
  });

  testWidgets('Fotoğraf Ekle: seç → upload → path kaydet', (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final FakePetRepository petRepo = FakePetRepository(<Pet>[_petNoPhoto]);
    final FakePetMediaRepository media = FakePetMediaRepository()..userId = 'u1';
    final FakePetPhotoPicker picker = FakePetPhotoPicker(
      result: Uint8List.fromList(<int>[1, 2, 3]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          petRepositoryProvider.overrideWithValue(petRepo),
          petMediaRepositoryProvider.overrideWithValue(media),
          petPhotoPickerProvider.overrideWithValue(picker),
        ],
        child: const MaterialApp(home: PetFormScreen(pet: _petNoPhoto)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fotoğraf Ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeriden seç'));
    await tester.pumpAndSettle();

    expect(picker.lastSource, PhotoSource.gallery);
    expect(media.uploadCount, 1);
    expect(media.lastUploadPetId, 'p1');
    expect(petRepo.lastPhotoPath, 'u1/p1/profile.jpg');
  });

  testWidgets('Fotoğraf Sil: storage + path temizlenir', (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final FakePetRepository petRepo = FakePetRepository(<Pet>[_petWithPhoto]);
    final FakePetMediaRepository media = FakePetMediaRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          petRepositoryProvider.overrideWithValue(petRepo),
          petMediaRepositoryProvider.overrideWithValue(media),
        ],
        child: const MaterialApp(home: PetFormScreen(pet: _petWithPhoto)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fotoğraf Sil'));
    await tester.pumpAndSettle();

    expect(media.lastDeleteName, 'u1/p1/profile.jpg');
    expect(petRepo.photoPathWasSet, isTrue);
    expect(petRepo.lastPhotoPath, isNull);
  });
}
