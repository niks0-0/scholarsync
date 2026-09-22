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
  int _activeTab = 0; // 0 = All Students, 1 = Verification Queue

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

  void _openIdCardPreviewDialog(BuildContext context, UserProfile student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0xFF27272A)),
        ),
        title: Row(
          children: [
            const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Student ID: ${student.fullName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0B0E),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Center(
                child: student.collegeIdCardUrl != null && student.collegeIdCardUrl!.isNotEmpty
                    ? Image.network(
                        student.collegeIdCardUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_rounded, size: 48, color: AppColors.primary),
                            SizedBox(height: 6),
                            Text('Institutional Student Card Attached', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card_rounded, size: 48, color: AppColors.primary),
                          SizedBox(height: 6),
                          Text('Student ID Card Uploaded', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('Attached during student onboarding', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Roll Number: ${student.rollNumber ?? 'Not specified'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Branch: ${student.branch ?? 'Not specified'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Semester: Semester ${student.semester ?? 1}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Division: ${student.division ?? 'A'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Email: ${student.email}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().updateStudentVerificationStatus(student.id, 'rejected');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Verification rejected for ${student.fullName}'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Reject'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().updateStudentVerificationStatus(student.id, 'verified');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student verified & approved: ${student.fullName}'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Approve & Verify', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
    final allStudents = admin.students;
    final pendingStudents = allStudents.where((s) => s.verificationStatus == 'pending_verification').toList();
    final displayedStudents = _activeTab == 1 ? pendingStudents : allStudents;

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
                        '${allStudents.length} registered students • ${pendingStudents.length} pending review',
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
            const SizedBox(height: 12),

            // ── Segmented Tab Switcher (Directory vs Verification Queue) ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF141418),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 0),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? const Color(0xFF27272A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Center(
                          child: Text(
                            'All Students (${allStudents.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTab == 0 ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? const Color(0xFF27272A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verification Queue',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.w500,
                                color: _activeTab == 1 ? Colors.white : Colors.white60,
                              ),
                            ),
                            if (pendingStudents.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${pendingStudents.length}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
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
                  : displayedStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _activeTab == 1 ? Icons.verified_user_outlined : Icons.people_outline_rounded,
                                size: 56,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _activeTab == 1 ? 'Verification Queue is Clear!' : 'No Students Registered',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _activeTab == 1
                                    ? 'All submitted student IDs have been reviewed and resolved.'
                                    : 'Tap "+ Add Student" below to provision student accounts.',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayedStudents.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = displayedStudents[index];
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
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: student.verificationStatus == 'verified'
                                                    ? AppColors.success.withValues(alpha: 0.15)
                                                    : (student.verificationStatus == 'rejected'
                                                        ? AppColors.error.withValues(alpha: 0.15)
                                                        : const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: student.verificationStatus == 'verified'
                                                      ? AppColors.success.withValues(alpha: 0.4)
                                                      : (student.verificationStatus == 'rejected'
                                                          ? AppColors.error.withValues(alpha: 0.4)
                                                          : const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                                                ),
                                              ),
                                              child: Text(
                                                student.verificationStatus == 'verified'
                                                    ? 'VERIFIED'
                                                    : (student.verificationStatus == 'rejected'
                                                        ? 'REJECTED'
                                                        : 'PENDING ID'),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: student.verificationStatus == 'verified'
                                                      ? AppColors.success
                                                      : (student.verificationStatus == 'rejected'
                                                          ? AppColors.error
                                                          : const Color(0xFFF59E0B)),
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
                                        if (student.verificationStatus == 'pending_verification' || student.collegeIdCardUrl != null) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  minimumSize: const Size(0, 28),
                                                  textStyle: const TextStyle(fontSize: 11),
                                                ),
                                                icon: const Icon(Icons.badge_outlined, size: 14),
                                                label: const Text('View ID Card'),
                                                onPressed: () => _openIdCardPreviewDialog(context, student),
                                              ),
                                              const Spacer(),
                                              if (student.verificationStatus != 'verified') ...[
                                                IconButton(
                                                  tooltip: 'Reject Verification',
                                                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                                                  onPressed: () => admin.updateStudentVerificationStatus(student.id, 'rejected'),
                                                ),
                                                FilledButton.icon(
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: AppColors.success,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    minimumSize: const Size(0, 28),
                                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                  icon: const Icon(Icons.check_rounded, size: 14),
                                                  label: const Text('Approve'),
                                                  onPressed: () => admin.updateStudentVerificationStatus(student.id, 'verified'),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
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
