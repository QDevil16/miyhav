import '../../../shared/widgets/pet_type_icon.dart';

/// Petin cinsiyeti (opsiyonel).
enum PetSex {
  male('male', 'Erkek'),
  female('female', 'Dişi'),
  unknown('unknown', 'Bilinmiyor');

  const PetSex(this.wire, this.label);

  final String wire;
  final String label;

  static PetSex? fromWire(String? value) {
    if (value == null) return null;
    for (final PetSex s in PetSex.values) {
      if (s.wire == value) return s;
    }
    return null;
  }
}

/// Kullanıcının kendi petinin ÖZEL verisi (yalnızca sahibe açık).
class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.breed,
    this.sex,
    this.birthDate,
    this.isBirthDateEstimated = false,
    this.color,
    this.currentWeight,
    this.profilePhotoPath,
    this.shortDescription,
    this.microchipNumber,
    this.isNeutered,
  });

  final String id;
  final String ownerId;
  final String name;
  final PetType type;
  final String? breed;
  final PetSex? sex;
  final DateTime? birthDate;
  final bool isBirthDateEstimated;
  final String? color;
  final double? currentWeight;
  final String? profilePhotoPath;
  final String? shortDescription;
  final String? microchipNumber;
  final bool? isNeutered;

  factory Pet.fromMap(Map<String, dynamic> map) {
    String? clean(Object? v) {
      if (v is! String) return null;
      final String t = v.trim();
      return t.isEmpty ? null : t;
    }

    double? toDouble(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? toDate(Object? v) {
      if (v is! String || v.isEmpty) return null;
      return DateTime.tryParse(v);
    }

    return Pet(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: (map['name'] as String? ?? '').trim(),
      type: petTypeFromSpecies(map['species'] as String?),
      breed: clean(map['breed']),
      sex: PetSex.fromWire(map['sex'] as String?),
      birthDate: toDate(map['birth_date']),
      isBirthDateEstimated: (map['is_birth_date_estimated'] as bool?) ?? false,
      color: clean(map['color']),
      currentWeight: toDouble(map['current_weight']),
      profilePhotoPath: map['profile_photo_path'] as String?,
      shortDescription: clean(map['short_description']),
      microchipNumber: clean(map['microchip_number']),
      isNeutered: map['is_neutered'] as bool?,
    );
  }

  String get speciesLabel => petTypeLabel(type);
}

/// Kullanıcının form üzerinden girdiği düzenlenebilir pet alanları.
///
/// `owner_id` ve `id` BURADA YOKTUR — sahiplik yalnızca oturumdan gelir ve
/// istemci tarafından değiştirilemez.
class PetDraft {
  const PetDraft({
    required this.name,
    required this.type,
    this.breed,
    this.sex,
    this.birthDate,
    this.isBirthDateEstimated = false,
    this.color,
    this.currentWeight,
    this.shortDescription,
    this.microchipNumber,
    this.isNeutered,
  });

  final String name;
  final PetType type;
  final String? breed;
  final PetSex? sex;
  final DateTime? birthDate;
  final bool isBirthDateEstimated;
  final String? color;
  final double? currentWeight;
  final String? shortDescription;
  final String? microchipNumber;
  final bool? isNeutered;
}
