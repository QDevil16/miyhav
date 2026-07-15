import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';
import 'package:miyhav/features/auth/application/auth_providers.dart';
import 'package:miyhav/features/auth/data/auth_repository.dart';

import '../../support/fake_auth_repository.dart';

Widget _app(FakeAuthRepository auth) {
  return ProviderScope(
    overrides: <Override>[authRepositoryProvider.overrideWithValue(auth)],
    child: const MiyhavApp(),
  );
}

void main() {
  testWidgets('oturum yokken giriş ekranına yönlendirir', (tester) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.unauthenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    expect(find.text('Giriş Yap'), findsOneWidget);
    // Ana uygulama (alt navigasyon) gösterilmez.
    expect(find.text('Keşfet'), findsNothing);
  });

  testWidgets('doğrulanmamış oturum doğrulama ekranına yönlendirir', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.unverified,
      email: 'yeni@miyhav.app',
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    expect(find.text('E-postanı doğrula'), findsOneWidget);
    expect(find.text('Ana Sayfa'), findsNothing);
  });

  testWidgets('girişli kullanıcı ana uygulamayı görür', (tester) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.authenticated,
      email: 'test@miyhav.app',
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Giriş Yap'), findsNothing);
  });

  testWidgets('geçersiz form gönderiminde Türkçe doğrulama hatası çıkar', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.unauthenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    // Boş formla giriş denenince e-posta alanı hatası görünür, ağ çağrısı olmaz.
    await tester.tap(find.text('Giriş Yap'));
    await tester.pumpAndSettle();

    expect(find.text('E-posta adresini gir.'), findsOneWidget);
    expect(auth.calls, isEmpty);
  });

  testWidgets('başarılı giriş ana uygulamaya geçirir', (tester) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.unauthenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@miyhav.app');
    await tester.enterText(find.byType(TextField).at(1), 'sifre1234');
    await tester.tap(find.text('Giriş Yap'));
    await tester.pumpAndSettle();

    expect(auth.calls, contains('signIn:test@miyhav.app'));
    expect(find.text('Ana Sayfa'), findsWidgets);
  });
}
