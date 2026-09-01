import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';

class AcademicInfoStep extends StatefulWidget {
  const AcademicInfoStep({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<AcademicInfoStep> createState() => _AcademicInfoStepState();
}

class _AcademicInfoStepState extends State<AcademicInfoStep> {
  final TextEditingController _customDivisionController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  bool _isCustomDivision = false;

  @override
  void dispose() {
    _customDivisionController.dispose();
    _rollNumberController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Identity',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Define your branch, academic year, semester, and division to align timetable & course modules.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Branch Selection ──────────────────────────────────────────────
          Text(
            'Academic Branch / Program',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onboarding.branch,
                isExpanded: true,
                dropdownColor: colorScheme.surfaceContainerHighest,
                items: OnboardingProvider.availableBranches.map((b) {
                  return DropdownMenuItem<String>(
                    value: b,
                    child: Text(b, style: textTheme.bodyLarge),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onboarding.setBranch(val);
                },
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Academic Year Selection ─────────────────────────────────────────
          Text(
            'Current Academic Year',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: OnboardingProvider.availableAcademicYears.map((yr) {
              final isSelected = onboarding.academicYear == yr;
              return ChoiceChip(
                label: Text(yr),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => onboarding.setAcademicYear(yr),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Semester Selection (1 to 8) ───────────────────────────────────
          Text(
            'Current Semester',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: OnboardingProvider.availableSemesters.map((sem) {
              final isSelected = onboarding.semester == sem;
              return ChoiceChip(
                label: Text('Sem $sem'),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => onboarding.setSemester(sem),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Division Selectable Value ─────────────────────────────────────
          Text(
            'Division / Section',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: OnboardingProvider.availableDivisions.map((div) {
              final isSelected = !_isCustomDivision && onboarding.division == div;
              final isCustomBtn = div == 'Custom';

              return ChoiceChip(
                label: Text(isCustomBtn ? 'Custom...' : 'Division $div'),
                selected: isCustomBtn ? _isCustomDivision : isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: (isCustomBtn ? _isCustomDivision : isSelected)
                      ? Colors.white
                      : colorScheme.onSurface,
                  fontWeight: (isCustomBtn ? _isCustomDivision : isSelected)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (_) {
                  if (isCustomBtn) {
                    setState(() => _isCustomDivision = true);
                  } else {
                    setState(() => _isCustomDivision = false);
                    onboarding.setDivision(div);
                  }
                },
              );
            }).toList(),
          ),

          if (_isCustomDivision) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            AppTextField(
              label: 'Custom Division',
              hint: 'Enter custom division (e.g., Sec-B1)',
              controller: _customDivisionController,
              prefixIcon: Icons.edit_note_rounded,
              onChanged: (val) => onboarding.setDivision(val),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Optional Student Identifiers ──────────────────────────────────
          Text(
            'Institutional Identifiers (Optional)',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Roll Number',
                  hint: 'e.g., 1042',
                  controller: _rollNumberController,
                  prefixIcon: Icons.badge_outlined,
                  onChanged: (val) => onboarding.setRollNumber(val),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: AppTextField(
                  label: 'Student / Enroll ID',
                  hint: 'e.g., 2026-CS-09',
                  controller: _enrollmentController,
                  prefixIcon: Icons.fingerprint_rounded,
                  onChanged: (val) => onboarding.setEnrollmentNumber(val),
                ),
              ),
            ],
          ),

          if (onboarding.error != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
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
          ],

          const SizedBox(height: AppDimensions.spacingXxxl),

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
