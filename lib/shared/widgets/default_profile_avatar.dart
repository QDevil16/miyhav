import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Varsayılan kullanıcı profil avatarı: yuvarlak pastel yüzey üzerinde sade bir
/// pati ikonu (Miyhav coral/taupe). Kullanıcı gerçek fotoğraf yüklemediğinde
/// gösterilir. Temiz ve premium; hayvan çizimi/gradient/3D yok.
///
/// Pet türü ikonlarından ([PetTypeIcon]) ayrışır: bu, kullanıcıyı temsil eden
/// nötr pati; onlar tür ikonlarıdır.
class DefaultProfileAvatar extends StatelessWidget {
  const DefaultProfileAvatar({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.pawPrint,
        size: size * 0.5,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
