import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Miyhav birincil butonu — dolu coral yüzey, pill form, yumuşak gölge.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool enabled = onPressed != null && !isLoading;

    final Widget child = isLoading
        ? SizedBox(
            height: AppSpacing.lg,
            width: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: scheme.onPrimary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: scheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.allPill,
        boxShadow: enabled ? AppShadows.primaryButton : null,
      ),
      child: Material(
        color: enabled ? scheme.primary : scheme.primary.withValues(alpha: 0.5),
        borderRadius: AppRadius.allPill,
        child: InkWell(
          borderRadius: AppRadius.allPill,
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// İkincil buton — çerçeveli, şeffaf yüzey.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool enabled = onPressed != null;
    final Color fg = enabled ? scheme.primary : scheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.allPill,
      child: InkWell(
        borderRadius: AppRadius.allPill,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.allPill,
            border: Border.all(color: fg.withValues(alpha: 0.6), width: 1.4),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(color: fg, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
