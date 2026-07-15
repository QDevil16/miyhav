import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Kullanıcıya gösterilebilir, Türkçe ve güvenli bir profil hatası.
///
/// Ham Postgres/PostgREST/ağ hataları asla doğrudan arayüze gösterilmez
/// (CLAUDE.md kural 6); repository katmanı bunları buna çevirir.
class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  @override
  String toString() => 'ProfileFailure(message: $message)';
}

/// Profil işlemlerindeki hataları merkezî olarak Türkçe mesajlara çevirir.
abstract final class ProfileErrorMapper {
  static const String usernameTaken = 'Bu kullanıcı adı zaten kullanılıyor.';
  static const String unavailable = 'Profil bilgilerine şu anda ulaşılamıyor.';
  static const String network =
      'İnternet bağlantını kontrol et ve tekrar dene.';
  static const String generic =
      'İşlem sırasında bir sorun oluştu. Lütfen tekrar dene.';

  static ProfileFailure map(Object error) {
    if (error is ProfileFailure) return error;
    return ProfileFailure(_message(error));
  }

  static String _message(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return network;
    }
    if (error is PostgrestException) {
      // 23505 = unique_violation → username_normalized benzersizlik ihlali.
      if (error.code == '23505') return usernameTaken;
      final String msg = error.message.toLowerCase();
      if (msg.contains('duplicate') || msg.contains('unique')) {
        return usernameTaken;
      }
    }
    return generic;
  }
}
