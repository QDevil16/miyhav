import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/auth_error_mapper.dart';
import '../../../core/errors/profile_error_mapper.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/default_profile_avatar.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../auth/application/auth_providers.dart';
import '../application/profile_providers.dart';
import '../domain/profile.dart';

/// Kullanıcının kendi profil ekranı (MainShell profil sekmesi).
///
/// Yalnızca kendi profili gösterir/düzenler; sosyal profil, arkadaş profili,
/// keşfet veya pet profili KAPSAM DIŞIDIR.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Profile> profile = ref.watch(myProfileProvider);

    return profile.when(
      loading: () => const LoadingState(message: 'Profilin yükleniyor…'),
      error: (Object error, _) => _ProfileError(
        message: error is ProfileFailure
            ? error.message
            : ProfileErrorMapper.unavailable,
        onRetry: () => ref.invalidate(myProfileProvider),
      ),
      data: (Profile data) => _ProfileView(
        profile: data,
        signingOut: _signingOut,
        onEdit: () => context.push(AppRoutes.profileEdit),
        onSignOut: _signingOut ? null : _signOut,
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

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

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.profile,
    required this.signingOut,
    required this.onEdit,
    required this.onSignOut,
  });

  final Profile profile;
  final bool signingOut;
  final VoidCallback onEdit;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasBio = profile.shortBio != null;
    final bool hasCity = profile.city != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        const Center(child: DefaultProfileAvatar(size: 96)),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.displayName ?? 'İsim eklenmemiş',
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(
            color: profile.displayName != null
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          profile.usernameHandle,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (hasBio) ...<Widget>[
                Text(
                  profile.shortBio!,
                  style: AppTypography.body.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (hasCity)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: profile.city!,
                ),
              if (hasCity) const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: _visibilityIcon(profile.visibility),
                label: profile.visibility.label,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Profili Düzenle',
          icon: Icons.edit_rounded,
          onPressed: onEdit,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: signingOut ? 'Çıkış yapılıyor…' : 'Çıkış Yap',
          icon: Icons.logout_rounded,
          onPressed: onSignOut,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}

IconData _visibilityIcon(ProfileVisibility visibility) {
  switch (visibility) {
    case ProfileVisibility.private:
      return Icons.lock_outline_rounded;
    case ProfileVisibility.friendsOnly:
      return Icons.group_outlined;
    case ProfileVisibility.public:
      return Icons.public_rounded;
  }
}
