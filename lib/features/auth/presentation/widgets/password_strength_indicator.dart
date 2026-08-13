import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';

/// 4-segment password strength indicator bar.
/// Pass the current password value and it computes the strength score.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  static const List<Color> _segmentColors = [
    AppColors.error,
    AppColors.warning,
    AppColors.primary,
    AppColors.success,
  ];

  static const List<String> _labels = [
    AppStrings.strengthWeak,
    AppStrings.strengthFair,
    AppStrings.strengthGood,
    AppStrings.strengthStrong,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (password.isEmpty) return const SizedBox.shrink();

    // Score: 1–4 (clamp from validator's 0–4 to display 1–4 segments)
    final int rawScore = AppValidators.passwordStrength(password);
    final int score = rawScore.clamp(1, 4);
    final Color activeColor = _segmentColors[score - 1];
    final String label = _labels[score - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Segments ─────────────────────────────────────────────────────────
        Row(
          children: List.generate(4, (index) {
            final bool active = index < score;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: AppDimensions.strengthBarHeight,
                margin: EdgeInsets.only(
                  right: index < 3 ? AppDimensions.strengthBarSpacing : 0,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor
                      : colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppDimensions.spacingXs),

        // ── Label ─────────────────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: textTheme.labelSmall?.copyWith(
              color: activeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

