import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Horizontal divider with centered label (typically "or continue with").
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.label = 'or',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outline,
            thickness: AppDimensions.dividerThickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dividerHorizontalPadding,
          ),
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outline,
            thickness: AppDimensions.dividerThickness,
          ),
        ),
      ],
    );
  }
}

