import 'package:miyhav/core/errors/pet_error_mapper.dart';
import 'package:miyhav/features/pet/data/pet_repository.dart';
import 'package:miyhav/features/pet/domain/pet.dart';

/// Testlerde Supabase'e bağlanmadan kullanılan sahte [PetRepository].
class FakePetRepository implements PetRepository {
  FakePetRepository([List<Pet>? pets]) : _pets = pets ?? <Pet>[];

  final List<Pet> _pets;
  Object? throwOnFetch;
  int fetchCount = 0;
  PetDraft? lastCreate;
  PetDraft? lastUpdate;
  String? lastUpdateId;
  String? lastDeleteId;

  @override
  Future<List<Pet>> fetchMyPets() async {
    fetchCount++;
    final Object? err = throwOnFetch;
    if (err != null) throw PetErrorMapper.map(err);
    return List<Pet>.unmodifiable(_pets);
  }

  @override
  Future<Pet> createPet(PetDraft draft) async {
    lastCreate = draft;
    final Pet pet = _fromDraft('new-id', 'owner-me', draft);
    _pets.add(pet);
    return pet;
  }

  @override
  Future<Pet> updatePet(String id, PetDraft draft) async {
    lastUpdateId = id;
    lastUpdate = draft;
    return _fromDraft(id, 'owner-me', draft);
  }

  @override
  Future<void> deletePet(String id) async {
    lastDeleteId = id;
    _pets.removeWhere((Pet p) => p.id == id);
  }

  Pet _fromDraft(String id, String owner, PetDraft d) => Pet(
    id: id,
    ownerId: owner,
    name: d.name.trim(),
    type: d.type,
    breed: d.breed,
    sex: d.sex,
    birthDate: d.birthDate,
    isBirthDateEstimated: d.isBirthDateEstimated,
    color: d.color,
    currentWeight: d.currentWeight,
    shortDescription: d.shortDescription,
    microchipNumber: d.microchipNumber,
    isNeutered: d.isNeutered,
  );
}
