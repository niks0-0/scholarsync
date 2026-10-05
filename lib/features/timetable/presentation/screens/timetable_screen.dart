import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/presentation/academic_catalog_provider.dart';
import '../../../auth/auth_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../../dashboard/presentation/widgets/dashboard_skeleton_loader.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../domain/models/timetable_entry.dart';
import '../timetable_provider.dart';
import '../widgets/add_edit_class_sheet.dart';
import '../widgets/class_detail_modal.dart';
import '../widgets/timetable_class_card.dart';

import '../widgets/upload_timetable_sheet.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final TextEditingController _searchController = TextEditingController();

  final weekdays = const [
    MapEntry(1, 'Mon'),
    MapEntry(2, 'Tue'),
    MapEntry(3, 'Wed'),
    MapEntry(4, 'Thu'),
    MapEntry(5, 'Fri'),
    MapEntry(6, 'Sat'),
    MapEntry(7, 'Sun'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final profile = context.read<ProfileProvider>().profile;
      if (user != null) {
        context.read<TimetableProvider>().loadWeeklySchedule(user.uid);
      }
      context.read<AcademicCatalogProvider>().loadCatalogForUser(profile);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddClassSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditClassSheet(
        firebaseUid: uid,
        initialWeekday: context.read<TimetableProvider>().selectedWeekday,
      ),
    );
  }

  void _showUploadTimetableSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UploadTimetableSheet(firebaseUid: uid),
    );
  }

  void _showClassDetailModal(BuildContext context, TimetableEntry entry, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClassDetailModal(
        entry: entry,
        firebaseUid: uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final timetable = context.watch<TimetableProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid ?? '';

    final daySchedule = timetable.selectedDaySchedule;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassSheet(context, uid),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        tooltip: 'Add Class',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Back',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Timetable',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Weekly Academic Class Schedule',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload_outlined),
                    tooltip: 'Upload / Import Timetable',
                    onPressed: () => _showUploadTimetableSheet(context, uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh Schedule',
                    onPressed: () => timetable.loadWeeklySchedule(uid),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // Weekday Selector Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weekdays.map((entry) {
                    final isSelected = timetable.selectedWeekday == entry.key;
                    final count = timetable.weeklySchedule.where((e) => e.weekday == entry.key).length;
                    final isToday = DateTime.now().weekday == entry.key;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(entry.value),
                            if (isToday) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => timetable.setSelectedWeekday(entry.key),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              // Quick Banner: Mark Today's Attendance
              InkWell(
                onTap: () => context.go(AppRoutes.attendance),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fact_check_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Mark Today's Attendance as per Schedule",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              // Search Bar
              AppTextField(
                label: 'Search Timetable',
                hint: 'Search by subject, faculty, room...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (q) => timetable.setSearchQuery(q),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // Schedule List
              Expanded(
                child: timetable.isLoading
                    ? ListView.separated(
                        itemCount: 3,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => const DashboardSkeletonLoader(height: 110),
                      )
                    : timetable.error != null
                        ? Center(
                            child: Text(
                              timetable.error!,
                              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                            ),
                          )
                        : daySchedule.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_seat_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No classes scheduled for this day.',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add classes manually or upload a timetable.',
                                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => _showUploadTimetableSheet(context, uid),
                                            icon: const Icon(Icons.file_upload_outlined, size: 16),
                                            label: const Text('Upload'),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton.icon(
                                            onPressed: () => _showAddClassSheet(context, uid),
                                            icon: const Icon(Icons.add, size: 16),
                                            label: const Text('Add Class'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: daySchedule.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = daySchedule[index];
                                  return TimetableClassCard(
                                    entry: item,
                                    onTap: () => _showClassDetailModal(context, item, uid),
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
