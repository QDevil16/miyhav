import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/pet_error_mapper.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validation/pet_validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/default_profile_avatar.dart';
import '../../../shared/widgets/miyhav_app_bar.dart';
import '../../../shared/widgets/pet_type_icon.dart';
import '../application/pet_providers.dart';
import '../data/pet_photo_picker.dart';
import '../data/pet_repository.dart';
import '../domain/pet.dart';

/// Pet ekleme/düzenleme ekranı. [pet] null ise ekleme, doluysa düzenleme.
class PetFormScreen extends ConsumerStatefulWidget {
  const PetFormScreen({super.key, this.pet});

  final Pet? pet;

  @override
  ConsumerState<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends ConsumerState<PetFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _microchipController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PetType _type = PetType.cat;
  PetSex? _sex;
  DateTime? _birthDate;
  bool _birthEstimated = false;
  bool _neutered = false;

  bool _saving = false;
  String? _formError;
  String? _nameError;
  String? _weightError;

  String? _photoPath;
  String? _photoUrl;
  bool _photoBusy = false;

  bool get _isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final Pet? pet = widget.pet;
    if (pet != null) {
      _nameController.text = pet.name;
      _breedController.text = pet.breed ?? '';
      _colorController.text = pet.color ?? '';
      _weightController.text = pet.currentWeight?.toString() ?? '';
      _microchipController.text = pet.microchipNumber ?? '';
      _descriptionController.text = pet.shortDescription ?? '';
      _type = pet.type;
      _sex = pet.sex;
      _birthDate = pet.birthDate;
      _birthEstimated = pet.isBirthDateEstimated;
      _neutered = pet.isNeutered ?? false;
      _photoPath = pet.profilePhotoPath;
      _loadSignedUrl();
    }
  }

  Future<void> _loadSignedUrl() async {
    final String? path = _photoPath;
    if (path == null) return;
    try {
      final String url = await ref
          .read(petMediaRepositoryProvider)
          .createSignedUrl(path);
      if (mounted) setState(() => _photoUrl = url);
    } on PetFailure {
      // İmzalı URL alınamazsa sessizce varsayılan avatara düşülür.
      if (mounted) setState(() => _photoUrl = null);
    }
  }

  Future<void> _pickPhoto() async {
    final PhotoSource? source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kameradan çek'),
              onTap: () => Navigator.of(ctx).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden seç'),
              onTap: () => Navigator.of(ctx).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _photoBusy = true);
    try {
      final Uint8List? bytes = await ref
          .read(petPhotoPickerProvider)
          .pickAndCrop(source);
      if (bytes == null) return; // kullanıcı vazgeçti
      final String name = await ref
          .read(petMediaRepositoryProvider)
          .uploadProfilePhoto(widget.pet!.id, bytes);
      await ref
          .read(petRepositoryProvider)
          .setProfilePhotoPath(widget.pet!.id, name);
      ref.invalidate(myPetsProvider);
      if (!mounted) return;
      _photoPath = name;
      _photoUrl = null;
      await _loadSignedUrl();
      if (mounted) _snack('Fotoğraf güncellendi.');
    } on PetFailure catch (failure) {
      if (mounted) _snack(failure.message);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _removePhoto() async {
    final String? path = _photoPath;
    if (path == null) return;
    setState(() => _photoBusy = true);
    try {
      await ref.read(petMediaRepositoryProvider).deleteProfilePhoto(path);
      await ref
          .read(petRepositoryProvider)
          .setProfilePhotoPath(widget.pet!.id, null);
      ref.invalidate(myPetsProvider);
      if (!mounted) return;
      setState(() {
        _photoPath = null;
        _photoUrl = null;
      });
      _snack('Fotoğraf silindi.');
    } on PetFailure catch (failure) {
      if (mounted) _snack(failure.message);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  PetDraft _draft() => PetDraft(
    name: _nameController.text,
    type: _type,
    breed: _breedController.text,
    sex: _sex,
    birthDate: _birthDate,
    isBirthDateEstimated: _birthEstimated,
    color: _colorController.text,
    currentWeight: PetValidators.parseWeight(_weightController.text),
    shortDescription: _descriptionController.text,
    microchipNumber: _microchipController.text,
    isNeutered: _neutered,
  );

  Future<void> _save() async {
    final String? nameError = PetValidators.name(_nameController.text);
    final String? weightError = PetValidators.weight(_weightController.text);
    final String? breedError = PetValidators.breed(_breedController.text);
    final String? colorError = PetValidators.color(_colorController.text);
    final String? descError = PetValidators.description(
      _descriptionController.text,
    );
    final String? microError = PetValidators.microchip(
      _microchipController.text,
    );
    setState(() {
      _nameError = nameError;
      _weightError = weightError;
      _formError = breedError ?? colorError ?? descError ?? microError;
    });
    if (nameError != null || weightError != null || _formError != null) return;

    setState(() => _saving = true);
    try {
      final PetRepository repo = ref.read(petRepositoryProvider);
      if (_isEdit) {
        await repo.updatePet(widget.pet!.id, _draft());
      } else {
        await repo.createPet(_draft());
      }
      ref.invalidate(myPetsProvider);
      if (!mounted) return;
      _snack(_isEdit ? 'Pet güncellendi.' : 'Pet eklendi.');
      _pop();
    } on PetFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: const Text('Peti sil'),
            content: Text(
              '${widget.pet!.name} silinsin mi? Bu işlem geri alınamaz.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _saving = true);
    try {
      await ref.read(petRepositoryProvider).deletePet(widget.pet!.id);
      ref.invalidate(myPetsProvider);
      if (!mounted) return;
      _snack('Pet silindi.');
      _pop();
    } on PetFailure catch (failure) {
      if (!mounted) return;
      setState(() => _formError = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 40),
      lastDate: now,
      helpText: 'Doğum tarihi',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _pop() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: <Widget>[
          MiyhavAppBar(title: _isEdit ? 'Peti Düzenle' : 'Pet Ekle'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: <Widget>[
                if (_isEdit) ...<Widget>[
                  _PhotoSection(
                    photoUrl: _photoUrl,
                    hasPhoto: _photoPath != null,
                    busy: _photoBusy,
                    onAddOrChange: _photoBusy ? null : _pickPhoto,
                    onRemove: _photoBusy ? null : _removePhoto,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  'Tür',
                  style: AppTypography.label.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final PetType type in PetType.values)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _type = type),
                        child: Column(
                          children: <Widget>[
                            PetTypeIcon(
                              type: type,
                              size: 56,
                              selected: _type == type,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              petTypeLabel(type),
                              style: AppTypography.caption.copyWith(
                                color: _type == type
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Ad',
                  hint: 'Örn. Pamuk',
                  controller: _nameController,
                  prefixIcon: Icons.pets_rounded,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _label(context, 'Cinsiyet'),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final PetSex sex in PetSex.values)
                      _ChoiceChip(
                        label: sex.label,
                        selected: _sex == sex,
                        onTap: () =>
                            setState(() => _sex = _sex == sex ? null : sex),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _DateRow(
                  date: _birthDate,
                  onPick: _pickBirthDate,
                  onClear: () => setState(() => _birthDate = null),
                ),
                if (_birthDate != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tahmini doğum tarihi'),
                    value: _birthEstimated,
                    onChanged: (bool v) => setState(() => _birthEstimated = v),
                  ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Cins (opsiyonel)',
                  controller: _breedController,
                  prefixIcon: Icons.category_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Renk (opsiyonel)',
                  controller: _colorController,
                  prefixIcon: Icons.palette_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Ağırlık kg (opsiyonel)',
                  hint: 'Örn. 4.5',
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.monitor_weight_outlined,
                  errorText: _weightError,
                  onChanged: (_) {
                    if (_weightError != null) {
                      setState(() => _weightError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Mikroçip no (opsiyonel)',
                  controller: _microchipController,
                  prefixIcon: Icons.qr_code_2_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Açıklama (opsiyonel)',
                  controller: _descriptionController,
                  maxLines: 3,
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kısırlaştırıldı'),
                  value: _neutered,
                  onChanged: (bool v) => setState(() => _neutered = v),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_formError != null) ...<Widget>[
                  Text(
                    _formError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: scheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                PrimaryButton(
                  label: 'Kaydet',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                if (_isEdit) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Peti Sil',
                    icon: Icons.delete_outline_rounded,
                    onPressed: _saving ? null : _delete,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
    text,
    style: AppTypography.label.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

/// Pet profil fotoğrafı bölümü: önizleme (yoksa DefaultProfileAvatar) + ekle/
/// değiştir/sil eylemleri + yükleme göstergesi.
class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photoUrl,
    required this.hasPhoto,
    required this.busy,
    required this.onAddOrChange,
    required this.onRemove,
  });

  final String? photoUrl;
  final bool hasPhoto;
  final bool busy;
  final VoidCallback? onAddOrChange;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    const double size = 104;
    return Column(
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const DefaultProfileAvatar(size: size),
                      )
                    : const DefaultProfileAvatar(size: size),
              ),
              if (busy)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x66000000),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              onPressed: onAddOrChange,
              icon: Icon(
                hasPhoto ? Icons.edit_outlined : Icons.add_a_photo_outlined,
              ),
              label: Text(hasPhoto ? 'Fotoğraf Değiştir' : 'Fotoğraf Ekle'),
            ),
            if (hasPhoto)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Fotoğraf Sil'),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.12)
          : scheme.surfaceContainerHighest,
      borderRadius: AppRadius.allPill,
      child: InkWell(
        borderRadius: AppRadius.allPill,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.allPill,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: selected ? scheme.primary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String text = date == null
        ? 'Doğum tarihi (opsiyonel)'
        : '${date!.day.toString().padLeft(2, '0')}.'
              '${date!.month.toString().padLeft(2, '0')}.${date!.year}';
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.cake_outlined, size: 18),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(text, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        if (date != null)
          IconButton(
            onPressed: onClear,
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
          ),
      ],
    );
  }
}
