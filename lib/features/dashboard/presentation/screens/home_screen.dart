import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../dashboard_personalization_provider.dart';
import '../dashboard_provider.dart';
import '../dashboard_widget_registry.dart';
import '../widgets/dashboard_edit_mode_sheet.dart';
import '../widgets/smart_fab.dart';

/// Production Home Dashboard composed dynamically from [DashboardWidgetRegistry].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<DashboardProvider>().loadDashboard(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<DashboardProvider>().refreshAll(user.uid);
    }
  }

  void _openEditModeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DashboardEditModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final personalization = context.watch<DashboardPersonalizationProvider>();
    final dashboard = context.watch<DashboardProvider>();

    final displayIds = personalization.displayWidgetIds;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: SmartFab(scrollController: _scrollController),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _openEditModeSheet,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top Synchronization & Customization Banner
                if (dashboard.lastSyncedTime != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sync_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'Last synced: ${dashboard.lastSyncedTime}',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.tune_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Long-press to customize',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Modular Widgets List composed via Registry
                SliverPadding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final widgetId = displayIds[index];
                        final config = DashboardWidgetRegistry.getWidget(widgetId);
                        if (config == null) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
                          child: config.builder(context),
                        );
                      },
                      childCount: displayIds.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.spacingXxxl * 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
