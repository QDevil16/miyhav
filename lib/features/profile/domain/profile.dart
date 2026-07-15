/// Profil görünürlüğü. Wire değerleri `profile_visibility` enum'u ile birebir.
///
/// NOT: Bu yalnızca profilin kendi görünürlük tercihidir; ileriki arama/keşif
/// (discovery) projeksiyonu ayrı bir konudur ve burada ele alınmaz.
enum ProfileVisibility {
  private('private', 'Sadece Ben', 'Profilini yalnızca sen görürsün.'),
  friendsOnly(
    'friends_only',
    'Sadece Arkadaşlar',
    'Yalnızca arkadaşların görebilir.',
  ),
  public('public', 'Herkese Açık', 'Herkes profilini görebilir.');

  const ProfileVisibility(this.wire, this.label, this.description);

  /// Veritabanı/enum değeri (private / friends_only / public).
  final String wire;

  /// Türkçe kısa etiket.
  final String label;

  /// Türkçe kısa açıklama.
  final String description;

  static ProfileVisibility fromWire(String? value) {
    for (final ProfileVisibility v in ProfileVisibility.values) {
      if (v.wire == value) return v;
    }
    return ProfileVisibility.private;
  }
}

/// Kullanıcının kendi profili (yalnızca gerekli alanlar).
///
/// Kritik alanlar (membership_type, account_status, created_at,
/// username_normalized) modelde tutulmaz; bu görevde okunmaz/yazılmaz.
class Profile {
  const Profile({
    required this.id,
    this.displayName,
    this.username,
    this.profilePhotoPath,
    this.shortBio,
    this.city,
    this.visibility = ProfileVisibility.private,
  });

  final String id;
  final String? displayName;
  final String? username;
  final String? profilePhotoPath;
  final String? shortBio;
  final String? city;
  final ProfileVisibility visibility;

  factory Profile.fromMap(Map<String, dynamic> map) {
    String? clean(Object? value) {
      if (value is! String) return null;
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return Profile(
      id: map['id'] as String,
      displayName: clean(map['display_name']),
      username: clean(map['username']),
      profilePhotoPath: map['profile_photo_path'] as String?,
      shortBio: clean(map['short_bio']),
      city: clean(map['city']),
      visibility: ProfileVisibility.fromWire(
        map['profile_visibility'] as String?,
      ),
    );
  }

  bool get hasUsername => username != null && username!.isNotEmpty;

  /// Görüntülenecek kullanıcı adı; yoksa Türkçe bilgi.
  String get usernameHandle =>
      hasUsername ? '@$username' : 'Kullanıcı adı belirlenmedi';
}
