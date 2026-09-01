import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../../dashboard/presentation/widgets/dashboard_skeleton_loader.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../academic_catalog_provider.dart';
import '../../domain/models/subject.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_detail_modal.dart';

class AcademicCatalogScreen extends StatefulWidget {
  const AcademicCatalogScreen({super.key});

  @override
  State<AcademicCatalogScreen> createState() => _AcademicCatalogScreenState();
}

class _AcademicCatalogScreenState extends State<AcademicCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      context.read<AcademicCatalogProvider>().loadCatalogForUser(profile);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSubjectDetail(BuildContext context, Subject subject, bool isEnrolled, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubjectDetailModal(
        subject: subject,
        isEnrolled: isEnrolled,
        onToggleEnrollment: () {
          context.read<AcademicCatalogProvider>().toggleSubjectEnrollment(uid, subject);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final catalog = context.watch<AcademicCatalogProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid ?? profile?.id ?? '';

    final branch = profile?.branch ?? 'Computer Science & Engineering';
    final semester = profile?.semester ?? 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'Academic Subject Catalog',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$branch • Semester $semester Curriculum',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // Search Bar
              AppTextField(
                label: 'Search Catalog',
                hint: 'Search by subject name, code, or short name...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (q) => catalog.filterSubjects(q),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Semester Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Current Sem'),
                      selected: catalog.semesterFilter == null,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: catalog.semesterFilter == null ? Colors.white : colorScheme.onSurface,
                      ),
                      onSelected: (_) => catalog.filterSubjects(_searchController.text, semester: null),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(8, (i) {
                      final sem = i + 1;
                      final isSelected = catalog.semesterFilter == sem;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Sem $sem'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colorScheme.onSurface,
                          ),
                          onSelected: (_) => catalog.filterSubjects(_searchController.text, semester: sem),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // Subjects List
              Expanded(
                child: catalog.isLoading
                    ? ListView.separated(
                        itemCount: 4,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => const DashboardSkeletonLoader(height: 120),
                      )
                    : catalog.error != null
                        ? Center(
                            child: Text(
                              catalog.error!,
                              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                            ),
                          )
                        : catalog.subjects.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.library_books_outlined, size: 44, color: colorScheme.onSurfaceVariant),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No curriculum subjects found matching filter.',
                                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: catalog.subjects.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = catalog.subjects[index];
                                  final isEnrolled = catalog.isEnrolled(item.id);
                                  return SubjectCard(
                                    subject: item,
                                    isEnrolled: isEnrolled,
                                    onTap: () => _showSubjectDetail(context, item, isEnrolled, uid),
                                    onToggleEnrollment: () {
                                      catalog.toggleSubjectEnrollment(uid, item);
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
