import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarsync/core/constants/app_dimensions.dart';
import 'package:scholarsync/core/theme/app_colors.dart';
import 'package:scholarsync/features/admin/domain/models/moderation_report.dart';
import 'package:scholarsync/features/admin/presentation/admin_provider.dart';
import 'package:scholarsync/features/dashboard/presentation/widgets/dashboard_skeleton_loader.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadModerationReports();
    });
  }

  void _openReportActionModal(BuildContext context, ModerationReport report) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final notesController = TextEditingController();
    String selectedAction = 'warned';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resolve Moderation Ticket',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entity: ${report.entityType.toUpperCase()} (ID: ${report.entityId})',
                        style: textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Reported User: ${report.reportedUserName ?? report.reportedUserId}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Reason: ${report.reason}', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Resolution Action', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Warn User'),
                    selected: selectedAction == 'warned',
                    selectedColor: AppColors.warning.withValues(alpha: 0.2),
                    onSelected: (_) => setModalState(() => selectedAction = 'warned'),
                  ),
                  ChoiceChip(
                    label: const Text('Suspend Account'),
                    selected: selectedAction == 'suspended',
                    selectedColor: AppColors.error.withValues(alpha: 0.2),
                    onSelected: (_) => setModalState(() => selectedAction = 'suspended'),
                  ),
                  ChoiceChip(
                    label: const Text('Delete Content'),
                    selected: selectedAction == 'deleted_content',
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) => setModalState(() => selectedAction = 'deleted_content'),
                  ),
                  ChoiceChip(
                    label: const Text('Dismiss Report'),
                    selected: selectedAction == 'none',
                    selectedColor: colorScheme.surfaceContainerHighest,
                    onSelected: (_) => setModalState(() => selectedAction = 'none'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Resolution Audit Notes',
                  hintText: 'Describe the reasoning for this administrative resolution...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.gavel_rounded),
                  label: const Text('Submit Resolution', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await context.read<AdminProvider>().resolveModerationReport(
                          report.id,
                          selectedAction,
                          notesController.text.trim(),
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Report resolved successfully.' : 'Failed to resolve report.'),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final admin = context.watch<AdminProvider>();
    final reports = admin.reports;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unified Moderation Center',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${reports.length} moderation tickets requiring administrative review',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Queue',
                  onPressed: () => admin.loadModerationReports(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pending Review'),
                    selected: admin.selectedReportStatusFilter == 'pending',
                    selectedColor: AppColors.warning.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setReportStatusFilter('pending'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Resolved'),
                    selected: admin.selectedReportStatusFilter == 'resolved',
                    selectedColor: AppColors.success.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setReportStatusFilter('resolved'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All Reports'),
                    selected: admin.selectedReportStatusFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setReportStatusFilter(null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reports List
            Expanded(
              child: admin.isLoading
                  ? ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => const DashboardSkeletonLoader(height: 100),
                    )
                  : reports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user_outlined, size: 56, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'Moderation Queue is Clean',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No pending tickets require attention.',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: reports.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = reports[index];
                            final isPending = item.status == 'pending';
                            final isUrgent = item.priority == 'urgent' || item.priority == 'high';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isUrgent
                                      ? AppColors.error.withValues(alpha: 0.5)
                                      : colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isUrgent ? AppColors.error : AppColors.warning)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.priority.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isUrgent ? AppColors.error : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.entityType.toUpperCase(),
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.status.toUpperCase(),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: isPending ? AppColors.warning : AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.reason,
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reported User: ${item.reportedUserName ?? item.reportedUserId}',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                  if (isPending) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.tonalIcon(
                                        icon: const Icon(Icons.gavel_rounded, size: 16),
                                        label: const Text('Take Action'),
                                        onPressed: () => _openReportActionModal(context, item),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
