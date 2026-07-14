import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miyhav/core/theme/app_colors.dart';
import 'package:miyhav/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('açık tema Jost fontu ve marka rengini kullanır', () {
      final ThemeData t = AppTheme.light;
      expect(t.useMaterial3, isTrue);
      expect(t.textTheme.bodyLarge?.fontFamily, 'Jost');
      expect(t.colorScheme.primary, AppColors.primary);
      expect(t.colorScheme.brightness, Brightness.light);
    });

    test('koyu tema doğru parlaklıkta üretilir', () {
      final ThemeData t = AppTheme.dark;
      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.scaffoldBackgroundColor, AppColors.darkBackground);
    });
  });
}
