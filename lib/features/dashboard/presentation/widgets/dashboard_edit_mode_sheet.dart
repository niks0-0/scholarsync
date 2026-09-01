import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../dashboard_personalization_provider.dart';
import '../dashboard_widget_registry.dart';

class DashboardEditModeSheet extends StatelessWidget {
  const DashboardEditModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final personalization = context.watch<DashboardPersonalizationProvider>();

    final activeIds = personalization.activeWidgetIds;
    final hiddenIds = personalization.hiddenWidgetIds;
    final pinnedIds = personalization.pinnedWidgetIds;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXxl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Customize Dashboard Layout',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => personalization.resetToDefaultLayout(),
                child: const Text('Reset Default'),
              ),
            ],
          ),
          Text(
            'Drag to reorder widgets, pin favorites to top, or hide widgets you do not need.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: activeIds.length,
              onReorderItem: (oldIndex, newIndex) => personalization.reorderWidgets(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final id = activeIds[index];
                final config = DashboardWidgetRegistry.getWidget(id);
                if (config == null) return SizedBox(key: ValueKey(id));

                final isPinned = pinnedIds.contains(id);
                final isHidden = hiddenIds.contains(id);

                return Container(
                  key: ValueKey(id),
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: isHidden
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isPinned ? AppColors.primary : colorScheme.outline.withValues(alpha: 0.3),
                      width: isPinned ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        config.icon,
                        color: isHidden ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.title,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isHidden ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              config.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Pin Toggle
                      IconButton(
                        icon: Icon(
                          isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          color: isPinned ? AppColors.primary : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: isPinned ? 'Unpin from top' : 'Pin to top',
                        onPressed: () => personalization.togglePinWidget(id),
                      ),
                      // Hide/Show Toggle
                      IconButton(
                        icon: Icon(
                          isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isHidden ? colorScheme.onSurfaceVariant : AppColors.primary,
                          size: 20,
                        ),
                        tooltip: isHidden ? 'Show widget' : 'Hide widget',
                        onPressed: () {
                          if (isHidden) {
                            personalization.showWidget(id);
                          } else {
                            personalization.hideWidget(id);
                          }
                        },
                      ),
                      const ReorderableDragStartListener(
                        index: 0,
                        child: Icon(Icons.drag_handle_rounded),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save Layout & Close'),
            ),
          ),
        ],
      ),
    );
  }
}
