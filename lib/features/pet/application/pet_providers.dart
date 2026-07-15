import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/supabase_bootstrap.dart';
import '../../profile/application/profile_providers.dart';
import '../data/pet_media_repository.dart';
import '../data/pet_photo_picker.dart';
import '../data/pet_repository.dart';
import '../domain/pet.dart';

/// Uygulama genelinde kullanılan [PetRepository].
final Provider<PetRepository> petRepositoryProvider = Provider<PetRepository>((
  ref,
) {
  return SupabasePetRepository(ref.watch(supabaseClientProvider));
});

/// Pet fotoğrafı Storage erişimi.
final Provider<PetMediaRepository> petMediaRepositoryProvider =
    Provider<PetMediaRepository>((ref) {
      return SupabasePetMediaRepository(ref.watch(supabaseClientProvider));
    });

/// Fotoğraf seç + kırp servisi (testlerde sahte ile değiştirilebilir).
final Provider<PetPhotoPicker> petPhotoPickerProvider =
    Provider<PetPhotoPicker>((ref) => ImagePickerCropper());

/// Oturum açmış kullanıcının kendi petleri. Auth durumu değişince yeniden yüklenir;
/// ekleme/güncelleme/silme sonrası `ref.invalidate` ile tazelenir.
final FutureProvider<List<Pet>> myPetsProvider = FutureProvider<List<Pet>>((
  ref,
) async {
  ref.watch(authStatusProvider);
  final PetRepository repo = ref.watch(petRepositoryProvider);
  return repo.fetchMyPets();
});
