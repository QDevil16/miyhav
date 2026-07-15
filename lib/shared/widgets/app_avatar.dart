import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Genel kullanıcı avatarı. Fotoğraf yoksa baş harf(ler)i veya ikon gösterir.
/// (İsimsiz varsayılan profil için [DefaultProfileAvatar]; pet türü ikonu için
/// [PetTypeIcon] kullanılır.)
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.displayName, this.size = 48, this.icon});

  final String? displayName;
  final double size;
  final IconData? icon;

  String get _initials {
    final String name = (displayName ?? '').trim();
    if (name.isEmpty) return '';
    final List<String> parts = name.split(RegExp(r'\s+'));
    final String first = parts.first.characters.first;
    final String second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String initials = _initials;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 2),
      ),
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: AppTypography.h3.copyWith(
                color: scheme.onSecondaryContainer,
                fontSize: size * 0.36,
              ),
            )
          : Icon(
              icon ?? Icons.person_rounded,
              size: size * 0.5,
              color: scheme.onSecondaryContainer,
            ),
    );
  }
}
