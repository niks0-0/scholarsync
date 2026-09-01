import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';

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
          Text(
            'Select Your College / University',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Choose your institution from the official dataset to align timetables and announcements.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Search Field
          AppTextField(
            label: 'Search College',
            hint: 'Search college name or code...',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: (query) => onboarding.searchColleges(query),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          if (onboarding.error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error),
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
            const SizedBox(height: AppDimensions.spacingMd),
          ],

          // College Dataset List
          Expanded(
            child: colleges.isEmpty
                ? Center(
                    child: Text(
                      'No colleges found matching "${_searchController.text}".',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: colleges.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final college = colleges[index];
                      final isSelected = selectedCollege?.id == college.id;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onboarding.setSelectedCollege(college),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(AppDimensions.spacingLg),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : colorScheme.outline.withValues(alpha: 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_rounded,
                                  color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppDimensions.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        college.name,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.primary : colorScheme.onSurface,
                                        ),
                                      ),
                                      if (college.code.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Code: ${college.code}',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

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
