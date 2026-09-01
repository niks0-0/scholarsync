import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/models/college.dart';
import '../admin_provider.dart';

/// Screen allowing administrators to manage registered colleges and universities.
class AdminCollegeManagementScreen extends StatelessWidget {
  const AdminCollegeManagementScreen({super.key});

  void _openAddEditCollegeModal(BuildContext context, {College? collegeToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddEditCollegeDialog(collegeToEdit: collegeToEdit),
    );
  }

  void _confirmDeleteCollege(BuildContext context, College college) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete College?'),
        content: Text('Are you sure you want to delete "${college.name} (${college.code})"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().deleteCollege(college.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'College deleted' : 'Failed to delete college'),
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
    final colleges = admin.colleges;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditCollegeModal(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.domain_add_rounded),
        label: const Text('Add College', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        'Colleges & Partner Campuses',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${colleges.length} registered institutions available during onboarding',
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
                  tooltip: 'Refresh Colleges',
                  onPressed: () => admin.loadColleges(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : colleges.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_outlined,
                                  size: 48, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'No colleges registered yet.',
                                style: textTheme.bodyLarge
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: () => _openAddEditCollegeModal(context),
                                child: const Text('Add College'),
                              ),
                            ],
                          ),
                        )
                        : ListView.separated(
                            itemCount: colleges.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final college = colleges[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1218),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                  border: Border.all(color: const Color(0xFF27272A)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                        border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                                      ),
                                      child: const Icon(Icons.account_balance_rounded,
                                          size: 22, color: Color(0xFFFBBF24)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            college.name,
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (college.code.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.06),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'CODE: ${college.code}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF94A3B8),
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      tooltip: 'Edit College',
                                      onPressed: () => _openAddEditCollegeModal(context, collegeToEdit: college),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                      tooltip: 'Delete College',
                                      onPressed: () => _confirmDeleteCollege(context, college),
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

class _AddEditCollegeDialog extends StatefulWidget {
  const _AddEditCollegeDialog({this.collegeToEdit});

  final College? collegeToEdit;

  @override
  State<_AddEditCollegeDialog> createState() => _AddEditCollegeDialogState();
}

class _AddEditCollegeDialogState extends State<_AddEditCollegeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.collegeToEdit?.name ?? '');
    _codeController = TextEditingController(text: widget.collegeToEdit?.code ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.collegeToEdit != null;
    final college = College(
      id: widget.collegeToEdit?.id ?? '',
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
    );

    final provider = context.read<AdminProvider>();
    final success = isEdit
        ? await provider.updateCollege(college)
        : await provider.createCollege(college);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (isEdit ? 'College updated' : 'College created')
              : (provider.errorMessage ?? 'Operation failed')),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.collegeToEdit != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit College' : 'Add College'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'College Name *',
                hintText: 'e.g. MIT World Peace University',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Short Code / Abbreviation *',
                hintText: 'e.g. MIT-WPU',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _handleSubmit,
          child: Text(
            isEdit ? 'Save Changes' : 'Add College',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
