import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/supabase_bootstrap.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

/// Uygulama genelinde kullanılan [ProfileRepository].
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((ref) {
      return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
    });

/// Auth durumu akışı (profilin yeniden yüklenmesini tetikler).
final StreamProvider<AuthStatus> authStatusProvider =
    StreamProvider<AuthStatus>((ref) {
      return ref.watch(authRepositoryProvider).statusChanges();
    });

/// Oturum açmış kullanıcının kendi profili. Auth durumu değiştiğinde (giriş/çıkış/
/// kullanıcı değişimi) yeniden yüklenir; güncelleme sonrası `ref.invalidate` ile
/// tazelenir.
final FutureProvider<Profile> myProfileProvider = FutureProvider<Profile>((
  ref,
) async {
  // Auth durumu değişimini dinle (doğru kullanıcının profili yüklensin).
  ref.watch(authStatusProvider);
  final ProfileRepository repo = ref.watch(profileRepositoryProvider);
  return repo.fetchMyProfile();
});
