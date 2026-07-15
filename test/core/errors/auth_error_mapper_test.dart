import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/core/errors/auth_error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthErrorMapper', () {
    test('zaten kayıtlı e-posta Türkçe mesaja çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const AuthException(
          'User already registered',
          code: 'user_already_exists',
        ),
      );
      expect(f.message, contains('zaten kayıtlı'));
    });

    test('hatalı giriş bilgisi Türkçe mesaja çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const AuthException(
          'Invalid login credentials',
          code: 'invalid_credentials',
        ),
      );
      expect(f.message, 'E-posta veya şifre hatalı.');
    });

    test('doğrulanmamış e-posta Türkçe mesaja çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const AuthException('Email not confirmed', code: 'email_not_confirmed'),
      );
      expect(f.message, AuthErrorMapper.emailNotConfirmed);
    });

    test('zayıf şifre Türkçe mesaja çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const AuthException('Password should be at least 6 characters'),
      );
      expect(f.message, contains('güçlü değil'));
    });

    test('hız sınırı Türkçe mesaja çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const AuthException(
          'For security purposes, you can only request this after 60 seconds',
        ),
      );
      expect(f.message, contains('Çok fazla deneme'));
    });

    test('ağ hatası bağlantı mesajına çevrilir', () {
      final AuthFailure f = AuthErrorMapper.map(
        const SocketException('failed'),
      );
      expect(f.message, AuthErrorMapper.network);
    });

    test('bilinmeyen hata genel mesaja çevrilir (ham hata sızmaz)', () {
      final AuthFailure f = AuthErrorMapper.map(
        Exception('raw internal detail'),
      );
      expect(f.message, AuthErrorMapper.generic);
      expect(f.message, isNot(contains('raw internal detail')));
    });

    test('AuthFailure tekrar sarılmaz (aynen döner)', () {
      const AuthFailure original = AuthFailure('özel mesaj');
      expect(AuthErrorMapper.map(original), same(original));
    });
  });
}
