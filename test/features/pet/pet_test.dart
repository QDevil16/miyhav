import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/core/validation/pet_validators.dart';
import 'package:miyhav/features/pet/data/pet_repository.dart';
import 'package:miyhav/features/pet/domain/pet.dart';
import 'package:miyhav/shared/widgets/pet_type_icon.dart';

void main() {
  group('Pet.fromMap', () {
    test('Supabase satırını doğru parse eder', () {
      final Pet p = Pet.fromMap(<String, dynamic>{
        'id': 'p1',
        'owner_id': 'u1',
        'name': ' Pamuk ',
        'species': 'cat',
        'breed': 'Tekir',
        'sex': 'female',
        'birth_date': '2022-03-15',
        'is_birth_date_estimated': true,
        'color': 'Beyaz',
        'current_weight': 4.2,
        'short_description': 'Sevimli',
        'microchip_number': 'MC123',
        'is_neutered': true,
      });
      expect(p.id, 'p1');
      expect(p.ownerId, 'u1');
      expect(p.name, 'Pamuk');
      expect(p.type, PetType.cat);
      expect(p.sex, PetSex.female);
      expect(p.birthDate, DateTime(2022, 3, 15));
      expect(p.isBirthDateEstimated, isTrue);
      expect(p.currentWeight, 4.2);
      expect(p.isNeutered, isTrue);
      expect(p.speciesLabel, 'Kedi');
    });

    test('numeric ağırlık string olarak da parse edilir', () {
      final Pet p = Pet.fromMap(<String, dynamic>{
        'id': 'p2',
        'owner_id': 'u1',
        'name': 'Boncuk',
        'species': 'unknown-species',
        'current_weight': '3.5',
      });
      expect(p.type, PetType.other); // bilinmeyen tür → other
      expect(p.currentWeight, 3.5);
      expect(p.sex, isNull);
      expect(p.birthDate, isNull);
    });
  });

  group('PetSex', () {
    test('etiketler doğru', () {
      expect(PetSex.male.label, 'Erkek');
      expect(PetSex.female.label, 'Dişi');
      expect(PetSex.unknown.label, 'Bilinmiyor');
      expect(PetSex.fromWire(null), isNull);
      expect(PetSex.fromWire('female'), PetSex.female);
    });
  });

  group('PetValidators', () {
    test('ad zorunlu ve 40 üstü reddedilir', () {
      expect(PetValidators.name(''), isNotNull);
      expect(PetValidators.name('   '), isNotNull);
      expect(PetValidators.name('Pamuk'), isNull);
      expect(PetValidators.name('a' * 41), isNotNull);
    });
    test('ağırlık: geçersiz/aralık dışı reddedilir, boş kabul', () {
      expect(PetValidators.weight(''), isNull);
      expect(PetValidators.weight('abc'), isNotNull);
      expect(PetValidators.weight('0'), isNotNull);
      expect(PetValidators.weight('999'), isNotNull);
      expect(PetValidators.weight('4.5'), isNull);
      expect(PetValidators.weight('4,5'), isNull); // virgül desteklenir
      expect(PetValidators.parseWeight('4,5'), 4.5);
    });
    test('breed/color/desc/microchip uzunlukları', () {
      expect(PetValidators.breed('a' * 41), isNotNull);
      expect(PetValidators.color('a' * 31), isNotNull);
      expect(PetValidators.description('a' * 201), isNotNull);
      expect(PetValidators.microchip('a' * 31), isNotNull);
    });
  });

  group('buildPetWrite', () {
    test('owner_id ve id İÇERMEZ; species wire; alanlar temiz', () {
      final Map<String, dynamic> payload = buildPetWrite(
        PetDraft(
          name: ' Pamuk ',
          type: PetType.reptile,
          breed: '  ',
          sex: PetSex.male,
          birthDate: DateTime(2021, 5, 1),
          isBirthDateEstimated: true,
          color: 'Yeşil',
          currentWeight: 1.2,
          shortDescription: '',
          microchipNumber: 'MC9',
          isNeutered: false,
        ),
      );
      expect(payload.containsKey('owner_id'), isFalse);
      expect(payload.containsKey('id'), isFalse);
      expect(payload['name'], 'Pamuk');
      expect(payload['species'], 'reptile');
      expect(payload['sex'], 'male');
      expect(payload['birth_date'], '2021-05-01');
      expect(payload['is_birth_date_estimated'], isTrue);
      expect(payload['breed'], isNull); // boş → null
      expect(payload['short_description'], isNull);
      expect(payload['current_weight'], 1.2);
    });
  });
}
