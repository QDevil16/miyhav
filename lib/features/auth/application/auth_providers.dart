import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/supabase_bootstrap.dart';
import '../data/auth_repository.dart';

/// Uygulama genelinde kullanılan [AuthRepository].
///
/// Varsayılan olarak Supabase'e bağlanır; testlerde `overrideWithValue` ile
/// sahte bir uygulama verilebilir (Supabase başlatılmadan).
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
      return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
    });

/// Doğrulama bekleyen e-posta adresi (kayıt/giriş → doğrulama ekranı arası).
final StateProvider<String?> pendingVerificationEmailProvider =
    StateProvider<String?>((ref) => null);
