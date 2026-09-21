import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Clean Modern Minimalist Text Input Field for ScholarSync.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.autofillHints,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF334155),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          obscureText: obscureText,
          autofillHints: autofillHints,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 14.5,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF141418)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 19,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  )
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
