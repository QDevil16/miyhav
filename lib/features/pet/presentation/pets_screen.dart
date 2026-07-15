import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/pet_error_mapper.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/pet_type_icon.dart';
import '../application/pet_providers.dart';
import '../domain/pet.dart';

/// "Petlerim" sekmesi — kullanıcının kendi petlerini listeler.
class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Pet>> pets = ref.watch(myPetsProvider);

    return pets.when(
      loading: () => const LoadingState(message: 'Petlerin yükleniyor…'),
      error: (Object error, _) => _PetsError(
        message: error is PetFailure ? error.message : PetErrorMapper.generic,
        onRetry: () => ref.invalidate(myPetsProvider),
      ),
      data: (List<Pet> list) {
        if (list.isEmpty) {
          return EmptyState(
            title: 'Henüz pet eklemedin',
            message: 'İlk pet dostunu ekleyerek başla.',
            icon: Icons.pets_rounded,
            actionLabel: 'Pet Ekle',
            onAction: () => context.push(AppRoutes.petForm),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            PrimaryButton(
              label: 'Pet Ekle',
              icon: Icons.add_rounded,
              onPressed: () => context.push(AppRoutes.petForm),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final Pet pet in list) ...<Widget>[
              _PetCard(
                pet: pet,
                onTap: () => context.push(AppRoutes.petForm, extra: pet),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> meta = <String>[
      pet.speciesLabel,
      if (pet.breed != null) pet.breed!,
      if (pet.sex != null) pet.sex!.label,
    ];

    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          PetTypeIcon(type: pet.type, size: 56),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  meta.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _PetsError extends StatelessWidget {
  const _PetsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Tekrar dene',
              icon: Icons.refresh_rounded,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
