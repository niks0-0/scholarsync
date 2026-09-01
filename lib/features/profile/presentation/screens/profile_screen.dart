import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../../onboarding/presentation/onboarding_provider.dart';
import '../../data/repositories/supabase_college_repository.dart';
import '../../domain/models/college.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/college_repository.dart';
import '../profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollegeRepository _collegeRepository = const SupabaseCollegeRepository();

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _enrollmentController;

  College? _selectedCollege;
  List<College> _colleges = [];
  bool _isLoadingColleges = false;

  late String _branch;
  late int _semester;
  late String _division;
  late String _academicYear;

  Uint8List? _newAvatarBytes;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _rollController = TextEditingController(text: profile?.rollNumber ?? '');
    _enrollmentController = TextEditingController(text: profile?.enrollmentNumber ?? '');

    _branch = profile?.branch ?? OnboardingProvider.availableBranches.first;
    _semester = profile?.semester ?? 1;
    _division = profile?.division ?? 'A';
    _academicYear = profile?.academicYear ?? OnboardingProvider.availableAcademicYears.first;

    _loadColleges(profile?.collegeId);
  }

  Future<void> _loadColleges(String? currentCollegeId) async {
    setState(() => _isLoadingColleges = true);
    try {
      final list = await _collegeRepository.getColleges();
      setState(() {
        _colleges = list;
        if (currentCollegeId != null && list.isNotEmpty) {
          _selectedCollege = list.firstWhere(
            (c) => c.id == currentCollegeId,
            orElse: () => list.first,
          );
        }
      });
    } catch (e) {
      debugPrint('Failed to load colleges for profile edit: $e');
    } finally {
      setState(() => _isLoadingColleges = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() => _newAvatarBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick avatar image: $e')),
      );
    }
  }

  Future<void> _toggleAdminRole() async {
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final newRole = current.role.isAdmin ? UserRole.student : UserRole.admin;
    final updated = current.copyWith(role: newRole);

    final saved = await profileProvider.updateProfile(updated);
    if (mounted && saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role switched to ${newRole.displayName}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    final currentProfile = profileProvider.profile;
    if (currentProfile == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // 1. Upload avatar if selected
      String? updatedAvatarUrl = currentProfile.avatarUrl;
      if (_newAvatarBytes != null) {
        final path = await profileProvider.uploadAvatar(
          firebaseUid: currentProfile.id,
          bytes: _newAvatarBytes!,
        );
        if (path != null) updatedAvatarUrl = path;
      }

      // 2. Build updated profile
      final updated = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        collegeId: _selectedCollege?.id,
        branch: _branch,
        semester: _semester,
        division: _division,
        academicYear: _academicYear,
        rollNumber: _rollController.text.trim().isNotEmpty ? _rollController.text.trim() : null,
        enrollmentNumber:
            _enrollmentController.text.trim().isNotEmpty ? _enrollmentController.text.trim() : null,
        avatarUrl: updatedAvatarUrl,
      );

      // 3. Update profile via ProfileRepository
      final saved = await profileProvider.updateProfile(updated);

      if (mounted && saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic Identity Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to update profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final avatarUrl = profile?.avatarUrl ?? auth.currentUser?.photoUrl;
    final email = profile?.email ?? auth.currentUser?.email ?? 'N/A';
    final uid = profile?.id ?? auth.currentUser?.uid ?? 'N/A';
    final provider = profile?.authProvider ?? 'google.com';
    final isAdmin = profile?.role.isAdmin ?? false;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Academic Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (context.mounted) context.go('/welcome');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Admin Portal Access Banner ──────────────────────────────
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.secondary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              ),
                              child: const Icon(Icons.shield_rounded,
                                  size: 24, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ScholarSync Owner Mode Active',
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'You have master control over all student accounts, colleges, and broadcasts.',
                                    style: textTheme.bodySmall
                                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textPrimary,
                            ),
                            icon: const Icon(Icons.launch_rounded, size: 18),
                            label: const Text('Open Master Console',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => context.go('/admin'),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Avatar Header
                Center(
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Change avatar picture',
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              backgroundImage: _newAvatarBytes != null
                                  ? MemoryImage(_newAvatarBytes!)
                                  : (avatarUrl != null && avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null) as ImageProvider?,
                              child: _newAvatarBytes == null &&
                                      (avatarUrl == null || avatarUrl.isEmpty)
                                  ? Icon(Icons.person_rounded, size: 46, color: AppColors.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAvatar,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      TextButton.icon(
                        onPressed: _pickAvatar,
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('Change Photo'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // ── Read-Only Identity Card ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Authentication Identity (Read-Only)',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          InkWell(
                            onTap: _toggleAdminRole,
                            child: Chip(
                              label: Text(
                                profile?.role.displayName ?? 'Student',
                                style: textTheme.labelSmall
                                    ?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: isAdmin
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email,
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Provider: $provider • UID: ${uid.substring(0, uid.length > 8 ? 8 : uid.length)}...',
                              style:
                                  textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXxl),

                // ── Editable Academic Identity Fields ────────────────────────
                Text(
                  'Academic Profile Information',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Full Name is required' : null,
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // College Selection
                Text('College / University', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                _isLoadingColleges
                    ? const LinearProgressIndicator()
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<College>(
                            value: _selectedCollege,
                            isExpanded: true,
                            dropdownColor: colorScheme.surfaceContainerHighest,
                            hint: const Text('Select College'),
                            items: _colleges.map((c) {
                              return DropdownMenuItem<College>(
                                value: c,
                                child: Text(c.name,
                                    style: textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCollege = val);
                            },
                          ),
                        ),
                      ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Branch Selection
                Text('Branch / Program', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _branch,
                      isExpanded: true,
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: OnboardingProvider.availableBranches.map((b) {
                        return DropdownMenuItem<String>(
                          value: b,
                          child: Text(b, style: textTheme.bodyLarge),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _branch = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Academic Year Selection
                Text('Academic Year', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  runSpacing: AppDimensions.spacingSm,
                  children: OnboardingProvider.availableAcademicYears.map((yr) {
                    final isSelected = _academicYear == yr;
                    return ChoiceChip(
                      label: Text(yr),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _academicYear = yr),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Semester Selection
                Text('Semester', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  runSpacing: AppDimensions.spacingSm,
                  children: OnboardingProvider.availableSemesters.map((sem) {
                    final isSelected = _semester == sem;
                    return ChoiceChip(
                      label: Text('Sem $sem'),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _semester = sem),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Division Selection
                Text('Division / Section', style: textTheme.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  runSpacing: AppDimensions.spacingSm,
                  children: OnboardingProvider.availableDivisions
                      .where((d) => d != 'Custom')
                      .map((div) {
                    final isSelected = _division == div;
                    return ChoiceChip(
                      label: Text('Division $div'),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _division = div),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Optional Roll & Enrollment Numbers
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Roll Number',
                        controller: _rollController,
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: AppTextField(
                        label: 'Enrollment ID',
                        controller: _enrollmentController,
                        prefixIcon: Icons.fingerprint_rounded,
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ],

                const SizedBox(height: AppDimensions.spacingXxxl),

                PrimaryButton(
                  label: 'Save Academic Profile',
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
