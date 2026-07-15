import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Kullanıcıya gösterilebilir, Türkçe ve güvenli bir pet hatası.
class PetFailure implements Exception {
  const PetFailure(this.message);

  final String message;

  @override
  String toString() => 'PetFailure(message: $message)';
}

/// Pet işlemlerindeki ham hataları merkezî olarak Türkçe mesajlara çevirir.
abstract final class PetErrorMapper {
  static const String network =
      'İnternet bağlantını kontrol et ve tekrar dene.';
  static const String generic =
      'İşlem sırasında bir sorun oluştu. Lütfen tekrar dene.';
  static const String notAllowed = 'Bu işlem için yetkin yok.';

  static PetFailure map(Object error) {
    if (error is PetFailure) return error;
    return PetFailure(_message(error));
  }

  static String _message(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return network;
    }
    if (error is PostgrestException) {
      // RLS reddi / yetki hatası → güvenli mesaj (ham detay sızmaz).
      final String code = error.code ?? '';
      if (code == '42501' || code == 'PGRST301') return notAllowed;
    }
    return generic;
  }
}
