import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/core/validation/auth_validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('boş e-posta reddedilir', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('   '), isNotNull);
    });

    test('geçersiz biçim reddedilir', () {
      expect(AuthValidators.email('abc'), isNotNull);
      expect(AuthValidators.email('abc@'), isNotNull);
      expect(AuthValidators.email('abc@def'), isNotNull);
    });

    test('geçerli e-posta kabul edilir', () {
      expect(AuthValidators.email('ornek@eposta.com'), isNull);
      expect(AuthValidators.email('  ad.soyad+1@miyhav.app '), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('boş veya kısa şifre reddedilir', () {
      expect(AuthValidators.password(''), isNotNull);
      expect(AuthValidators.password('1234567'), isNotNull);
    });

    test('yeterli uzunluk kabul edilir', () {
      expect(AuthValidators.password('12345678'), isNull);
    });
  });

  group('AuthValidators.passwordConfirm', () {
    test('eşleşmeyen şifre reddedilir', () {
      expect(AuthValidators.passwordConfirm('abcd1234', 'abcd9999'), isNotNull);
    });

    test('eşleşen şifre kabul edilir', () {
      expect(AuthValidators.passwordConfirm('abcd1234', 'abcd1234'), isNull);
    });
  });
}
