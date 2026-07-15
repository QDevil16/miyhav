import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/profile_error_mapper.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validation/profile_validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/miyhav_app_bar.dart';
import '../application/profile_providers.dart';
import '../domain/profile.dart';

/// Kullanıcının kendi profilini düzenlediği ekran.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _initialized = false;
  bool _saving = false;
  String? _formError;
  String? _displayNameError;
  String? _usernameError;
  String? _bioError;
  String? _cityError;
  int _bioLength = 0;
  ProfileVisibility _visibility = ProfileVisibility.private;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initFrom(Profile profile) {
    if (_initialized) return;
    _initialized = true;
    _displayNameController.text = profile.displayName ?? '';
    _usernameController.text = profile.username ?? '';
    _bioController.text = profile.shortBio ?? '';
    _cityController.text = profile.city ?? '';
    _bioLength = (profile.shortBio ?? '').characters.length;
    _visibility = profile.visibility;
  }

  Future<void> _save() async {
    final String? displayNameError = ProfileValidators.displayName(
      _displayNameController.text,
    );
    final String? usernameError = ProfileValidators.username(
      _usernameController.text,
    );
    final String? bioError = ProfileValidators.bio(_bioController.text);
    final String? cityError = ProfileValidators.city(_cityController.text);
    setState(() {
      _displayNameError = displayNameError;
      _usernameError = usernameError;
      _bioError = bioError;
      _cityError = cityError;
      _formError = null;
    });
    if (displayNameError != null ||
        usernameError != null ||
        bioError != null ||
        cityError != null) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateMyProfile(
            displayName: _displayNameController.text,
            username: _usernameController.text,
            shortBio: _bioController.text,
            city: _cityController.text,
            visibility: _visibility,
          );
      // Profil ekranı taze veriyi göstersin.
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profilin güncellendi.')));
      final NavigatorState navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Profile> profile = ref.watch(myProfileProvider);

    return Scaffold(
      body: Column(
        children: <Widget>[
          const MiyhavAppBar(title: 'Profili Düzenle'),
          Expanded(
            child: profile.when(
              loading: () => const LoadingState(message: 'Yükleniyor…'),
              error: (Object error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    error is ProfileFailure
                        ? error.message
                        : ProfileErrorMapper.unavailable,
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ),
              ),
              data: (Profile data) {
                _initFrom(data);
                return _form(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        // Profil fotoğrafı: bu görevde yükleme yok, yalnızca bilgilendirme.
        AppTextField(
          label: 'Görünen ad',
          hint: 'Örn. Ada',
          controller: _displayNameController,
          prefixIcon: Icons.badge_outlined,
          errorText: _displayNameError,
          onChanged: (_) {
            if (_displayNameError != null) {
              setState(() => _displayNameError = null);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Kullanıcı adı',
          hint: 'harf, rakam, alt çizgi',
          controller: _usernameController,
          prefixIcon: Icons.alternate_email_rounded,
          errorText: _usernameError,
          onChanged: (_) {
            if (_usernameError != null) setState(() => _usernameError = null);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Kısa biyografi',
          hint: 'Kendinden kısaca bahset',
          controller: _bioController,
          maxLines: 4,
          prefixIcon: Icons.notes_rounded,
          errorText: _bioError,
          onChanged: (String value) {
            setState(() {
              _bioLength = value.characters.length;
              if (_bioError != null) _bioError = null;
            });
          },
        ),
        const SizedBox(height: AppSpacing.xxs),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_bioLength/${ProfileValidators.bioMax}',
            style: AppTypography.caption.copyWith(
              color: _bioLength > ProfileValidators.bioMax
                  ? scheme.error
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Şehir',
          hint: 'Örn. İstanbul',
          controller: _cityController,
          prefixIcon: Icons.location_on_outlined,
          errorText: _cityError,
          onChanged: (_) {
            if (_cityError != null) setState(() => _cityError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Profil gizliliği',
          style: AppTypography.label.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final ProfileVisibility option
            in ProfileVisibility.values) ...<Widget>[
          _VisibilityTile(
            option: option,
            selected: _visibility == option,
            onTap: () => setState(() => _visibility = option),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        AuthErrorTextProfile(_formError),
        PrimaryButton(
          label: 'Kaydet',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

/// Profil düzenlemede ham hata yerine Türkçe hata satırı.
class AuthErrorTextProfile extends StatelessWidget {
  const AuthErrorTextProfile(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message!,
              style: AppTypography.bodySmall.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gizlilik seçeneği kartı (etiket + kısa açıklama; seçiliyken coral vurgu).
class _VisibilityTile extends StatelessWidget {
  const _VisibilityTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ProfileVisibility option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.10)
          : scheme.surfaceContainerHighest,
      borderRadius: AppRadius.allLg,
      child: InkWell(
        borderRadius: AppRadius.allLg,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.allLg,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.6,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      option.label,
                      style: AppTypography.label.copyWith(
                        color: scheme.onSurface,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      option.description,
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
