import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/presentation/academic_catalog_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../../dashboard/presentation/dashboard_provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();
    final catalog = context.watch<AcademicCatalogProvider>();

    final matchingSubjects = _query.isEmpty
        ? []
        : catalog.curriculumSubjects.where((s) {
            final q = _query.toLowerCase();
            return s.subjectName.toLowerCase().contains(q) ||
                s.subjectCode.toLowerCase().contains(q) ||
                s.shortName.toLowerCase().contains(q);
          }).toList();

    final matchingClasses = _query.isEmpty
        ? []
        : dashboard.schedule.where((c) {
            final q = _query.toLowerCase();
            return c.subject.toLowerCase().contains(q) ||
                c.faculty.toLowerCase().contains(q) ||
                c.room.toLowerCase().contains(q);
          }).toList();

    final matchingAssignments = _query.isEmpty
        ? []
        : dashboard.assignments.where((a) {
            final q = _query.toLowerCase();
            return a.title.toLowerCase().contains(q) ||
                a.subject.toLowerCase().contains(q);
          }).toList();

    final totalResults = matchingSubjects.length + matchingClasses.length + matchingAssignments.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Global Search'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Search ScholarSync',
                hint: 'Search subjects, lectures, assignments, events...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (q) => setState(() => _query = q.trim()),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              if (_query.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded, size: 54, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Type to search across subjects, schedule, and assignments',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (totalResults == 0) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No academic records found for "$_query"',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView(
                    children: [
                      if (matchingSubjects.isNotEmpty) ...[
                        Text('Subjects (${matchingSubjects.length})', style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...matchingSubjects.map((s) => ListTile(
                              leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                              title: Text(s.subjectName),
                              subtitle: Text('${s.subjectCode} • ${s.branch} Sem ${s.semester}'),
                              onTap: () => context.push('/activities'),
                            )),
                        const Divider(),
                      ],
                      if (matchingClasses.isNotEmpty) ...[
                        Text('Today Schedule (${matchingClasses.length})', style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...matchingClasses.map((c) => ListTile(
                              leading: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                              title: Text(c.subject),
                              subtitle: Text('${c.startTime} - ${c.endTime} • ${c.room}'),
                              onTap: () => context.push('/home'),
                            )),
                        const Divider(),
                      ],
                      if (matchingAssignments.isNotEmpty) ...[
                        Text('Assignments (${matchingAssignments.length})', style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...matchingAssignments.map((a) => ListTile(
                              leading: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                              title: Text(a.title),
                              subtitle: Text('${a.subject} • Priority: ${a.priority.name}'),
                              onTap: () => context.push('/activities'),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
