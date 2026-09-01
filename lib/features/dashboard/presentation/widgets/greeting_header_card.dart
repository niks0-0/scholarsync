import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../dashboard_provider.dart';
import 'dashboard_edit_mode_sheet.dart';

class GreetingHeaderCard extends StatelessWidget {
  const GreetingHeaderCard({super.key});

  void _showCustomizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DashboardEditModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final themeService = context.watch<ThemeService>();

    final user = auth.currentUser;
    final profile = profileProvider.profile;
    final greeting = DashboardProvider.getGreetingText();
    final name = profile?.fullName ?? user?.displayNameOrEmail ?? 'Student';
    final branch = profile?.branch ?? 'Academic Student';
    final semester = profile?.semester != null ? 'Semester ${profile!.semester}' : 'Fall Term';
    final avatarUrl = profile?.avatarUrl ?? user?.photoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Semantics(
                label: 'User profile avatar',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$branch • $semester',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Header Quick Bar (Search, Customize, Theme, Notifications)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Global Search',
                onPressed: () => context.push('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Customize Dashboard',
                onPressed: () => _showCustomizeSheet(context),
              ),
              IconButton(
                icon: Icon(
                  themeService.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () => themeService.toggle(),
              ),
              const Spacer(),
              Semantics(
                label: 'View Notifications',
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notifications',
                      onPressed: () => context.push('/notifications'),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
