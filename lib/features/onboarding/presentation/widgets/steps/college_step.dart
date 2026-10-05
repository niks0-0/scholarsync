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
  late final TextEditingController _searchController;
  late final TextEditingController _manualNameController;
  late final TextEditingController _manualCodeController;

  @override
  void initState() {
    super.initState();
    final onboarding = context.read<OnboardingProvider>();
    _searchController = TextEditingController(text: onboarding.collegeSearchQuery);
    _manualNameController = TextEditingController(text: onboarding.manualCollegeName);
    _manualCodeController = TextEditingController(text: onboarding.manualCollegeCode);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _switchToManual({String? prefilledName}) {
    final onboarding = context.read<OnboardingProvider>();
    final name = prefilledName ?? _searchController.text.trim();
    if (name.isNotEmpty && _manualNameController.text.trim().isEmpty) {
      _manualNameController.text = name;
      onboarding.setManualCollegeName(name);
    }
    onboarding.setIsManualCollege(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final selectedCollege = onboarding.selectedCollege;
    final colleges = onboarding.colleges;
    final isManual = onboarding.isManualCollege;

    // Sync controllers if draft was loaded asynchronously
    if (_manualNameController.text != onboarding.manualCollegeName &&
        onboarding.manualCollegeName.isNotEmpty) {
      _manualNameController.text = onboarding.manualCollegeName;
    }
    if (_manualCodeController.text != onboarding.manualCollegeCode &&
        onboarding.manualCollegeCode.isNotEmpty) {
      _manualCodeController.text = onboarding.manualCollegeCode;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final listMaxHeight = (screenHeight * 0.36).clamp(180.0, 320.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select Your Institution',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const OnboardingClassificationBadge(level: ClassificationLevel.required),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            isManual
                ? 'Type your college details manually to proceed without catalog restrictions.'
                : 'Choose your college from the master dataset or enter it manually to sync timetables and campus updates.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // ── Mode Switcher: Browse Catalog vs Enter Manually ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onboarding.setIsManualCollege(false),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isManual ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: !isManual
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: !isManual ? Colors.black : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Browse Catalog',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: !isManual ? FontWeight.bold : FontWeight.w500,
                                color: !isManual ? Colors.black : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () => _switchToManual(),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isManual ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: isManual
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: isManual ? Colors.black : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Enter Manually',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: isManual ? FontWeight.bold : FontWeight.w500,
                                color: isManual ? Colors.black : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

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

          // ── Conditional Body based on Mode ──
          if (!isManual) ...[
            // Search Field
            AppTextField(
              label: 'Search College',
              hint: 'Search college name, code, or city...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => onboarding.searchColleges(val),
            ),

            // Quick manual entry helper below search bar
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _switchToManual(),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.primary),
                label: Text(
                  "Can't find your college? Enter manually",
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingSm),

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
              const SizedBox(height: AppDimensions.spacingMd),
            ],

            // College Dataset List (Bounded with ConstrainedBox for zero pixel overflow)
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 140,
                maxHeight: listMaxHeight,
              ),
              child: colleges.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_rounded, size: 40, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              'No colleges found matching criteria.',
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add_business_rounded, color: AppColors.primary, size: 18),
                              label: Text(
                                _searchController.text.trim().isNotEmpty
                                    ? 'Enter "${_searchController.text.trim()}" Manually'
                                    : 'Enter College Name Manually',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _switchToManual(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
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
          ] else ...[
            // ── Manual College Entry Form ──
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      'Type your college details below. ScholarSync will link your institution directly to your profile so you can proceed smoothly.',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            AppTextField(
              label: 'College / Institution Name *',
              hint: 'e.g., L.D. College of Engineering or IIT Bombay',
              controller: _manualNameController,
              prefixIcon: Icons.account_balance_rounded,
              onChanged: (val) => onboarding.setManualCollegeName(val),
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            AppTextField(
              label: 'College Code / Abbreviation (Optional)',
              hint: 'e.g., LDCE, IITB (Auto-generated if blank)',
              controller: _manualCodeController,
              prefixIcon: Icons.tag_rounded,
              onChanged: (val) => onboarding.setManualCollegeCode(val),
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Manual Card Live Preview
            if (onboarding.manualCollegeName.trim().isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
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
                      child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            onboarding.manualCollegeName.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${onboarding.manualCollegeCode.trim().isNotEmpty ? onboarding.manualCollegeCode.trim().toUpperCase() : "(Auto-generated)"}',
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
              const SizedBox(height: AppDimensions.spacingMd),
            ],

            Center(
              child: TextButton.icon(
                onPressed: () => onboarding.setIsManualCollege(false),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to catalog search'),
              ),
            ),
          ],

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
          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }
}
