import '../../profile/domain/profile.dart' show ProfileVisibility;

/// Keşif/arama projeksiyonunun döndürdüğü SINIRLI, güvenli profil bilgisi.
///
/// Yalnızca `public_profiles` / `search_profiles` projeksiyonundaki güvenli
/// alanları taşır. Hassas veri (e-posta, üyelik, hesap durumu, sağlık, özel
/// alanlar) BU MODELDE YOKTUR ve projeksiyon tarafından da döndürülmez.
class DiscoveryProfile {
  const DiscoveryProfile({
    required this.id,
    this.username,
    this.displayName,
    this.profilePhotoPath,
    this.visibility = ProfileVisibility.public,
  });

  final String id;
  final String? username;
  final String? displayName;
  final String? profilePhotoPath;
  final ProfileVisibility visibility;

  factory DiscoveryProfile.fromMap(Map<String, dynamic> map) {
    String? clean(Object? v) {
      if (v is! String) return null;
      final String t = v.trim();
      return t.isEmpty ? null : t;
    }

    return DiscoveryProfile(
      id: map['id'] as String,
      username: clean(map['username']),
      displayName: clean(map['display_name']),
      profilePhotoPath: map['profile_photo_path'] as String?,
      visibility: ProfileVisibility.fromWire(
        map['profile_visibility'] as String?,
      ),
    );
  }
}
