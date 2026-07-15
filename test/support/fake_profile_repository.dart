import 'package:miyhav/core/errors/profile_error_mapper.dart';
import 'package:miyhav/features/profile/data/profile_repository.dart';
import 'package:miyhav/features/profile/domain/profile.dart';

/// Testlerde Supabase'e bağlanmadan kullanılan sahte [ProfileRepository].
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this._profile);

  Profile _profile;
  Object? throwOnFetch;
  Object? throwOnUpdate;
  int fetchCount = 0;
  Profile? lastUpdate;

  set profile(Profile value) => _profile = value;

  @override
  Future<Profile> fetchMyProfile() async {
    fetchCount++;
    final Object? err = throwOnFetch;
    if (err != null) throw ProfileErrorMapper.map(err);
    return _profile;
  }

  @override
  Future<Profile> updateMyProfile({
    required String? displayName,
    required String? username,
    required String? shortBio,
    required String? city,
    required ProfileVisibility visibility,
  }) async {
    final Object? err = throwOnUpdate;
    if (err != null) throw ProfileErrorMapper.map(err);
    String? clean(String? v) {
      final String t = (v ?? '').trim();
      return t.isEmpty ? null : t;
    }

    _profile = Profile(
      id: _profile.id,
      displayName: clean(displayName),
      username: clean(username),
      profilePhotoPath: _profile.profilePhotoPath,
      shortBio: clean(shortBio),
      city: clean(city),
      visibility: visibility,
    );
    lastUpdate = _profile;
    return _profile;
  }
}
