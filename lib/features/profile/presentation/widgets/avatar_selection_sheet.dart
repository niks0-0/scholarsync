import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/student_avatar.dart';

/// Interactive modal sheet to pick between Male, Female, Blank, or Custom Gallery avatar.
class AvatarSelectionSheet extends StatelessWidget {
  const AvatarSelectionSheet({
    super.key,
    required this.currentAvatarUrl,
    this.currentBytes,
    required this.studentName,
    required this.onSelectPreset,
    required this.onSelectBytes,
  });

  final String? currentAvatarUrl;
  final Uint8List? currentBytes;
  final String studentName;
  final ValueChanged<String> onSelectPreset;
  final ValueChanged<Uint8List> onSelectBytes;

  static Future<void> show({
    required BuildContext context,
    required String? currentAvatarUrl,
    Uint8List? currentBytes,
    required String studentName,
    required ValueChanged<String> onSelectPreset,
    required ValueChanged<Uint8List> onSelectBytes,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarSelectionSheet(
        currentAvatarUrl: currentAvatarUrl,
        currentBytes: currentBytes,
        studentName: studentName,
        onSelectPreset: onSelectPreset,
        onSelectBytes: onSelectBytes,
      ),
    );
  }

  Future<void> _pickCustomImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        onSelectBytes(bytes);
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final isMaleSelected = currentBytes == null && currentAvatarUrl == AvatarPresets.male;
    final isFemaleSelected = currentBytes == null && currentAvatarUrl == AvatarPresets.female;
    final isBlankSelected = currentBytes == null && (currentAvatarUrl == null || currentAvatarUrl!.isEmpty);
    final isCustomSelected = currentBytes != null || (currentAvatarUrl != null && currentAvatarUrl!.startsWith('http'));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Avatar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Select a cartoon avatar, clean blank initial, or upload custom',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preset Avatars Grid
          Row(
            children: [
              // 1. Male Avatar Option
              Expanded(
                child: _buildAvatarOption(
                  context,
                  title: 'Male',
                  isSelected: isMaleSelected,
                  avatarWidget: const StudentAvatar(
                    avatarUrl: AvatarPresets.male,
                    radius: 36,
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectPreset(AvatarPresets.male);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. Female Avatar Option
              Expanded(
                child: _buildAvatarOption(
                  context,
                  title: 'Female',
                  isSelected: isFemaleSelected,
                  avatarWidget: const StudentAvatar(
                    avatarUrl: AvatarPresets.female,
                    radius: 36,
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectPreset(AvatarPresets.female);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 3. Blank / Initial Logo Option
              Expanded(
                child: _buildAvatarOption(
                  context,
                  title: 'Blank (Initials)',
                  isSelected: isBlankSelected,
                  avatarWidget: StudentAvatar(
                    avatarUrl: AvatarPresets.blank,
                    name: studentName,
                    radius: 36,
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectPreset(AvatarPresets.blank);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 4. Custom Gallery Upload Button
          InkWell(
            onTap: () => _pickCustomImage(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isCustomSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCustomSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: isCustomSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Custom Photo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Select your personal image from device storage',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required Widget avatarWidget,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            avatarWidget,
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
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
