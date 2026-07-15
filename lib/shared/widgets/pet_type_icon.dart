import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Miyhav pet türleri. Her tür için hazır, profesyonel ve tanınabilir tek bir
/// Lucide ikonu kullanılır (elle hayvan çizimi YOK — bkz. DECISIONS D-019).
enum PetType { cat, dog, bird, rabbit, fish, reptile, other }

/// `pets.species` metnini [PetType]'a eşler.
PetType petTypeFromSpecies(String? species) {
  switch (species) {
    case 'cat':
      return PetType.cat;
    case 'dog':
      return PetType.dog;
    case 'bird':
      return PetType.bird;
    case 'rabbit':
      return PetType.rabbit;
    case 'fish':
      return PetType.fish;
    case 'reptile':
      return PetType.reptile;
    default:
      return PetType.other;
  }
}

/// Tür için Türkçe etiket.
String petTypeLabel(PetType type) {
  switch (type) {
    case PetType.cat:
      return 'Kedi';
    case PetType.dog:
      return 'Köpek';
    case PetType.bird:
      return 'Kuş';
    case PetType.rabbit:
      return 'Tavşan';
    case PetType.fish:
      return 'Balık';
    case PetType.reptile:
      return 'Sürüngen';
    case PetType.other:
      return 'Diğer';
  }
}

/// Tür için hazır Lucide ikonu (ince, tutarlı çizgi ailesi).
IconData petTypeIconData(PetType type) {
  switch (type) {
    case PetType.cat:
      return LucideIcons.cat;
    case PetType.dog:
      return LucideIcons.dog;
    case PetType.bird:
      return LucideIcons.bird;
    case PetType.rabbit:
      return LucideIcons.rabbit;
    case PetType.fish:
      return LucideIcons.fish;
    case PetType.reptile:
      return LucideIcons.turtle;
    case PetType.other:
      return LucideIcons.pawPrint;
  }
}

/// Pet türü için temiz, minimal ve premium ikon yüzeyi.
///
/// Yuvarlak sade zemin + ortada tür ikonu. [selected] iken soft coral vurgu
/// (ince coral çerçeve + çok hafif coral zemin + belirgin ikon). Gradient/3D/
/// gölge kullanılmaz. Hem tür seçim kartında hem de fotoğrafsız pet avatarı
/// (fallback) olarak kullanılır.
class PetTypeIcon extends StatelessWidget {
  const PetTypeIcon({
    super.key,
    required this.type,
    this.size = 72,
    this.selected = false,
  });

  final PetType type;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = selected
        ? scheme.primary.withValues(alpha: 0.12)
        : scheme.surfaceContainerHighest;
    final Color foreground = selected ? scheme.primary : scheme.tertiary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: selected ? Border.all(color: scheme.primary, width: 1.6) : null,
      ),
      alignment: Alignment.center,
      child: Icon(petTypeIconData(type), size: size * 0.48, color: foreground),
    );
  }
}
