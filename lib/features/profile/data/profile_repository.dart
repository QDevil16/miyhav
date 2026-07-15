import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/profile_error_mapper.dart';
import '../domain/profile.dart';

/// Yalnızca kullanıcının düzenleyebileceği alanları içeren update payload'u.
///
/// Kritik alanlar (id, membership_type, account_status, created_at,
/// username_normalized) ASLA yer almaz — güvenlik BEFORE UPDATE trigger'ı + RLS
/// ile de korunur. `profile_photo_path` bu görevde değiştirilmez (payload'a
/// eklenmez → mevcut değer korunur). Boş metinler null olarak kaydedilir.
Map<String, dynamic> buildProfileUpdate({
  required String? displayName,
  required String? username,
  required String? shortBio,
  required String? city,
  required ProfileVisibility visibility,
}) {
  String? clean(String? value) {
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  return <String, dynamic>{
    'display_name': clean(displayName),
    'username': clean(username),
    'short_bio': clean(shortBio),
    'city': clean(city),
    'profile_visibility': visibility.wire,
  };
}

/// Profil verisi için soyut arayüz. UI yalnızca buna bağlanır; Supabase istemcisi
/// ekranlara sızmaz. Hatalar Türkçe [ProfileFailure] olarak fırlatılır.
abstract interface class ProfileRepository {
  /// Oturum açmış kullanıcının kendi profilini getirir.
  Future<Profile> fetchMyProfile();

  /// Oturum açmış kullanıcının kendi profilini günceller (yalnızca kendi id'si).
  Future<Profile> updateMyProfile({
    required String? displayName,
    required String? username,
    required String? shortBio,
    required String? city,
    required ProfileVisibility visibility,
  });
}

/// [ProfileRepository]'nin Supabase uygulaması. RLS gereği yalnızca kullanıcının
/// kendi satırı okunur/güncellenir; id her zaman auth oturumundan alınır.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'profiles';

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) throw const ProfileFailure(ProfileErrorMapper.unavailable);
    return id;
  }

  @override
  Future<Profile> fetchMyProfile() async {
    try {
      final Map<String, dynamic>? data = await _client
          .from(_table)
          .select()
          .eq('id', _userId)
          .maybeSingle();
      // Satır yoksa sahte profil ÜRETİLMEZ; beklenmeyen durum olarak ele alınır.
      if (data == null) {
        throw const ProfileFailure(ProfileErrorMapper.unavailable);
      }
      return Profile.fromMap(data);
    } catch (error) {
      throw ProfileErrorMapper.map(error);
    }
  }

  @override
  Future<Profile> updateMyProfile({
    required String? displayName,
    required String? username,
    required String? shortBio,
    required String? city,
    required ProfileVisibility visibility,
  }) async {
    try {
      final Map<String, dynamic> payload = buildProfileUpdate(
        displayName: displayName,
        username: username,
        shortBio: shortBio,
        city: city,
        visibility: visibility,
      );
      final Map<String, dynamic> data = await _client
          .from(_table)
          .update(payload)
          .eq('id', _userId)
          .select()
          .single();
      return Profile.fromMap(data);
    } catch (error) {
      throw ProfileErrorMapper.map(error);
    }
  }
}
