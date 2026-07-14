import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Yumuşak, düşük gölgeler. Sert/koyu gölge kullanılmaz; sıcak kahve tonlu
/// yumuşak yükseltiler tercih edilir.
abstract final class AppShadows {
  /// Kartlar için hafif yükselti.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x147A5240), // cacao, %8 opaklık
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Bottom sheet / yüzen yüzeyler için biraz daha belirgin.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F7A5240), // cacao, %12 opaklık
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Marka renginde vurgulu buton gölgesi.
  static List<BoxShadow> primaryButton = <BoxShadow>[
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];
}
