import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Rounded surface card with subtle border and optional shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.addShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final bool addShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card = Card(
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppDimensions.radiusLg),
        ),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.6),
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      elevation: addShadow ? AppDimensions.elevationSm : AppDimensions.elevationNone,
      shadowColor: addShadow ? colorScheme.shadow : Colors.transparent,
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(AppDimensions.cardPaddingMd),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppDimensions.radiusLg),
        ),
        child: card,
      );
    }

    return card;
  }
}

