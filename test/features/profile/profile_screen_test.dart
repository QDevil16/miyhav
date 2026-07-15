import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/core/errors/profile_error_mapper.dart';
import 'package:miyhav/features/auth/application/auth_providers.dart';
import 'package:miyhav/features/auth/data/auth_repository.dart';
import 'package:miyhav/features/profile/application/profile_providers.dart';
import 'package:miyhav/features/profile/domain/profile.dart';
import 'package:miyhav/features/profile/presentation/profile_edit_screen.dart';
import 'package:miyhav/features/profile/presentation/profile_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_profile_repository.dart';

const Profile _sample = Profile(
  id: 'u1',
  displayName: 'Ada',
  username: 'ada_k',
  shortBio: 'Merhaba',
  city: 'İzmir',
  visibility: ProfileVisibility.public,
);

void main() {
  testWidgets('profil ekranı loading durumunu gösterir', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myProfileProvider.overrideWith((ref) => Completer<Profile>().future),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('profil ekranı hata durumunda retry gösterir ve yeniden dener', (
    tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myProfileProvider.overrideWith((ref) async {
            calls++;
            if (calls == 1) {
              throw const ProfileFailure(ProfileErrorMapper.unavailable);
            }
            return _sample;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(ProfileErrorMapper.unavailable), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    // Yeniden denemede profil gelir.
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('@ada_k'), findsOneWidget);
  });

  testWidgets('profil ekranı verileri ve gizlilik etiketini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          myProfileProvider.overrideWith((ref) async => _sample),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('@ada_k'), findsOneWidget);
    expect(find.text('Herkese Açık'), findsOneWidget);
    expect(find.text('Profili Düzenle'), findsOneWidget);
    expect(find.text('Çıkış Yap'), findsOneWidget);
  });

  test(
    'repository yalnızca current user id ile günceller; provider tazelenir',
    () async {
      final FakeAuthRepository auth = FakeAuthRepository(
        AuthStatus.authenticated,
      );
      final FakeProfileRepository repo = FakeProfileRepository(_sample);
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(auth.dispose);

      final Profile p1 = await container.read(myProfileProvider.future);
      expect(p1.displayName, 'Ada');

      await container
          .read(profileRepositoryProvider)
          .updateMyProfile(
            displayName: 'Bade',
            username: 'ada_k',
            shortBio: null,
            city: 'İzmir',
            visibility: ProfileVisibility.private,
          );
      container.invalidate(myProfileProvider);

      final Profile p2 = await container.read(myProfileProvider.future);
      expect(p2.displayName, 'Bade');
      expect(p2.id, p1.id); // aynı kullanıcı; id değişmez
    },
  );

  testWidgets(
    'düzenleme başarılı kayıttan sonra güncel veri repository\'ye yazılır',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final FakeAuthRepository auth = FakeAuthRepository(
        AuthStatus.authenticated,
      );
      addTearDown(auth.dispose);
      final FakeProfileRepository repo = FakeProfileRepository(_sample);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authRepositoryProvider.overrideWithValue(auth),
            profileRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: ProfileEditScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Bade');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(repo.lastUpdate?.displayName, 'Bade');
    },
  );
}
