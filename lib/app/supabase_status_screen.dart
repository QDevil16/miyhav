import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/networking/supabase_bootstrap.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../shared/widgets/app_card.dart';

/// Supabase hazır olmadığında gösterilen kontrollü ekran.
///
/// Ham hata veya boş ekran YERİNE anlaşılır bir durum gösterir. Geliştirme
/// ortamında eksik yapılandırma için kurulum adımları; üretimde sade, kontrollü
/// bir mesaj verir.
class SupabaseStatusScreen extends StatelessWidget {
  const SupabaseStatusScreen({super.key, required this.status});

  final SupabaseStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isMissing = status == SupabaseStatus.missingConfig;

    final String title = isMissing ? 'Kurulum gerekli' : 'Bağlantı kurulamadı';
    final String message = isMissing
        ? 'Uygulamanın çalışması için Supabase bağlantı bilgileri gerekiyor.'
        : 'Sunucuya şu anda bağlanılamadı. Lütfen daha sonra tekrar deneyin.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMissing
                        ? Icons.settings_suggest_rounded
                        : Icons.cloud_off_rounded,
                    size: 42,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                // Kurulum ayrıntıları yalnızca geliştirme ortamında gösterilir.
                if (isMissing && AppConfig.isDevelopment) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  const _DevSetupHint(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevSetupHint extends StatelessWidget {
  const _DevSetupHint();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Geliştirici notu',
            style: AppTypography.label.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'config/dev.json içindeki SUPABASE_URL ve SUPABASE_ANON_KEY '
            'değerlerini doldurup şu komutla çalıştırın:',
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: AppRadius.allSm,
            ),
            child: Text(
              'flutter run \\\n'
              '  --dart-define-from-file=config/dev.json',
              style: AppTypography.caption.copyWith(
                fontFamily: 'monospace',
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ayrıntı: docs/ENVIRONMENT_SETUP.md',
            style: AppTypography.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
