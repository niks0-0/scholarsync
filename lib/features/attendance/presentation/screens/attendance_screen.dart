import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../attendance_provider.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/attendance_summary_header.dart';
import '../widgets/bunk_calculator_sheet.dart';
import '../widgets/subject_attendance_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _filterIndex = 0; // 0: All, 1: Safe, 2: At Risk

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AttendanceProvider>().loadAttendance(user.uid);
      }
    });
  }

  void _openCalculator() {
    final attendance = context.read<AttendanceProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BunkCalculatorSheet(subjects: attendance.subjects),
    );
  }

  void _openAddSubject() {
    final attendance = context.read<AttendanceProvider>();
    showDialog(
      context: context,
      builder: (_) => AddSubjectDialog(
        onAdd: (sub) {
          attendance.addSubject(sub);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${sub.subjectName} added to tracker!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attendance = context.watch<AttendanceProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final filteredSubjects = attendance.subjects.where((s) {
      if (_filterIndex == 1) return s.isSafe;
      if (_filterIndex == 2) return !s.isSafe;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          IconButton(
            onPressed: _openCalculator,
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Safe Bunk Calculator',
          ),
          IconButton(
            onPressed: _openAddSubject,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Subject',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSubject,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Track Subject',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await attendance.loadAttendance(user.uid);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Summary Header
                AttendanceSummaryHeader(
                  overallPercentage: attendance.overallPercentage,
                  totalAttended: attendance.totalAttended,
                  totalClasses: attendance.totalClasses,
                  atRiskCount: attendance.atRiskCount,
                  onOpenCalculator: _openCalculator,
                ),
                const SizedBox(height: 16),

                // Filter Pill Selector (All, Safe, At Risk)
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _buildFilterTab(
                        context,
                        title: 'All (${attendance.subjects.length})',
                        index: 0,
                      ),
                      _buildFilterTab(
                        context,
                        title: 'Safe (${attendance.safeCount})',
                        index: 1,
                      ),
                      _buildFilterTab(
                        context,
                        title: 'At Risk (${attendance.atRiskCount})',
                        index: 2,
                        isAlert: attendance.atRiskCount > 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subjects Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enrolled Subjects',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Min 75% Required',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of Subject Attendance Cards
                if (attendance.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredSubjects.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 40,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No subjects in this category',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All your subjects are either safe or you haven\'t added any yet.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredSubjects.map(
                    (sub) => SubjectAttendanceCard(
                      subject: sub,
                      onMarkPresent: () => attendance.markClass(
                        subjectId: sub.id,
                        isPresent: true,
                      ),
                      onMarkAbsent: () => attendance.markClass(
                        subjectId: sub.id,
                        isPresent: false,
                      ),
                      onUndo: () => attendance.undoMarkClass(
                        subjectId: sub.id,
                      ),
                    ),
                  ),

                const SizedBox(height: 80), // FAB clearance
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required String title,
    required int index,
    bool isAlert = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _filterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isAlert ? const Color(0xFFEF4444) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
