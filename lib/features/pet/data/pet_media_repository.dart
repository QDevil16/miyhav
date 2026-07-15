import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/pet_error_mapper.dart';

/// Pet profil fotoğrafının Storage nesne adı (bucket içindeki yol).
///
/// Tek dosya modeli: her pet için tek `profile.jpg`; her yükleme üzerine yazar.
/// Yolun ilk klasörü sahibin id'sidir (Storage RLS bunu doğrular).
String petProfilePhotoObjectName(String userId, String petId) =>
    '$userId/$petId/profile.jpg';

/// Pet fotoğrafı için Storage erişimi (private 'pets' bucket). UI'a Supabase
/// istemcisi sızmaz; hatalar Türkçe [PetFailure] olarak fırlatılır.
abstract interface class PetMediaRepository {
  /// Aktif kullanıcı için bu pet'in fotoğraf nesne adını üretir.
  String objectNameFor(String petId);

  /// Fotoğrafı yükler (aynı yolun üzerine yazar) ve nesne adını döner.
  Future<String> uploadProfilePhoto(String petId, Uint8List bytes);

  /// Fotoğrafı siler.
  Future<void> deleteProfilePhoto(String objectName);

  /// Görüntüleme için kısa ömürlü imzalı URL üretir (private bucket).
  Future<String> createSignedUrl(String objectName, {int expiresInSeconds});
}

/// [PetMediaRepository]'nin Supabase Storage uygulaması.
class SupabasePetMediaRepository implements PetMediaRepository {
  SupabasePetMediaRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'pets';

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) throw const PetFailure(PetErrorMapper.notAllowed);
    return id;
  }

  @override
  String objectNameFor(String petId) =>
      petProfilePhotoObjectName(_userId, petId);

  @override
  Future<String> uploadProfilePhoto(String petId, Uint8List bytes) async {
    try {
      final String name = objectNameFor(petId);
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            name,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      return name;
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteProfilePhoto(String objectName) async {
    try {
      await _client.storage.from(_bucket).remove(<String>[objectName]);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }

  @override
  Future<String> createSignedUrl(
    String objectName, {
    int expiresInSeconds = 3600,
  }) async {
    try {
      return await _client.storage
          .from(_bucket)
          .createSignedUrl(objectName, expiresInSeconds);
    } catch (error) {
      throw PetErrorMapper.map(error);
    }
  }
}
