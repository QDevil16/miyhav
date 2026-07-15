import 'dart:typed_data';

import 'package:miyhav/features/pet/data/pet_media_repository.dart';
import 'package:miyhav/features/pet/data/pet_photo_picker.dart';

/// Sahte Storage medya deposu (testlerde).
class FakePetMediaRepository implements PetMediaRepository {
  int uploadCount = 0;
  String? lastUploadPetId;
  String? lastDeleteName;
  String userId = 'owner-me';

  @override
  String objectNameFor(String petId) =>
      petProfilePhotoObjectName(userId, petId);

  @override
  Future<String> uploadProfilePhoto(String petId, Uint8List bytes) async {
    uploadCount++;
    lastUploadPetId = petId;
    return objectNameFor(petId);
  }

  @override
  Future<void> deleteProfilePhoto(String objectName) async {
    lastDeleteName = objectName;
  }

  @override
  Future<String> createSignedUrl(
    String objectName, {
    int expiresInSeconds = 3600,
  }) async {
    return 'https://example.test/$objectName';
  }
}

/// Sahte fotoğraf seçici (kamera/galeri + kırpma yerine sabit byte döner).
class FakePetPhotoPicker implements PetPhotoPicker {
  FakePetPhotoPicker({this.result});

  /// null → kullanıcı vazgeçti; doluysa seçilen byte'lar.
  Uint8List? result;
  PhotoSource? lastSource;

  @override
  Future<Uint8List?> pickAndCrop(PhotoSource source) async {
    lastSource = source;
    return result;
  }
}
