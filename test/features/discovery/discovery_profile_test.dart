import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/features/discovery/domain/discovery_profile.dart';
import 'package:miyhav/features/profile/domain/profile.dart';

void main() {
  group('DiscoveryProfile.fromMap', () {
    test('güvenli projeksiyon satırını parse eder', () {
      final DiscoveryProfile p = DiscoveryProfile.fromMap(<String, dynamic>{
        'id': 'u1',
        'username': 'AdaPub',
        'display_name': ' Ada ',
        'profile_photo_path': null,
        'profile_visibility': 'friends_only',
      });
      expect(p.id, 'u1');
      expect(p.username, 'AdaPub');
      expect(p.displayName, 'Ada');
      expect(p.visibility, ProfileVisibility.friendsOnly);
    });

    test('boş/eksik alanlar güvenli biçimde null olur', () {
      final DiscoveryProfile p = DiscoveryProfile.fromMap(<String, dynamic>{
        'id': 'u2',
        'username': null,
        'display_name': '   ',
        'profile_visibility': 'public',
      });
      expect(p.username, isNull);
      expect(p.displayName, isNull);
      expect(p.visibility, ProfileVisibility.public);
    });
  });
}
