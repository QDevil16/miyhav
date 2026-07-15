import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Miyhav metin alanı — etiket + tema tabanlı yuvarlatılmış input.
/// Şifre alanı için [obscure] ile göster/gizle desteği içerir.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  /// Çok satırlı giriş için (ör. biyografi). Şifre alanında yok sayılır.
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: AppTypography.label.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          style: AppTypography.body.copyWith(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: scheme.onSurfaceVariant)
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_off : Icons.visibility,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
