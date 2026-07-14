import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Supabase başlatma sonucunun durumu.
enum SupabaseStatus {
  /// URL + anon key sağlanmış ve istemci başarıyla başlatıldı.
  ready,

  /// Yapılandırma eksik (SUPABASE_URL / SUPABASE_ANON_KEY verilmemiş).
  missingConfig,

  /// Yapılandırma var ama başlatma sırasında hata oluştu.
  error,
}

/// Supabase istemcisinin merkezi ve test edilebilir başlatıcısı.
///
/// Değerler [AppConfig] üzerinden (`--dart-define`) gelir; uygulamada yalnızca
/// public `SUPABASE_URL` + `SUPABASE_ANON_KEY` bulunur. `service_role` key
/// KESİNLİKLE burada kullanılmaz.
abstract final class SupabaseBootstrap {
  /// İstemciyi başlatır ve durum döner. Ham hata fırlatmaz; kontrollü sonuç verir.
  static Future<SupabaseStatus> initialize() async {
    if (!AppConfig.hasSupabaseConfig) {
      return SupabaseStatus.missingConfig;
    }
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // supabase_flutter 2.16: anonKey → publishableKey. Değer aynı (Supabase
        // panelindeki anon/publishable public key).
        publishableKey: AppConfig.supabaseAnonKey,
      );
      return SupabaseStatus.ready;
    } catch (_) {
      // Ham hata kullanıcıya gösterilmez; kontrollü durum döneriz.
      return SupabaseStatus.error;
    }
  }
}

/// Başlatılmış Supabase istemcisi. Yalnızca [SupabaseStatus.ready] iken kullanılır;
/// data/repository katmanı bu provider üzerinden erişir (ekranlara dağıtılmaz).
final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);
