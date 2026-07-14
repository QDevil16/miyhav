/// Uygulamanın çalıştığı ortam.
enum AppFlavor { development, production }

/// Miyhav uygulamasının merkezi yapılandırması.
///
/// Uygulama adı, marka ve kalıcı platform kimliği burada tek noktadan yönetilir;
/// koda dağınık sabitlenmez. Ortam ve Supabase bağlantı bilgileri derleme
/// sırasında `--dart-define` ile verilir:
///
/// ```
/// flutter run \
///   --dart-define=APP_ENV=development \
///   --dart-define=SUPABASE_URL=... \
///   --dart-define=SUPABASE_ANON_KEY=...
/// ```
///
/// Uygulama ikilisinde yalnızca Supabase URL + anon key gibi public değerler
/// bulunabilir. Service role key, PostgreSQL şifresi, FCM service account gibi
/// sırlar KESİNLİKLE burada veya uygulamada bulunmaz (bkz. ENVIRONMENT_SETUP.md).
class AppConfig {
  const AppConfig._();

  // --- Marka / kimlik (tek merkez) ---

  /// Kullanıcıya ve mağazalarda gösterilen uygulama adı.
  static const String appName = 'Miyhav';

  /// Marka adı (bildirim, PDF, e-posta şablonları vb. için).
  static const String brandName = 'Miyhav';

  /// Kalıcı Android package name = iOS bundle identifier (DECISIONS D-013).
  static const String applicationId = 'com.miyhav.app';

  // --- Ortam ---

  static const String _appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Aktif ortam. `APP_ENV=production` değilse geliştirme kabul edilir.
  static AppFlavor get flavor =>
      _appEnv == 'production' ? AppFlavor.production : AppFlavor.development;

  static bool get isProduction => flavor == AppFlavor.production;
  static bool get isDevelopment => flavor == AppFlavor.development;

  /// Uygulama başlığı; geliştirme ortamında ayırt edici ek taşır.
  static String get displayTitle => isProduction ? appName : '$appName (Dev)';

  // --- Supabase (yalnızca public değerler) ---

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Supabase bağlantı bilgileri build sırasında sağlanmış mı?
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
