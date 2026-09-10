import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/domain/models/user_role.dart';
import '../admin_provider.dart';

/// Complete Student Management & Role Delegation screen for ScholarSync Master Admin.
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRoleDialog(BuildContext context, UserProfile student) {
    UserRole selectedRole = student.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Manage Role: ${student.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign access permissions across the ScholarSync ecosystem for this account.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Assigned Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (newRole) {
                  if (newRole != null) {
                    setDialogState(() => selectedRole = newRole);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await context
                    .read<AdminProvider>()
                    .updateUserRole(student.id, selectedRole);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Role updated to ${selectedRole.displayName}'
                          : 'Failed to update role'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Save Role',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final rollController = TextEditingController();
    final enrollController = TextEditingController();
    final admin = context.read<AdminProvider>();
    String selectedBranch = 'Computer Science & Engineering';
    int selectedSemester = 1;
    String? selectedCollegeId = admin.colleges.isNotEmpty ? admin.colleges.first.id : null;
    UserRole selectedRole = UserRole.student;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Provision Student Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Rohan Sharma',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'College Email *',
                    hintText: 'rohan.sharma@college.edu',
                  ),
                ),
                const SizedBox(height: 12),
                if (admin.colleges.isNotEmpty) ...[
                  const Text('College / Institution *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCollegeId,
                    isExpanded: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: admin.colleges
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedCollegeId = val),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedBranch,
                        decoration: const InputDecoration(labelText: 'Branch', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'Computer Science & Engineering', child: Text('CSE / MCA', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Information Technology', child: Text('IT', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Electronics & Communication', child: Text('ECE', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Mechanical Engineering', child: Text('MECH', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setModalState(() => selectedBranch = v ?? selectedBranch),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedSemester,
                        decoration: const InputDecoration(labelText: 'Semester', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                        items: List.generate(8, (i) => i + 1)
                            .map((s) => DropdownMenuItem(value: s, child: Text('Sem $s')))
                            .toList(),
                        onChanged: (v) => setModalState(() => selectedSemester = v ?? 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rollController,
                        decoration: const InputDecoration(labelText: 'Roll No', hintText: '26'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: enrollController,
                        decoration: const InputDecoration(labelText: 'Enrollment ID', hintText: 'MCA2601'),
                      ),
                    ),
                  ],
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
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Save Profile'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and email are required.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final generatedUid = 'usr_${DateTime.now().millisecondsSinceEpoch}';
                final success = await admin.createStudentProfile(
                  UserProfile(
                    id: generatedUid,
                    email: email,
                    fullName: name,
                    role: selectedRole,
                    collegeId: selectedCollegeId,
                    branch: selectedBranch,
                    semester: selectedSemester,
                    rollNumber: rollController.text.trim().isNotEmpty ? rollController.text.trim() : null,
                    enrollmentNumber: enrollController.text.trim().isNotEmpty ? enrollController.text.trim() : null,
                    onboardingCompleted: true,
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Student profile saved to database!' : 'Failed to save student profile.'),
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
    final students = admin.students;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openCreateStudentDialog(context),
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
                        'Student Directory & User Management',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${students.length} registered students in institution',
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
                  tooltip: 'Refresh Students',
                  onPressed: () => admin.loadStudents(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, roll number, or enrollment ID...',
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
              ),
              onChanged: (val) => admin.setSearchQuery(val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline_rounded, size: 56, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'No Students Registered',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ Add Student" below to provision student accounts.',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final isAdmin = student.role.isAdmin;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: student.isSuspended
                                      ? AppColors.error.withValues(alpha: 0.5)
                                      : isAdmin
                                          ? AppColors.primary.withValues(alpha: 0.35)
                                          : const Color(0xFF27272A),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: isAdmin
                                        ? AppColors.primary.withValues(alpha: 0.2)
                                        : const Color(0xFF1E2430),
                                    child: Text(
                                      student.fullName.isNotEmpty
                                          ? student.fullName[0].toUpperCase()
                                          : 'S',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin ? AppColors.primary : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                student.fullName,
                                                style: textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: (isAdmin
                                                        ? AppColors.primary
                                                        : const Color(0xFF38BDF8))
                                                    .withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: (isAdmin
                                                          ? AppColors.primary
                                                          : const Color(0xFF38BDF8))
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                student.role.displayName.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: isAdmin
                                                      ? AppColors.primary
                                                      : const Color(0xFF38BDF8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          student.email,
                                          style: textTheme.bodySmall
                                              ?.copyWith(color: const Color(0xFF94A3B8)),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            if (student.branch != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  student.branch!,
                                                  style: const TextStyle(
                                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                                ),
                                              ),
                                            if (student.semester != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Sem ${student.semester}',
                                                  style: const TextStyle(
                                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                                ),
                                              ),
                                            if (student.rollNumber != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Roll: ${student.rollNumber}',
                                                  style: const TextStyle(
                                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                                ),
                                              ),
                                            if (student.enrollmentNumber != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'ID: ${student.enrollmentNumber}',
                                                  style: const TextStyle(
                                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                                    onSelected: (val) async {
                                      if (val == 'role') {
                                        _openRoleDialog(context, student);
                                      } else if (val == 'suspend') {
                                        await admin.toggleUserSuspension(student.id, !student.isSuspended);
                                      } else if (val == 'delete') {
                                        final success = await admin.deleteStudentProfile(student.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(success ? 'Student record removed.' : 'Failed to delete record.'),
                                              backgroundColor: success ? AppColors.success : AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'role',
                                        child: Row(
                                          children: [
                                            Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 18),
                                            SizedBox(width: 8),
                                            Text('Change Role'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'suspend',
                                        child: Row(
                                          children: [
                                            Icon(
                                              student.isSuspended ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                              color: AppColors.warning,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(student.isSuspended ? 'Reactivate Account' : 'Suspend Account'),
                                          ],
                                        ),
                                      ),
                                      if (!isAdmin) ...[
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                              SizedBox(width: 8),
                                              Text('Delete Record', style: TextStyle(color: AppColors.error)),
                                            ],
                                          ),
                                        ),
                                      ],
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
