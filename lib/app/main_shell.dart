import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/miyhav_app_bar.dart';
import '../shared/widgets/miyhav_bottom_nav.dart';
import '../shared/widgets/pet_type_icon.dart';

/// Ana uygulama kabuğu: alt navigasyon + sekme gövdeleri (iskelet).
///
/// Bu aşamada gerçek feature logic veya backend YOK; her sekme, Miyhav tasarım
/// sistemini kullanan geçici içerik gösterir. Gerçek ekranlar ilgili görevlerde
/// (AUTH, PROFILE, PET, SOCIAL, DISCOVERY ...) eklenecek.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<MiyhavNavItem> _items = <MiyhavNavItem>[
    MiyhavNavItem(label: 'Ana Sayfa', icon: Icons.home_rounded),
    MiyhavNavItem(label: 'Keşfet', icon: Icons.explore_rounded),
    MiyhavNavItem(label: 'Paylaş', icon: Icons.add_circle_rounded),
    MiyhavNavItem(label: 'Petlerim', icon: Icons.pets_rounded),
    MiyhavNavItem(label: 'Profil', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          MiyhavAppBar(
            title: _items[_index].label,
            subtitle: _index == 0 ? 'Miyhav dünyasına hoş geldin' : null,
          ),
          Expanded(child: _body(_index)),
        ],
      ),
      bottomNavigationBar: MiyhavBottomNav(
        items: _items,
        currentIndex: _index,
        onSelected: (int i) => setState(() => _index = i),
      ),
    );
  }

  Widget _body(int index) {
    switch (index) {
      case 0:
        return const _HomeShowcase();
      case 1:
        return const EmptyState(
          title: 'Keşfet yakında',
          message: 'Yeni pet dostları burada görünecek.',
          icon: Icons.explore_rounded,
        );
      case 2:
        return const EmptyState(
          title: 'Paylaşım oluştur',
          message: 'Petinin en güzel anını paylaşmak için hazır ol.',
          icon: Icons.add_a_photo_rounded,
        );
      case 3:
        return const EmptyState(
          title: 'Henüz pet eklemedin',
          message: 'İlk pet dostunu ekleyerek başla.',
          icon: Icons.pets_rounded,
          actionLabel: 'Pet Ekle',
        );
      default:
        return const ProfileScreen();
    }
  }
}

/// Ana sayfa iskeleti — tasarım sistemini sergileyen geçici içerik.
class _HomeShowcase extends StatelessWidget {
  const _HomeShowcase();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        AppCard(
          accent: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const PetTypeIcon(type: PetType.cat, size: 84),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pet dostların',
                      style: AppTypography.h3.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Sağlık, hatırlatma ve paylaşım tek yerde.',
                      style: AppTypography.bodySmall.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Türler',
          style: AppTypography.h3.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PetTypeGallery(),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Row(
            children: <Widget>[
              Icon(Icons.favorite_rounded, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Sıcak, özgün ve sevimli bir pet deneyimi.',
                  style: AppTypography.body.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Türler" bölümü: modern pet illüstrasyonlarını seçilebilir olarak gösterir.
/// Seçili tür zarif bir çerçeve + hafif vurgu + tür adı etiketi ile belirir.
class _PetTypeGallery extends StatefulWidget {
  const _PetTypeGallery();

  @override
  State<_PetTypeGallery> createState() => _PetTypeGalleryState();
}

class _PetTypeGalleryState extends State<_PetTypeGallery> {
  PetType _selected = PetType.cat;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        for (final PetType type in PetType.values)
          _PetTypeTile(
            type: type,
            selected: type == _selected,
            onTap: () => setState(() => _selected = type),
          ),
      ],
    );
  }
}

/// Tek bir pet türü: avatar + etiket; seçiliyken vurgulu çerçeve.
class _PetTypeTile extends StatelessWidget {
  const _PetTypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PetType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 76,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: <Widget>[
            PetTypeIcon(type: type, size: 64, selected: selected),
            const SizedBox(height: AppSpacing.xs),
            Text(
              petTypeLabel(type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
