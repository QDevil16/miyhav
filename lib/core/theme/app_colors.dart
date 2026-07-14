import 'package:flutter/material.dart';

/// Miyhav renk paleti — sıcak kahve/kakao/taupe/krem + soft coral.
///
/// Renkler burada tek merkezden tanımlanır; widget'larda ham HEX/`Color(0x...)`
/// dağınık kullanılmaz. Tema (`AppTheme`) bu tokenlardan Material 3 ColorScheme
/// üretir.
abstract final class AppColors {
  // --- Marka çekirdeği ---
  /// Soft coral / terracotta — ana marka rengi.
  static const Color primary = Color(0xFFD08D79);
  static const Color primaryDark = Color(0xFFB06B57);
  static const Color primarySoft = Color(0xFFE8B8A8); // açık coral yüzeyler

  /// Warm amber — ikincil vurgu.
  static const Color secondary = Color(0xFFE0A96D);

  /// Cacao — koyu kahve vurgu / başlık aksanı.
  static const Color cacao = Color(0xFF7A5240);

  // --- Nötrler (açık tema) ---
  static const Color background = Color(0xFFF5EFE9); // krem / kırık beyaz
  static const Color surface = Color(0xFFFBF7F3); // pudra beyazı (kart)
  static const Color surfaceAlt = Color(0xFFEDE4DC); // taupe yüzey
  static const Color taupe = Color(0xFFD9CFC6);
  static const Color outline = Color(0xFFDCCFC4);

  static const Color textPrimary = Color(0xFF2B2320); // koyu kahve-siyah
  static const Color textMuted = Color(0xFF8A7D74); // taupe-gri
  static const Color onPrimary = Color(0xFFFFFBF8);

  // --- Durum renkleri ---
  static const Color success = Color(0xFF7FA87A);
  static const Color warning = Color(0xFFE0A96D);
  static const Color error = Color(0xFFC15B4E);

  // --- Nötrler (koyu tema) ---
  static const Color darkBackground = Color(0xFF1E1815);
  static const Color darkSurface = Color(0xFF2A221E);
  static const Color darkSurfaceAlt = Color(0xFF3A2F29);
  static const Color darkOutline = Color(0xFF4A3D35);
  static const Color darkTextPrimary = Color(0xFFF1E8E1);
  static const Color darkTextMuted = Color(0xFFB4A79E);

  /// Açık tema ColorScheme.
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primarySoft,
    onPrimaryContainer: cacao,
    secondary: secondary,
    onSecondary: onPrimary,
    secondaryContainer: Color(0xFFF3DCC0),
    onSecondaryContainer: cacao,
    tertiary: cacao,
    onTertiary: onPrimary,
    error: error,
    onError: onPrimary,
    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textMuted,
    surfaceContainerHighest: surfaceAlt,
    outline: outline,
    outlineVariant: taupe,
  );

  /// Koyu tema ColorScheme (sıcak koyu kahve zeminler).
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Color(0xFF2B1B14),
    primaryContainer: primaryDark,
    onPrimaryContainer: Color(0xFFFDEDE5),
    secondary: secondary,
    onSecondary: Color(0xFF2B1B14),
    secondaryContainer: Color(0xFF5A4028),
    onSecondaryContainer: Color(0xFFF7E2C8),
    tertiary: Color(0xFFCBA48E),
    onTertiary: Color(0xFF2B1B14),
    error: Color(0xFFE58B7E),
    onError: Color(0xFF2B1B14),
    surface: darkSurface,
    onSurface: darkTextPrimary,
    onSurfaceVariant: darkTextMuted,
    surfaceContainerHighest: darkSurfaceAlt,
    outline: darkOutline,
    outlineVariant: darkSurfaceAlt,
  );
}
