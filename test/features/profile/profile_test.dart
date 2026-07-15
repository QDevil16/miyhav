import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/core/errors/profile_error_mapper.dart';
import 'package:miyhav/core/validation/profile_validators.dart';
import 'package:miyhav/features/profile/data/profile_repository.dart';
import 'package:miyhav/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Profile.fromMap', () {
    test('Supabase satırını doğru parse eder', () {
      final Profile p = Profile.fromMap(<String, dynamic>{
        'id': 'uuid-1',
        'display_name': ' Ada ',
        'username': 'ada_k',
        'profile_photo_path': null,
        'short_bio': 'Merhaba',
        'city': 'İzmir',
        'profile_visibility': 'public',
      });
      expect(p.id, 'uuid-1');
      expect(p.displayName, 'Ada'); // trim
      expect(p.username, 'ada_k');
      expect(p.shortBio, 'Merhaba');
      expect(p.city, 'İzmir');
      expect(p.visibility, ProfileVisibility.public);
      expect(p.usernameHandle, '@ada_k');
    });

    test('boş alanlar null olur, username yoksa Türkçe bilgi', () {
      final Profile p = Profile.fromMap(<String, dynamic>{
        'id': 'uuid-2',
        'display_name': '   ',
        'username': null,
        'short_bio': '',
        'city': null,
        'profile_visibility': 'private',
      });
      expect(p.displayName, isNull);
      expect(p.shortBio, isNull);
      expect(p.city, isNull);
      expect(p.hasUsername, isFalse);
      expect(p.usernameHandle, 'Kullanıcı adı belirlenmedi');
    });
  });

  group('ProfileVisibility etiketleri', () {
    test('private → Sadece Ben', () {
      expect(ProfileVisibility.fromWire('private').label, 'Sadece Ben');
    });
    test('friends_only → Sadece Arkadaşlar', () {
      expect(
        ProfileVisibility.fromWire('friends_only').label,
        'Sadece Arkadaşlar',
      );
    });
    test('public → Herkese Açık', () {
      expect(ProfileVisibility.fromWire('public').label, 'Herkese Açık');
    });
  });

  group('ProfileValidators.username', () {
    test('3 karakter altını reddeder', () {
      expect(ProfileValidators.username('ab'), isNotNull);
    });
    test('boşluğu reddeder', () {
      expect(ProfileValidators.username('ab cd'), isNotNull);
    });
    test('Türkçe karakteri reddeder', () {
      expect(ProfileValidators.username('şule'), isNotNull);
      expect(ProfileValidators.username('ağa_1'), isNotNull);
    });
    test('alt çizgiyi kabul eder', () {
      expect(ProfileValidators.username('user_1'), isNull);
    });
    test('boş kullanıcı adı geçerli (opsiyonel)', () {
      expect(ProfileValidators.username(''), isNull);
      expect(ProfileValidators.username('   '), isNull);
    });
    test('30 karakter üstünü reddeder', () {
      expect(ProfileValidators.username('a' * 31), isNotNull);
    });
  });

  group('ProfileValidators uzunluk', () {
    test('bio 160 üstünü reddeder, 160 kabul eder', () {
      expect(ProfileValidators.bio('a' * 161), isNotNull);
      expect(ProfileValidators.bio('a' * 160), isNull);
    });
    test('city 80 üstünü reddeder, 80 kabul eder', () {
      expect(ProfileValidators.city('a' * 81), isNotNull);
      expect(ProfileValidators.city('a' * 80), isNull);
    });
    test('display name 60 üstünü reddeder', () {
      expect(ProfileValidators.displayName('a' * 61), isNotNull);
      expect(ProfileValidators.displayName('a' * 60), isNull);
    });
  });

  group('buildProfileUpdate', () {
    test(
      'yalnızca düzenlenebilir alanları içerir, kritik alanları içermez',
      () {
        final Map<String, dynamic> payload = buildProfileUpdate(
          displayName: ' Ada ',
          username: '  ada_k ',
          shortBio: '',
          city: '  ',
          visibility: ProfileVisibility.friendsOnly,
        );
        expect(payload.keys.toSet(), <String>{
          'display_name',
          'username',
          'short_bio',
          'city',
          'profile_visibility',
        });
        // Kritik alanlar asla yer almaz.
        for (final String critical in <String>[
          'id',
          'membership_type',
          'account_status',
          'created_at',
          'username_normalized',
          'profile_photo_path',
        ]) {
          expect(payload.containsKey(critical), isFalse);
        }
        // Boşlar null, trim uygulanır, enum wire değeri.
        expect(payload['display_name'], 'Ada');
        expect(payload['username'], 'ada_k');
        expect(payload['short_bio'], isNull);
        expect(payload['city'], isNull);
        expect(payload['profile_visibility'], 'friends_only');
      },
    );
  });

  group('ProfileErrorMapper', () {
    test('unique violation (23505) Türkçe mesaja map edilir', () {
      final ProfileFailure f = ProfileErrorMapper.map(
        const PostgrestException(message: 'duplicate key value', code: '23505'),
      );
      expect(f.message, ProfileErrorMapper.usernameTaken);
    });
    test('ağ hatası bağlantı mesajına map edilir', () {
      expect(
        ProfileErrorMapper.map(const SocketException('x')).message,
        ProfileErrorMapper.network,
      );
    });
    test('bilinmeyen hata genel mesaja map edilir (ham hata sızmaz)', () {
      final ProfileFailure f = ProfileErrorMapper.map(
        Exception('raw pg detail'),
      );
      expect(f.message, ProfileErrorMapper.generic);
      expect(f.message, isNot(contains('raw pg detail')));
    });
  });
}
