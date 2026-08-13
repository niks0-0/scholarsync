import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Shared scroll-safe layout scaffold for all auth screens.
/// Handles keyboard avoidance, safe area, and centering with max-width.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.centerContent = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.authMaxWidth,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.authHorizontalPadding,
                vertical: AppDimensions.spacingXxl,
              ),
              child: centerContent
                  ? Center(child: child)
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}

