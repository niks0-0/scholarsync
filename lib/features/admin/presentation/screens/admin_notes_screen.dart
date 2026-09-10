import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarsync/core/constants/app_dimensions.dart';
import 'package:scholarsync/core/theme/app_colors.dart';
import 'package:scholarsync/features/admin/domain/models/study_note.dart';
import 'package:scholarsync/features/admin/presentation/admin_provider.dart';
import 'package:scholarsync/features/dashboard/presentation/widgets/dashboard_skeleton_loader.dart';

class AdminNotesScreen extends StatefulWidget {
  const AdminNotesScreen({super.key});

  @override
  State<AdminNotesScreen> createState() => _AdminNotesScreenState();
}

class _AdminNotesScreenState extends State<AdminNotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRejectReasonDialog(BuildContext context, StudyNote note) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Study Note'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for Rejection',
            hintText: 'e.g. Copyright issue, poor quality, wrong subject...',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().moderateNote(
                    note.id,
                    'rejected',
                    reason: reasonController.text.trim(),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Note rejected.' : 'Failed to reject note.'),
                    backgroundColor: success ? AppColors.warning : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  void _openUploadNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController(text: 'https://example.com/notes.pdf');
    final admin = context.read<AdminProvider>();
    String? selectedSubjectId = admin.subjects.isNotEmpty ? admin.subjects.first.id : null;
    String selectedFileType = 'PDF';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Direct Upload Study Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Material Title *',
                    hintText: 'e.g. Unit 1 - Relational Algebra & SQL Notes',
                  ),
                ),
                const SizedBox(height: 12),
                if (admin.subjects.isNotEmpty) ...[
                  const Text('Curriculum Subject *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    isExpanded: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: admin.subjects
                        .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.subjectCode} - ${s.subjectName}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedSubjectId = val),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'File / Document URL *',
                    hintText: 'https://storage.scholarsync.com/notes/...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description / Topics Covered',
                    hintText: 'e.g. Complete chapter formulas, sample problems, and solved PYQs.',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('File Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['PDF', 'PPTX', 'DOCX'].map((t) {
                    final isSel = selectedFileType == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSel,
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedFileType = t),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Upload to Catalog'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final title = titleController.text.trim();
                final fileUrl = urlController.text.trim();
                if (title.isEmpty || fileUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a note title and file URL.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final success = await admin.createStudyNote(
                  StudyNote(
                    id: '',
                    title: title,
                    description: descController.text.trim(),
                    subjectId: selectedSubjectId ?? '',
                    uploaderId: 'SQJRGQZkujOAIfFEetfaqPqtHbL2',
                    uploaderName: 'App Owner Admin',
                    fileUrl: fileUrl,
                    fileType: selectedFileType,
                    fileSizeBytes: 2048576,
                    status: 'approved',
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Study note uploaded to database catalog!' : 'Failed to upload note.'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final admin = context.watch<AdminProvider>();
    final notes = admin.notes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Material', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openUploadNoteDialog(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes & Study Material Queue',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${notes.length} notes in current status view',
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
                  onPressed: () => admin.loadNotes(),
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
                    label: const Text('Pending Approval'),
                    selected: admin.selectedNoteStatusFilter == 'pending',
                    selectedColor: AppColors.warning.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setNoteStatusFilter('pending'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Approved Catalog'),
                    selected: admin.selectedNoteStatusFilter == 'approved',
                    selectedColor: AppColors.success.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setNoteStatusFilter('approved'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Rejected'),
                    selected: admin.selectedNoteStatusFilter == 'rejected',
                    selectedColor: AppColors.error.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setNoteStatusFilter('rejected'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All Notes'),
                    selected: admin.selectedNoteStatusFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => admin.setNoteStatusFilter(null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title or description...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          admin.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => admin.setSearchQuery(val),
            ),
            const SizedBox(height: 16),

            // Notes List
            Expanded(
              child: admin.isLoading
                  ? ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => const DashboardSkeletonLoader(height: 120),
                    )
                  : notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_outlined, size: 56, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'No Notes Found',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ Upload Material" below to directly publish study materials to database.',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: notes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = notes[index];
                            final isPending = item.status == 'pending';
                            final isApproved = item.status == 'approved';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isApproved
                                      ? AppColors.success.withValues(alpha: 0.3)
                                      : isPending
                                          ? AppColors.warning.withValues(alpha: 0.3)
                                          : colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.fileType.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.subjectName ?? 'Curriculum Subject',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isApproved
                                                  ? AppColors.success
                                                  : isPending
                                                      ? AppColors.warning
                                                      : AppColors.error)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isApproved
                                                ? AppColors.success
                                                : isPending
                                                    ? AppColors.warning
                                                    : AppColors.error,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Note',
                                        onPressed: () async {
                                          final success = await admin.deleteStudyNote(item.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success ? 'Note deleted from database.' : 'Failed to delete note.'),
                                                backgroundColor: success ? AppColors.success : AppColors.error,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (item.description != null && item.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description!,
                                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    'Uploader: ${item.uploaderName ?? item.uploaderId}',
                                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                  if (isPending) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                          label: const Text('Reject', style: TextStyle(color: AppColors.error)),
                                          onPressed: () => _showRejectReasonDialog(context, item),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton.icon(
                                          icon: const Icon(Icons.check_rounded, size: 16),
                                          label: const Text('Approve Note'),
                                          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                                          onPressed: () async {
                                            final success = await admin.moderateNote(item.id, 'approved');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(success ? 'Note approved for student catalog.' : 'Failed to approve.'),
                                                  backgroundColor: success ? AppColors.success : AppColors.error,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
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
