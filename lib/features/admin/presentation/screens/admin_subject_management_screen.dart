import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/domain/models/subject.dart';
import '../admin_provider.dart';

/// Screen allowing administrators and faculty to manage the academic curriculum & syllabus subjects.
class AdminSubjectManagementScreen extends StatefulWidget {
  const AdminSubjectManagementScreen({super.key});

  @override
  State<AdminSubjectManagementScreen> createState() => _AdminSubjectManagementScreenState();
}

class _AdminSubjectManagementScreenState extends State<AdminSubjectManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _branches = const [
    'All Branches',
    'Computer Science & Engineering',
    'Information Technology',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Electronics & Telecommunication',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditSubjectModal({Subject? subjectToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddEditSubjectDialog(subjectToEdit: subjectToEdit),
    );
  }

  void _confirmDeleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
          'Are you sure you want to permanently delete "${subject.subjectName} (${subject.subjectCode})"?\n\nThis will remove it from student catalogs and schedules.',
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
              final success = await context.read<AdminProvider>().deleteSubject(subject.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Subject deleted successfully'
                        : 'Failed to delete subject'),
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

    final subjects = admin.subjects;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSubjectModal(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Curriculum & Subject Catalog',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${subjects.length} subjects registered in curriculum',
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
                  tooltip: 'Refresh Subjects',
                  onPressed: () => admin.loadSubjects(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title, code (e.g. CS401), or short name...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                admin.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    onChanged: (val) => admin.setSearchQuery(val),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: DropdownButton<int?>(
                      value: admin.selectedSemesterFilter,
                      hint: const Text('All Semesters'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Semesters'),
                        ),
                        ...List.generate(8, (i) => i + 1).map(
                          (sem) => DropdownMenuItem<int?>(
                            value: sem,
                            child: Text('Semester $sem'),
                          ),
                        ),
                      ],
                      onChanged: (sem) => admin.setSemesterFilter(sem),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Branch horizontal filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _branches.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final branch = _branches[index];
                  final isAll = branch == 'All Branches';
                  final isSelected = isAll
                      ? admin.selectedBranchFilter == null
                      : admin.selectedBranchFilter == branch;

                  return FilterChip(
                    label: Text(branch),
                    selected: isSelected,
                    onSelected: (selected) {
                      admin.setBranchFilter(isAll || !selected ? null : branch);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Subject List / Empty state
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 48, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'No subjects found matching the filters.',
                                style: textTheme.bodyLarge
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: () => _openAddEditSubjectModal(),
                                child: const Text('Add Your First Subject'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: subjects.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            return _AdminSubjectCard(
                              subject: subject,
                              onEdit: () => _openAddEditSubjectModal(subjectToEdit: subject),
                              onDelete: () => _confirmDeleteSubject(subject),
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

class _AdminSubjectCard extends StatelessWidget {
  const _AdminSubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF27272A), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              subject.subjectCode,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subjectName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.branch} • Semester ${subject.semester}',
                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${subject.credits} Credits',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    if (subject.theory)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'THEORY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    if (subject.practical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRACTICAL / LAB',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ),
                    if (subject.facultyName != null && subject.facultyName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Prof. ${subject.facultyName}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit Subject',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                tooltip: 'Delete Subject',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddEditSubjectDialog extends StatefulWidget {
  const _AddEditSubjectDialog({this.subjectToEdit});

  final Subject? subjectToEdit;

  @override
  State<_AddEditSubjectDialog> createState() => _AddEditSubjectDialogState();
}

class _AddEditSubjectDialogState extends State<_AddEditSubjectDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _facultyController;
  late TextEditingController _creditsController;

  String _selectedBranch = 'Computer Science & Engineering';
  int _selectedSemester = 4;
  bool _isTheory = true;
  bool _isPractical = false;

  final List<String> _branchOptions = const [
    'Computer Science & Engineering',
    'Information Technology',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Electronics & Telecommunication',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.subjectToEdit;
    _codeController = TextEditingController(text: s?.subjectCode ?? '');
    _nameController = TextEditingController(text: s?.subjectName ?? '');
    _shortNameController = TextEditingController(text: s?.shortName ?? '');
    _facultyController = TextEditingController(text: s?.facultyName ?? '');
    _creditsController = TextEditingController(text: '${s?.credits ?? 3}');

    if (s != null) {
      _selectedBranch = s.branch;
      _selectedSemester = s.semester;
      _isTheory = s.theory;
      _isPractical = s.practical;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _facultyController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.subjectToEdit != null;
    final subject = Subject(
      id: widget.subjectToEdit?.id ?? '',
      branch: _selectedBranch,
      semester: _selectedSemester,
      subjectCode: _codeController.text.trim().toUpperCase(),
      subjectName: _nameController.text.trim(),
      shortName: _shortNameController.text.trim().toUpperCase(),
      facultyName: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
      credits: int.tryParse(_creditsController.text.trim()) ?? 3,
      theory: _isTheory,
      practical: _isPractical,
    );

    final provider = context.read<AdminProvider>();
    final success = isEdit
        ? await provider.updateSubject(subject)
        : await provider.createSubject(subject);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (isEdit ? 'Subject updated successfully' : 'Subject created successfully')
              : (provider.errorMessage ?? 'Operation failed')),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.subjectToEdit != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Subject' : 'Add New Subject',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Subject Code *',
                          hintText: 'e.g. CS401',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _shortNameController,
                        decoration: const InputDecoration(
                          labelText: 'Short Name *',
                          hintText: 'e.g. DAA',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _creditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          hintText: '3',
                        ),
                        validator: (val) {
                          final num = int.tryParse(val ?? '');
                          if (num == null || num < 1 || num > 10) return '1-10';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Official Subject Title *',
                    hintText: 'e.g. Design & Analysis of Algorithms',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter subject name' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Branch / Department *'),
                  items: _branchOptions
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBranch = val);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedSemester,
                        decoration: const InputDecoration(labelText: 'Semester *'),
                        items: List.generate(8, (i) => i + 1)
                            .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSemester = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _facultyController,
                        decoration: const InputDecoration(
                          labelText: 'Faculty / Teacher',
                          hintText: 'e.g. Dr. Alan Turing',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Theory Lecture'),
                        value: _isTheory,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _isTheory = val ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Practical Lab'),
                        value: _isPractical,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _isPractical = val ?? false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _handleSubmit,
          child: Text(
            isEdit ? 'Save Changes' : 'Create Subject',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
