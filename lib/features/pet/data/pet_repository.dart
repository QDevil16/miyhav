import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/pet_error_mapper.dart';
import '../domain/pet.dart';

/// Bir [PetDraft]'tan yalnızca DÜZENLENEBİLİR pet kolonlarını içeren yazma map'i.
///
/// `owner_id` ve `id` ASLA yer almaz — sahiplik oturumdan (`auth.uid()`) gelir,
/// istemci tarafından set edilemez/değiştirilemez (RLS + trigger ile de korunur).
Map<String, dynamic> buildPetWrite(PetDraft draft) {
  String? clean(String? v) {
    final String t = (v ?? '').trim();
    return t.isEmpty ? null : t;
  }

  return <String, dynamic>{
    'name': draft.name.trim(),
    'species': draft.type.name,
    'breed': clean(draft.breed),
    'sex': draft.sex?.wire,
    'birth_date': draft.birthDate?.toIso8601String().split('T').first,
    'is_birth_date_estimated': draft.isBirthDateEstimated,
    'color': clean(draft.color),
    'current_weight': draft.currentWeight,
    'short_description': clean(draft.shortDescription),
    'microchip_number': clean(draft.microchipNumber),
    'is_neutered': draft.isNeutered,
  };
}

/// Pet verisi için soyut arayüz. UI yalnızca buna bağlanır; Supabase istemcisi
/// ekranlara sızmaz. Hatalar Türkçe [PetFailure] olarak fırlatılır.
abstract interface class PetRepository {
  /// Oturum açmış kullanıcının kendi petleri (RLS ile yalnızca kendi satırları).
  Future<List<Pet>> fetchMyPets();

  /// Yeni pet oluşturur (owner_id her zaman aktif kullanıcı).
  Future<Pet> createPet(PetDraft draft);

  /// Kendi petini günceller (owner_id değiştirilemez).
  Future<Pet> updatePet(String id, PetDraft draft);

  /// Kendi petini siler.
  Future<void> deletePet(String id);

  /// Yalnızca `profile_photo_path` kolonunu günceller (fotoğraf ekle/sil sonrası).
  Future<void> setProfilePhotoPath(String id, String? path);
}

/// [PetRepository]'nin Supabase uygulaması. RLS gereği yalnızca kullanıcının kendi
/// petleri okunur/yazılır; owner_id insert'te auth oturumundan gelir.
class SupabasePetRepository implements PetRepository {
  SupabasePetRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'pets';

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) throw const PetFailure(PetErrorMapper.notAllowed);
    return id;
  }

  @override
  Future<List<Pet>> fetchMyPets() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from(_table)
          .select()
          .order('created_at');
      return rows.map(Pet.fromMap).toList(growable: false);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<Pet> createPet(PetDraft draft) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        ...buildPetWrite(draft),
        // Sahiplik yalnızca oturumdan; istemci başka değer veremez (RLS with check).
        'owner_id': _userId,
      };
      final Map<String, dynamic> data = await _client
          .from(_table)
          .insert(payload)
          .select()
          .single();
      return Pet.fromMap(data);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<Pet> updatePet(String id, PetDraft draft) async {
    try {
      final Map<String, dynamic> data = await _client
          .from(_table)
          .update(buildPetWrite(draft))
          .eq('id', id)
          .select()
          .single();
      return Pet.fromMap(data);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<void> deletePet(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<void> setProfilePhotoPath(String id, String? path) async {
    try {
      await _client
          .from(_table)
          .update(<String, dynamic>{'profile_photo_path': path})
          .eq('id', id);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }
}
