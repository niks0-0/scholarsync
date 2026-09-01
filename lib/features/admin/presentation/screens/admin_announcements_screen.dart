import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarsync/features/admin/domain/models/announcement.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../admin_provider.dart';

/// Screen allowing administrators to publish campus announcements and broadcast alerts.
class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  void _openCreateAnnouncementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateAnnouncementSheet(),
    );
  }

  void _confirmDeleteAnnouncement(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement?'),
        content: Text('Are you sure you want to delete "${announcement.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<AdminProvider>().deleteAnnouncement(announcement.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Announcement deleted' : 'Failed to delete announcement'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
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
    final announcements = admin.announcements;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateAnnouncementSheet(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Broadcast Alert', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Announcements & Campus Alerts',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${announcements.length} broadcasts published to students',
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
                  tooltip: 'Refresh Announcements',
                  onPressed: () => admin.loadAnnouncements(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : announcements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.campaign_outlined,
                                  size: 48, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'No announcements published yet.',
                                style: textTheme.bodyLarge
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: () => _openCreateAnnouncementSheet(context),
                                child: const Text('Broadcast First Announcement'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: announcements.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ann = announcements[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: ann.isUrgent
                                      ? AppColors.error.withValues(alpha: 0.5)
                                      : const Color(0xFF27272A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (ann.isUrgent) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  size: 13, color: AppColors.error),
                                              SizedBox(width: 4),
                                              Text(
                                                'URGENT ALERT',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          ann.title,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded,
                                            size: 18, color: AppColors.error),
                                        tooltip: 'Delete Announcement',
                                        onPressed: () =>
                                            _confirmDeleteAnnouncement(context, ann),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ann.content,
                                    style: textTheme.bodyMedium
                                        ?.copyWith(color: const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline_rounded,
                                          size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        ann.createdBy,
                                        style: textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      if (ann.targetBranch != null &&
                                          ann.targetBranch!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            ann.targetBranch!,
                                            style: const TextStyle(
                                                color: Color(0xFF94A3B8), fontSize: 10),
                                          ),
                                        ),
                                    ],
                                  ),
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

class _CreateAnnouncementSheet extends StatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  State<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isUrgent = false;
  String? _targetBranch;

  final List<String> _branchOptions = const [
    'All Branches (Entire College)',
    'Computer Science & Engineering',
    'Information Technology',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Electronics & Telecommunication',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>().profile;
    final announcement = Announcement(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdBy: profile?.fullName ?? 'Administrator',
      targetBranch: (_targetBranch == null || _targetBranch == 'All Branches (Entire College)')
          ? null
          : _targetBranch,
      isUrgent: _isUrgent,
    );

    final provider = context.read<AdminProvider>();
    final success = await provider.publishAnnouncement(announcement);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Announcement broadcasted!' : 'Failed to publish announcement'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Broadcast Announcement',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Announcement Title *',
                  hintText: 'e.g. Campus Holiday Notice / Mid-Term Exams',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Announcement Body / Details *',
                  hintText: 'Write the complete announcement details for students...',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _targetBranch ?? _branchOptions.first,
                decoration: const InputDecoration(labelText: 'Target Audience'),
                items: _branchOptions
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) => setState(() => _targetBranch = val),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                title: const Text('Mark as High Priority / Urgent Alert'),
                subtitle: const Text('Highlights the notice in red on student dashboards'),
                value: _isUrgent,
                activeThumbColor: AppColors.error,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isUrgent = val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Publish Announcement',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: _handlePublish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
