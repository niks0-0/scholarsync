import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';

class ProfileStep extends StatefulWidget {
  const ProfileStep({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<ProfileStep> {
  late TextEditingController _nameController;

  // Sample avatar presets for quick selection if live file picker isn't available
  static final Map<String, Uint8List> _avatarPresets = {
    'Student Avatar 1': base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    ),
    'Student Avatar 2': base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    ),
  };

  @override
  void initState() {
    super.initState();
    final onboarding = context.read<OnboardingProvider>();
    _nameController = TextEditingController(text: onboarding.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Profile & Avatar',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Customize your student display name and upload a profile avatar.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Avatar Image Preview & Upload Container
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: onboarding.avatarUrl != null && onboarding.avatarUrl!.isNotEmpty
                            ? NetworkImage(onboarding.avatarUrl!)
                            : null,
                        child: onboarding.avatarUrl == null || onboarding.avatarUrl!.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                size: 55,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Profile Avatar',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supports JPG, PNG, WEBP, GIF (Max 5MB)',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  children: _avatarPresets.entries.map((entry) {
                    return ActionChip(
                      avatar: const Icon(Icons.image_outlined, size: 16),
                      label: Text(entry.key),
                      onPressed: () {
                        onboarding.setAvatarBytes(entry.value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${entry.key} selected for upload!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Full Name Input
          Text(
            'Full Display Name',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          AppTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            prefixIcon: Icons.person_outline_rounded,
            onChanged: (val) => onboarding.setFullName(val),
          ),

          if (onboarding.error != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onboarding.error!,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingXxxl),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onboarding.previousStep();
                    widget.onPrevious();
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    onboarding.setFullName(_nameController.text);
                    if (onboarding.nextStep()) {
                      widget.onNext();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
