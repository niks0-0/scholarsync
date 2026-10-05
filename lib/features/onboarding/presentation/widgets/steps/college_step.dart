import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';
import '../onboarding_classification_badge.dart';

class CollegeStep extends StatefulWidget {
  const CollegeStep({super.key, required this.onNext, required this.onPrevious});

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<CollegeStep> createState() => _CollegeStepState();
}

class _CollegeStepState extends State<CollegeStep> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final selectedCollege = onboarding.selectedCollege;
    final colleges = onboarding.colleges;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Your Institution',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const OnboardingClassificationBadge(level: ClassificationLevel.required),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Choose your college from the master dataset to sync timetables, subjects, and campus announcements.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // ── State & University Cascading Filter Row ──
          Row(
            children: [
              // State Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: onboarding.states.any((s) => s.id == onboarding.selectedState?.id)
                          ? onboarding.selectedState?.id
                          : null,
                      hint: Text('All States', style: textTheme.bodySmall),
                      isExpanded: true,
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All States', style: textTheme.bodySmall),
                        ),
                        ...onboarding.states.map((s) => DropdownMenuItem<String?>(
                              value: s.id,
                              child: Text(s.name,
                                  style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                            )),
                      ],
                      onChanged: (stateId) {
                        if (stateId == null) {
                          onboarding.setSelectedState(null);
                        } else {
                          final state = onboarding.states.where((s) => s.id == stateId).firstOrNull;
                          onboarding.setSelectedState(state);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // University Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: onboarding.filteredUniversities.any((u) => u.id == onboarding.selectedUniversity?.id)
                          ? onboarding.selectedUniversity?.id
                          : null,
                      hint: Text('All Universities', style: textTheme.bodySmall),
                      isExpanded: true,
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Universities', style: textTheme.bodySmall),
                        ),
                        ...onboarding.filteredUniversities.map((u) => DropdownMenuItem<String?>(
                              value: u.id,
                              child: Text(u.name,
                                  style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                            )),
                      ],
                      onChanged: (uniId) {
                        if (uniId == null) {
                          onboarding.setSelectedUniversity(null);
                        } else {
                          final uni =
                              onboarding.universities.where((u) => u.id == uniId).firstOrNull;
                          onboarding.setSelectedUniversity(uni);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Search Field
          AppTextField(
            label: 'Search College',
            hint: 'Search college name, code, or city...',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: (val) => onboarding.searchColleges(val),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Selected College Card Preview
          if (selectedCollege != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCollege.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Code: ${selectedCollege.code}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],

          // College Dataset List
          Expanded(
            child: colleges.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          'No colleges found matching criteria.',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: colleges.length,
                    itemBuilder: (context, index) {
                      final college = colleges[index];
                      final isSelected = selectedCollege?.id == college.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : colorScheme.outline.withValues(alpha: 0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => onboarding.setSelectedCollege(college),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : colorScheme.surfaceContainerHighest,
                            child: Text(
                              college.code.substring(0, college.code.length > 3 ? 3 : college.code.length),
                              style: TextStyle(
                                color: isSelected ? Colors.black : colorScheme.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            college.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              : null,
                        ),
                      );
                    },
                  ),
          ),

          if (onboarding.error != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onboarding.error!,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingLg),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onboarding.previousStep();
                    widget.onPrevious();
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    if (onboarding.nextStep()) {
                      widget.onNext();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
