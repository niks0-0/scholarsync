import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarsync/core/constants/app_dimensions.dart';
import 'package:scholarsync/core/theme/app_colors.dart';
import 'package:scholarsync/features/admin/domain/models/moderation_report.dart';
import 'package:scholarsync/features/admin/domain/models/moderation_context.dart';
import 'package:scholarsync/features/admin/domain/models/chat_message.dart';
import 'package:scholarsync/features/admin/presentation/admin_provider.dart';
import 'package:scholarsync/features/dashboard/presentation/widgets/dashboard_skeleton_loader.dart';

/// Contextual Moderation Center with Graduated Human Review Studio & Safe-Lock Triggers.
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

  void _openContextualReviewStudio(BuildContext context, ModerationReport report) {
    final admin = context.read<AdminProvider>();
    final notesController = TextEditingController(text: 'Reviewed violation in context: ${report.reason}');
    String selectedAction = 'soft_delete_message';
    int muteDurationMinutes = 1440; // Default 24h

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0C0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => FutureBuilder<ModerationContext?>(
        future: admin.fetchReportContext(report.id, contextCount: 3),
        builder: (context, snapshot) {
          final modContext = snapshot.data;
          final isChatEntity = report.entityType.toLowerCase() == 'message' ||
              report.entityType.toLowerCase() == 'chat';

          return StatefulBuilder(
            builder: (context, setModalState) => Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shield_outlined, color: AppColors.error, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contextual Moderation Studio',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
                              ),
                              Text(
                                'Evidence Review & Graduated Sanction Protocol',
                                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF27272A), height: 24),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ticket Summary Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141418),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(color: const Color(0xFF27272A)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'REPORTED FOR: ${report.reason.toUpperCase()}',
                                        style: const TextStyle(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Target ID: ${report.entityId}',
                                      style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reported User: ${report.reportedUserName ?? report.reportedUserId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Live Thread Context Preview
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (modContext != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.history_edu_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                const Text(
                                  'Surrounding Thread Context',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                                const Spacer(),
                                Text(
                                  '${modContext.previousMessages.length} preceding msgs',
                                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1015),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                border: Border.all(color: const Color(0xFF1E2028)),
                              ),
                              child: Column(
                                children: [
                                  // Preceding Messages
                                  for (final m in modContext.previousMessages) _buildMessageRow(m, isTarget: false),
                                  // Target Reported Message
                                  _buildMessageRow(modContext.targetMessage, isTarget: true),
                                  // Subsequent Messages
                                  for (final m in modContext.nextMessages) _buildMessageRow(m, isTarget: false),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Graduated Moderation Sanction Selection
                          const Text(
                            'Graduated Enforcement Action',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSanctionChip(
                                label: 'Dismiss Ticket',
                                isSelected: selectedAction == 'dismiss',
                                color: const Color(0xFF64748B),
                                icon: Icons.check_circle_outline_rounded,
                                onSelected: () => setModalState(() => selectedAction = 'dismiss'),
                              ),
                              _buildSanctionChip(
                                label: 'Warn User',
                                isSelected: selectedAction == 'warn',
                                color: AppColors.warning,
                                icon: Icons.warning_amber_rounded,
                                onSelected: () => setModalState(() => selectedAction = 'warn'),
                              ),
                              if (isChatEntity)
                                _buildSanctionChip(
                                  label: 'Soft-Delete Message',
                                  isSelected: selectedAction == 'soft_delete_message',
                                  color: AppColors.primary,
                                  icon: Icons.delete_sweep_outlined,
                                  onSelected: () => setModalState(() => selectedAction = 'soft_delete_message'),
                                ),
                              _buildSanctionChip(
                                label: 'Mute User',
                                isSelected: selectedAction == 'mute',
                                color: const Color(0xFFF97316),
                                icon: Icons.volume_off_rounded,
                                onSelected: () => setModalState(() => selectedAction = 'mute'),
                              ),
                              _buildSanctionChip(
                                label: 'Ban User',
                                isSelected: selectedAction == 'ban',
                                color: AppColors.error,
                                icon: Icons.block_rounded,
                                onSelected: () => setModalState(() => selectedAction = 'ban'),
                              ),
                              if (isChatEntity && modContext?.targetMessage != null)
                                _buildSanctionChip(
                                  label: 'Safe-Lock Room',
                                  isSelected: selectedAction == 'lock_room',
                                  color: const Color(0xFFEC4899),
                                  icon: Icons.lock_outline_rounded,
                                  onSelected: () => setModalState(() => selectedAction = 'lock_room'),
                                ),
                            ],
                          ),

                          // Mute Duration Selector if Mute is selected
                          if (selectedAction == 'mute') ...[
                            const SizedBox(height: 14),
                            const Text(
                              'Mute Duration',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('1 Hour'),
                                  selected: muteDurationMinutes == 60,
                                  selectedColor: AppColors.warning.withValues(alpha: 0.3),
                                  onSelected: (_) => setModalState(() => muteDurationMinutes = 60),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('24 Hours'),
                                  selected: muteDurationMinutes == 1440,
                                  selectedColor: AppColors.warning.withValues(alpha: 0.3),
                                  onSelected: (_) => setModalState(() => muteDurationMinutes = 1440),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('7 Days'),
                                  selected: muteDurationMinutes == 10080,
                                  selectedColor: AppColors.warning.withValues(alpha: 0.3),
                                  onSelected: (_) => setModalState(() => muteDurationMinutes = 10080),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16),
                          TextField(
                            controller: notesController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Audit Reasoning & Justification',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'Explain why this action was taken for transparent audit logging...',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                              filled: true,
                              fillColor: const Color(0xFF141418),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: const BorderSide(color: Color(0xFF27272A)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: const BorderSide(color: Color(0xFF27272A)),
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.gavel_rounded, color: Colors.black),
                      label: const Text(
                        'Apply Graduated Sanction & Log Audit',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final reason = notesController.text.trim();
                        bool success = false;

                        if (selectedAction == 'dismiss') {
                          success = await admin.resolveModerationReport(report.id, 'dismissed', reason);
                        } else if (selectedAction == 'warn') {
                          await admin.moderateUser(
                            userId: report.reportedUserId,
                            action: 'warn',
                            reason: reason,
                          );
                          success = await admin.resolveModerationReport(report.id, 'warned', reason);
                        } else if (selectedAction == 'soft_delete_message') {
                          await admin.moderateChatMessage(
                            messageId: report.entityId,
                            action: 'soft_delete',
                            reason: reason,
                          );
                          success = await admin.resolveModerationReport(report.id, 'deleted_content', reason);
                        } else if (selectedAction == 'mute') {
                          await admin.moderateUser(
                            userId: report.reportedUserId,
                            action: 'mute',
                            durationMinutes: muteDurationMinutes,
                            reason: reason,
                            roomId: modContext?.targetMessage.roomId,
                          );
                          success = await admin.resolveModerationReport(report.id, 'muted_user', reason);
                        } else if (selectedAction == 'ban') {
                          await admin.moderateUser(
                            userId: report.reportedUserId,
                            action: 'ban',
                            reason: reason,
                          );
                          success = await admin.resolveModerationReport(report.id, 'banned_user', reason);
                        } else if (selectedAction == 'lock_room') {
                          if (modContext != null) {
                            await admin.toggleRoomLock(
                              modContext.targetMessage.roomId,
                              true,
                              reason: reason,
                            );
                          }
                          success = await admin.resolveModerationReport(report.id, 'locked_room', reason);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? 'Moderation action executed and logged.' : 'Failed to complete moderation.',
                              ),
                              backgroundColor: success ? AppColors.success : AppColors.error,
                            ),
                          );
                          admin.loadModerationReports();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSanctionChip({
    required String label,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.black : color),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white)),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: const Color(0xFF18181B),
      side: BorderSide(color: isSelected ? color : const Color(0xFF27272A)),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildMessageRow(ChatMessage message, {required bool isTarget}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isTarget ? AppColors.error.withValues(alpha: 0.15) : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget ? AppColors.error.withValues(alpha: 0.6) : const Color(0xFF27272A),
          width: isTarget ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isTarget ? AppColors.error.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              message.senderName?.isNotEmpty ?? false ? message.senderName![0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isTarget ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.senderName ?? message.senderId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                    ),
                    if (isTarget) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'REPORTED TARGET',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message.isDeleted ? '[Content moderated: ${message.deletionReason ?? 'Removed'}]' : message.content,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                    color: message.isDeleted
                        ? Colors.white.withValues(alpha: 0.5)
                        : (isTarget ? Colors.white : Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${reports.length} moderation tickets requiring contextual administrative review',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isUrgent
                                      ? AppColors.error.withValues(alpha: 0.5)
                                      : const Color(0xFF27272A),
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
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          color: isPending ? AppColors.warning : AppColors.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.reason,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reported User: ${item.reportedUserName ?? item.reportedUserId}',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                  ),
                                  if (isPending) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.icon(
                                        icon: const Icon(Icons.shield_outlined, size: 16, color: Colors.black),
                                        label: const Text(
                                          'Inspect Context & Sanction',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                        onPressed: () => _openContextualReviewStudio(context, item),
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
