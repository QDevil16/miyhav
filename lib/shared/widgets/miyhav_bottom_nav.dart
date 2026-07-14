import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Alt navigasyon sekmesi tanımı.
class MiyhavNavItem {
  const MiyhavNavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Miyhav'a özgü, yüzen ve yuvarlatılmış alt navigasyon çubuğu.
/// Standart [BottomNavigationBar] yerine markaya uygun görünüm sağlar.
class MiyhavBottomNav extends StatelessWidget {
  const MiyhavBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<MiyhavNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadius.allPill,
            boxShadow: AppShadows.raised,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MiyhavNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.allPill,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.md : AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: AppRadius.allPill,
          ),
          child: Row(
            children: <Widget>[
              Icon(item.icon, size: 22, color: fg),
              if (selected) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  item.label,
                  style: AppTypography.label.copyWith(color: fg, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
