import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../../onboarding/presentation/onboarding_provider.dart';
import '../../data/repositories/supabase_college_repository.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../widgets/avatar_selection_sheet.dart';
import '../../domain/models/college.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/college_repository.dart';
import '../../../leaderboard/presentation/leaderboard_provider.dart';
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
  String? _selectedAvatarUrl;
  bool _isSaving = false;
  String? _errorMessage;

  bool _initializedFromProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rollController = TextEditingController();
    _enrollmentController = TextEditingController();

    _branch = OnboardingProvider.availableBranches.first;
    _semester = 1;
    _division = 'A';
    _academicYear = OnboardingProvider.availableAcademicYears.first;

    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _populateFields(profile);
    } else {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.displayNameOrEmail;
        _selectedAvatarUrl = user.photoUrl;
      }
    }

    _loadColleges(profile?.collegeId);
  }

  void _populateFields(UserProfile profile) {
    if (_initializedFromProfile) return;
    _nameController.text = profile.fullName;
    _rollController.text = profile.rollNumber ?? '';
    _enrollmentController.text = profile.enrollmentNumber ?? '';
    _branch = profile.branch ?? OnboardingProvider.availableBranches.first;
    _semester = profile.semester ?? 1;
    _division = profile.division ?? 'A';
    _academicYear = profile.academicYear ?? OnboardingProvider.availableAcademicYears.first;
    _selectedAvatarUrl = profile.avatarUrl;
    _initializedFromProfile = true;
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
        } else if (list.isNotEmpty && _selectedCollege == null) {
          _selectedCollege = list.first;
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
    final authProvider = context.read<AuthProvider>();
    final authUser = authProvider.currentUser;

    final currentProfile = profileProvider.profile ?? (authUser != null
        ? UserProfile(
            id: authUser.uid,
            email: authUser.email ?? '',
            fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : authUser.displayNameOrEmail,
            avatarUrl: authUser.photoUrl,
            onboardingCompleted: true,
          )
        : null);

    if (currentProfile == null) {
      setState(() => _errorMessage = 'User session not found. Please re-login.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // 1. Determine updated avatar URL
      String? updatedAvatarUrl = _selectedAvatarUrl;
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
        collegeId: _selectedCollege?.id ?? currentProfile.collegeId,
        branch: _branch,
        semester: _semester,
        division: _division,
        academicYear: _academicYear,
        rollNumber: _rollController.text.trim().isNotEmpty ? _rollController.text.trim() : null,
        enrollmentNumber:
            _enrollmentController.text.trim().isNotEmpty ? _enrollmentController.text.trim() : null,
        avatarUrl: updatedAvatarUrl,
        onboardingCompleted: true,
      );

      // 3. Update profile via ProfileRepository
      final saved = await profileProvider.updateProfile(updated);

      if (mounted) {
        if (saved != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Academic Identity Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final err = profileProvider.error ?? 'Failed to update profile in database.';
          setState(() => _errorMessage = err);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      final msg = 'Failed to update profile: $e';
      setState(() => _errorMessage = msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

    if (profile != null && !_initializedFromProfile) {
      _populateFields(profile);
    }

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
              final profileProvider = context.read<ProfileProvider>();
              await authProvider.signOut();
              profileProvider.clear();
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

                // Avatar Header & Options Selector
                Center(
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Change avatar picture',
                        child: GestureDetector(
                          onTap: () {
                            AvatarSelectionSheet.show(
                              context: context,
                              currentAvatarUrl: _selectedAvatarUrl,
                              currentBytes: _newAvatarBytes,
                              studentName: _nameController.text.isNotEmpty
                                  ? _nameController.text
                                  : (profile?.fullName ?? 'Student'),
                              onSelectPreset: (preset) {
                                setState(() {
                                  _selectedAvatarUrl = preset;
                                  _newAvatarBytes = null;
                                });
                              },
                              onSelectBytes: (bytes) {
                                setState(() {
                                  _newAvatarBytes = bytes;
                                });
                              },
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: StudentAvatar(
                                  radius: 46,
                                  avatarUrl: _selectedAvatarUrl,
                                  imageBytes: _newAvatarBytes,
                                  name: _nameController.text.isNotEmpty
                                      ? _nameController.text
                                      : (profile?.fullName ?? 'Student'),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        'Profile Avatar',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to change avatar preset or upload custom photo',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      // 3 Quick Presets Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProfileAvatarChip(
                            title: 'Male',
                            avatarUrl: AvatarPresets.male,
                            isSelected: _newAvatarBytes == null &&
                                _selectedAvatarUrl == AvatarPresets.male,
                            onTap: () {
                              setState(() {
                                _selectedAvatarUrl = AvatarPresets.male;
                                _newAvatarBytes = null;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildProfileAvatarChip(
                            title: 'Female',
                            avatarUrl: AvatarPresets.female,
                            isSelected: _newAvatarBytes == null &&
                                _selectedAvatarUrl == AvatarPresets.female,
                            onTap: () {
                              setState(() {
                                _selectedAvatarUrl = AvatarPresets.female;
                                _newAvatarBytes = null;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildProfileAvatarChip(
                            title: 'Blank',
                            avatarUrl: AvatarPresets.blank,
                            name: _nameController.text,
                            isSelected: _newAvatarBytes == null &&
                                (_selectedAvatarUrl == null ||
                                    _selectedAvatarUrl!.isEmpty),
                            onTap: () {
                              setState(() {
                                _selectedAvatarUrl = AvatarPresets.blank;
                                _newAvatarBytes = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // ── Gamification & Leaderboard Badge Showcase ───────────────
                Consumer<LeaderboardProvider>(
                  builder: (context, lb, _) {
                    final myEntry = lb.currentUserEntry;
                    final badges = lb.userBadges;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            const Color(0xFFF59E0B).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scholar Standing & Badges',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => context.push('/leaderboard'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'View Board',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GLOBAL RANK',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '#${myEntry?.rank ?? 4}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TOTAL POINTS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${myEntry?.score ?? 1850}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ACTIVE STREAK',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${myEntry?.streakDays ?? 14}d 🔥',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFF97316),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (badges.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: badges.map((b) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.military_tech_rounded,
                                          size: 14,
                                          color: Color(0xFFF59E0B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          b.title,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

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

  Widget _buildProfileAvatarChip({
    required String title,
    required String avatarUrl,
    String? name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StudentAvatar(
              avatarUrl: avatarUrl,
              name: name,
              radius: 22,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
