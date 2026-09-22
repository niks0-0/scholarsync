import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/student_avatar.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../../../profile/presentation/widgets/avatar_selection_sheet.dart';
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

          // Avatar Image Preview & Options Selector
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    AvatarSelectionSheet.show(
                      context: context,
                      currentAvatarUrl: onboarding.avatarUrl,
                      currentBytes: onboarding.avatarBytesToUpload,
                      studentName: onboarding.fullName.isNotEmpty ? onboarding.fullName : 'Student',
                      onSelectPreset: (preset) => onboarding.setAvatarUrl(preset),
                      onSelectBytes: (bytes) => onboarding.setAvatarBytes(bytes),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: StudentAvatar(
                          radius: 48,
                          avatarUrl: onboarding.avatarUrl,
                          imageBytes: onboarding.avatarBytesToUpload,
                          name: onboarding.fullName.isNotEmpty ? onboarding.fullName : 'Student',
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Choose Profile Avatar',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select male, female, blank initial, or custom photo',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // 3 Avatar Option Tiles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Male Avatar Option
                    _buildAvatarChip(
                      context,
                      title: 'Male',
                      avatarUrl: AvatarPresets.male,
                      isSelected: onboarding.avatarBytesToUpload == null &&
                          onboarding.avatarUrl == AvatarPresets.male,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onboarding.setAvatarUrl(AvatarPresets.male);
                      },
                    ),
                    const SizedBox(width: 12),

                    // Female Avatar Option
                    _buildAvatarChip(
                      context,
                      title: 'Female',
                      avatarUrl: AvatarPresets.female,
                      isSelected: onboarding.avatarBytesToUpload == null &&
                          onboarding.avatarUrl == AvatarPresets.female,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onboarding.setAvatarUrl(AvatarPresets.female);
                      },
                    ),
                    const SizedBox(width: 12),

                    // Blank / Initials Option
                    _buildAvatarChip(
                      context,
                      title: 'Blank',
                      avatarUrl: AvatarPresets.blank,
                      name: onboarding.fullName,
                      isSelected: onboarding.avatarBytesToUpload == null &&
                          (onboarding.avatarUrl == null ||
                              onboarding.avatarUrl!.isEmpty),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onboarding.setAvatarUrl(AvatarPresets.blank);
                      },
                    ),
                  ],
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

  Widget _buildAvatarChip(
    BuildContext context, {
    required String title,
    required String avatarUrl,
    String? name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StudentAvatar(
              avatarUrl: avatarUrl,
              name: name,
              radius: 24,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
