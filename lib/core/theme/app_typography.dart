import 'package:flutter/material.dart';

/// Miyhav tipografisi — Jost (bundled). Büyük, ferah, okunabilir ölçek.
///
/// Adlandırılmış stiller (display/h1/h2/h3/body/caption) ve bunlardan üretilen
/// Material [TextTheme]. Renk temaya bırakılır; burada yalnızca boyut/ağırlık.
abstract final class AppTypography {
  static const String fontFamily = 'Jost';

  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _semiBold = FontWeight.w600;

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: _semiBold,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: _semiBold,
    height: 1.18,
    letterSpacing: -0.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: _semiBold,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: _semiBold,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: _regular,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: _regular,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: _medium,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: _medium,
    height: 1.3,
    letterSpacing: 0.2,
  );

  /// Material [TextTheme] eşlemesi. Renk `onSurface` ile temadan gelir.
  static TextTheme textTheme(Color onSurface) {
    final TextTheme t = TextTheme(
      displayLarge: display,
      displayMedium: display.copyWith(fontSize: 30),
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h3,
      titleMedium: label.copyWith(fontSize: 16),
      titleSmall: label,
      bodyLarge: body,
      bodyMedium: bodySmall,
      bodySmall: caption,
      labelLarge: label,
      labelMedium: caption,
      labelSmall: caption.copyWith(fontSize: 11),
    );
    return t.apply(
      fontFamily: fontFamily,
      bodyColor: onSurface,
      displayColor: onSurface,
    );
  }
}
