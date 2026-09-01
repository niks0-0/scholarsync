import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/steps/academic_info_step.dart';
import '../widgets/steps/college_step.dart';
import '../widgets/steps/completion_step.dart';
import '../widgets/steps/preferences_step.dart';
import '../widgets/steps/profile_step.dart';
import '../widgets/steps/welcome_step.dart';

/// Master multi-step student onboarding screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const List<String> _stepTitles = [
    'Welcome',
    'College',
    'Academic Info',
    'Profile',
    'Preferences',
    'Completion',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      context.read<OnboardingProvider>().init(profile);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final currentStep = onboarding.currentStep;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator Header
            OnboardingHeader(
              currentStep: currentStep,
              totalSteps: _stepTitles.length,
              stepTitle: _stepTitles[currentStep],
            ),

            const Divider(height: 1),

            // Step Content PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Require guided navigation
                onPageChanged: (page) => onboarding.setStep(page),
                children: [
                  WelcomeStep(onNext: _nextPage),
                  CollegeStep(onNext: _nextPage, onPrevious: _previousPage),
                  AcademicInfoStep(onNext: _nextPage, onPrevious: _previousPage),
                  ProfileStep(onNext: _nextPage, onPrevious: _previousPage),
                  PreferencesStep(onNext: _nextPage, onPrevious: _previousPage),
                  CompletionStep(onPrevious: _previousPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
