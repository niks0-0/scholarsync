import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ClassificationLevel {
  required,
  recommended,
  optional,
}

/// Visual field classification badge for ScholarSync Student Onboarding.
class OnboardingClassificationBadge extends StatelessWidget {
  const OnboardingClassificationBadge({
    super.key,
    required this.level,
  });

  final ClassificationLevel level;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    String label;

    switch (level) {
      case ClassificationLevel.required:
        bg = AppColors.error.withValues(alpha: 0.12);
        border = AppColors.error.withValues(alpha: 0.4);
        text = AppColors.error;
        label = 'REQUIRED';
        break;
      case ClassificationLevel.recommended:
        bg = AppColors.primary.withValues(alpha: 0.15);
        border = AppColors.primary.withValues(alpha: 0.4);
        text = AppColors.primary;
        label = 'RECOMMENDED';
        break;
      case ClassificationLevel.optional:
        bg = Colors.white.withValues(alpha: 0.06);
        border = Colors.white.withValues(alpha: 0.15);
        text = Colors.white60;
        label = 'OPTIONAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.9),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
