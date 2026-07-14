import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Miyhav'ın imza yüzeyi: büyük yuvarlatılmış, yumuşak gölgeli kart.
///
/// [onTap] verilirse dokunulabilir olur. [accent] true ise coral tonlu
/// vurgulu bir yüzey (referanstaki "Pet Avatar" kartı gibi) üretir.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.accent = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = accent ? scheme.primaryContainer : scheme.surface;

    final Widget content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.allXl,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: bg,
        borderRadius: AppRadius.allXl,
        clipBehavior: Clip.antiAlias,
        child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
      ),
    );
  }
}
