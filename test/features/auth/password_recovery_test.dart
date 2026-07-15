import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/app/app.dart';
import 'package:miyhav/core/config/app_config.dart';
import 'package:miyhav/features/auth/application/auth_providers.dart';
import 'package:miyhav/features/auth/data/auth_repository.dart';
import 'package:miyhav/features/auth/presentation/forgot_password_screen.dart';
import 'package:miyhav/features/auth/presentation/reset_password_screen.dart';

import '../../support/fake_auth_repository.dart';

Widget _app(FakeAuthRepository auth) {
  return ProviderScope(
    overrides: <Override>[authRepositoryProvider.overrideWithValue(auth)],
    child: const MiyhavApp(),
  );
}

Widget _screen(FakeAuthRepository auth, Widget child) {
  return ProviderScope(
    overrides: <Override>[authRepositoryProvider.overrideWithValue(auth)],
    child: MaterialApp(home: child),
  );
}

void main() {
  test('AppConfig deep link callback URI\'leri doğru', () {
    expect(AppConfig.loginCallbackUrl, 'com.miyhav.app://login-callback/');
    expect(
      AppConfig.resetPasswordCallbackUrl,
      'com.miyhav.app://reset-password/',
    );
  });

  testWidgets('şifre kurtarma olayı yeni şifre ekranına yönlendirir', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.authenticated,
      email: 'user@miyhav.app',
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();
    // Normalde girişli kullanıcı ana ekranı görür.
    expect(find.text('Ana Sayfa'), findsWidgets);

    // Şifre sıfırlama deep link'i (kurtarma olayı) gelir.
    auth.emitEvent(AuthEventKind.passwordRecovery);
    await tester.pumpAndSettle();

    // Kurtarma modu: yalnızca yeni şifre ekranı, ana uygulama DEĞİL.
    expect(find.text('Yeni şifre belirle'), findsOneWidget);
    expect(find.text('Ana Sayfa'), findsNothing);
  });

  testWidgets('yeni şifre: kısa şifre Türkçe hata verir, çağrı yapılmaz', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.authenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_screen(auth, const ResetPasswordScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '123');
    await tester.enterText(find.byType(TextField).at(1), '123');
    await tester.tap(find.text('Şifreyi güncelle'));
    await tester.pumpAndSettle();

    expect(find.text('Şifre en az 8 karakter olmalı.'), findsOneWidget);
    expect(auth.calls, isNot(contains('updatePassword')));
  });

  testWidgets('yeni şifre: geçerli şifre güncellenir ve oturum kapatılır', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.authenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_screen(auth, const ResetPasswordScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'yeniSifre1');
    await tester.enterText(find.byType(TextField).at(1), 'yeniSifre1');
    await tester.tap(find.text('Şifreyi güncelle'));
    await tester.pumpAndSettle();

    expect(auth.calls, contains('updatePassword'));
    expect(auth.calls, contains('signOut'));
  });

  testWidgets(
    'şifremi unuttum: geçerli e-posta sıfırlama bağlantısı gönderir',
    (tester) async {
      final FakeAuthRepository auth = FakeAuthRepository(
        AuthStatus.unauthenticated,
      );
      addTearDown(auth.dispose);

      await tester.pumpWidget(_screen(auth, const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'user@miyhav.app');
      await tester.tap(find.text('Bağlantı gönder'));
      await tester.pumpAndSettle();

      expect(auth.calls, contains('sendPasswordReset:user@miyhav.app'));
      expect(find.text('Bağlantı gönderildi'), findsOneWidget);
    },
  );

  testWidgets('giriş ekranından şifremi unuttum ekranına gidilir', (
    tester,
  ) async {
    final FakeAuthRepository auth = FakeAuthRepository(
      AuthStatus.unauthenticated,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Şifremi unuttum'));
    await tester.pumpAndSettle();

    expect(find.text('Şifreni mi unuttun?'), findsOneWidget);
  });
}
