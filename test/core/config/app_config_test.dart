import 'package:flutter_test/flutter_test.dart';
import 'package:miyhav/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('marka ve kalıcı kimlik doğru sabitler', () {
      expect(AppConfig.appName, 'Miyhav');
      expect(AppConfig.brandName, 'Miyhav');
      expect(AppConfig.applicationId, 'com.miyhav.app');
    });

    test('varsayılan ortam geliştirmedir', () {
      // Test, dart-define olmadan çalışır; varsayılan development beklenir.
      expect(AppConfig.flavor, AppFlavor.development);
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isProduction, isFalse);
      expect(AppConfig.displayTitle, 'Miyhav (Dev)');
    });

    test('Supabase yapılandırması varsayılan olarak yoktur', () {
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.hasSupabaseConfig, isFalse);
    });
  });
}
