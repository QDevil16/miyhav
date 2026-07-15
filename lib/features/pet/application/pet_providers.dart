import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/supabase_bootstrap.dart';
import '../../profile/application/profile_providers.dart';
import '../data/pet_repository.dart';
import '../domain/pet.dart';

/// Uygulama genelinde kullanılan [PetRepository].
final Provider<PetRepository> petRepositoryProvider = Provider<PetRepository>((
  ref,
) {
  return SupabasePetRepository(ref.watch(supabaseClientProvider));
});

/// Oturum açmış kullanıcının kendi petleri. Auth durumu değişince yeniden yüklenir;
/// ekleme/güncelleme/silme sonrası `ref.invalidate` ile tazelenir.
final FutureProvider<List<Pet>> myPetsProvider = FutureProvider<List<Pet>>((
  ref,
) async {
  ref.watch(authStatusProvider);
  final PetRepository repo = ref.watch(petRepositoryProvider);
  return repo.fetchMyPets();
});
