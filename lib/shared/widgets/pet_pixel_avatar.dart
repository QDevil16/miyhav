import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Miyhav özgün pixel-art pet türleri (placeholder asset sistemi).
///
/// Gerçek kullanıcı fotoğrafı yüklenene kadar gösterilir. Görseller indirilmez;
/// tamamen kod içinde, özgün pixel desenlerinden çizilir (telifsiz).
enum PixelPetKind { cat, dog, bird, rabbit, other }

/// Bir tür ismini ([pets.species] değerleri) pixel türüne eşler.
PixelPetKind pixelPetKindFromSpecies(String? species) {
  switch (species) {
    case 'cat':
      return PixelPetKind.cat;
    case 'dog':
      return PixelPetKind.dog;
    case 'bird':
      return PixelPetKind.bird;
    case 'rabbit':
      return PixelPetKind.rabbit;
    default:
      return PixelPetKind.other; // fish / reptile / other → jenerik pati
  }
}

/// Özgün pixel-art pet avatarı. Dairesel bir yüzey içinde 12×12 pixel deseni
/// çizer. [size] avatar çapıdır.
class PetPixelAvatar extends StatelessWidget {
  const PetPixelAvatar({
    super.key,
    this.kind = PixelPetKind.other,
    this.size = 72,
  });

  final PixelPetKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _PixelPetPainter(_grids[kind]!, _paletteFor(kind)),
      ),
    );
  }
}

/// Palet harfleri → renk. Her tür kendi gövde tonunu kullanır.
Map<String, Color> _paletteFor(PixelPetKind kind) {
  final Color body = switch (kind) {
    PixelPetKind.cat => const Color(0xFFC68A63),
    PixelPetKind.dog => const Color(0xFFB9855C),
    PixelPetKind.bird => AppColors.secondary,
    PixelPetKind.rabbit => const Color(0xFFCFC3B8),
    PixelPetKind.other => AppColors.primary,
  };
  return <String, Color>{
    'B': body,
    'D': Color.lerp(body, const Color(0xFF3A241A), 0.45)!, // koyu kenar
    'L': const Color(0xFFF3E9DF), // krem karın
    'P': const Color(0xFFE79A93), // pembe burun/kulak içi
    'E': const Color(0xFF2B2320), // göz
    'W': const Color(0xFFFFFBF8), // beyaz vurgu
  };
}

class _PixelPetPainter extends CustomPainter {
  _PixelPetPainter(this.grid, this.palette);

  final List<String> grid;
  final Map<String, Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = grid.length;
    final int cols = grid.first.length;
    final double cw = size.width / cols;
    final double ch = size.height / rows;
    final Paint paint = Paint()..isAntiAlias = false;

    for (int r = 0; r < rows; r++) {
      final String line = grid[r];
      for (int c = 0; c < cols; c++) {
        final String ch0 = line[c];
        final Color? color = palette[ch0];
        if (color == null) continue; // '.' → şeffaf
        paint.color = color;
        // Hafif bindirme ile pixel araları kapanır.
        canvas.drawRect(
          Rect.fromLTWH(c * cw, r * ch, cw + 0.6, ch + 0.6),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPetPainter oldDelegate) =>
      oldDelegate.grid != grid || oldDelegate.palette != palette;
}

/// 12×12 özgün pixel desenleri. '.' = şeffaf.
const Map<PixelPetKind, List<String>> _grids = <PixelPetKind, List<String>>{
  PixelPetKind.cat: <String>[
    '..DD....DD..',
    '.DBD....DBD.',
    '.DBBD..DBBD.',
    '.DBBBDDBBBD.',
    '.DBBBBBBBBD.',
    'DBBBBBBBBBBD',
    'DBEBBBBBBEBD',
    'DBBBBPPBBBBD',
    'DBBBWPPWBBBD',
    '.DBBBBBBBBD.',
    '..DBBBBBBD..',
    '...DDDDDD...',
  ],
  PixelPetKind.dog: <String>[
    '...BBBBBB...',
    '.DDBBBBBBDD.',
    '.DBBBBBBBBD.',
    '.DBBBBBBBBD.',
    'DDBBBBBBBBDD',
    'DBBEBBBBEBBD',
    'DBBBBBBBBBBD',
    'DBBBBDDBBBBD',
    '.BBBBDDBBBB.',
    '.DBBBBBBBBD.',
    '..DBBBBBBD..',
    '...DDDDDD...',
  ],
  PixelPetKind.bird: <String>[
    '....DDD.....',
    '...DBBBD....',
    '..DBBBBBD...',
    '.DBBEBBBBD..',
    '.DBBBBBBBDPP',
    'DBBBBBBBBBP.',
    'DBBBLLLBBBD.',
    'DBBLLLLLBBD.',
    '.DBBLLLBBD..',
    '..DBBBBBD...',
    '...DBBBD....',
    '...P...P....',
  ],
  PixelPetKind.rabbit: <String>[
    '..DBD.DBD...',
    '..DBD.DBD...',
    '..DBD.DBD...',
    '..DBBDDBBD..',
    '...DBBBBD...',
    '..DBBBBBBD..',
    '.DBEBBBBEBD.',
    '.DBBBPPBBBD.',
    '.DBBBBBBBBD.',
    '..DBBBBBBD..',
    '...DBBBBD...',
    '....DDDD....',
  ],
  PixelPetKind.other: <String>[
    '..DD....DD..',
    '.DBBD..DBBD.',
    '.DBBD..DBBD.',
    '..DD....DD..',
    '............',
    'DD........DD',
    'BBD......DBB',
    'BBD......DBB',
    '.D..DDDD..D.',
    '...DBBBBD...',
    '..DBBBBBBD..',
    '..DBBBBBBD..',
  ],
};
