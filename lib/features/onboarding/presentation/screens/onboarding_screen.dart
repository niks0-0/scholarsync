import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/steps/academic_info_step.dart';
import '../widgets/steps/college_step.dart';
import '../widgets/steps/completion_step.dart';
import '../widgets/steps/legal_verification_step.dart';
import '../widgets/steps/preferences_step.dart';
import '../widgets/steps/profile_step.dart';
import '../widgets/steps/welcome_step.dart';

/// Production-grade multi-step student onboarding container for ScholarSync.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const List<String> _stepTitles = [
    'Welcome',
    'Institution',
    'Curriculum',
    'Profile & Interests',
    'Preferences',
    'Verification & Legal',
    'Completion & Review',
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
    final current = context.read<OnboardingProvider>().currentStep;
    _animateToPage(current);
  }

  void _previousPage() {
    final current = context.read<OnboardingProvider>().currentStep;
    _animateToPage(current);
  }

  void _animateToPage(int page) {
    if (_pageController.hasClients && _pageController.page?.round() != page) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final currentStep = onboarding.currentStep;

    // Synchronize page controller if changed via step buttons or edit summary cards
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToPage(currentStep);
    });

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

            // Step Content PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Require guided step navigation
                onPageChanged: (page) => onboarding.setStep(page),
                children: [
                  WelcomeStep(onNext: _nextPage),
                  CollegeStep(onNext: _nextPage, onPrevious: _previousPage),
                  AcademicInfoStep(onNext: _nextPage, onPrevious: _previousPage),
                  ProfileStep(onNext: _nextPage, onPrevious: _previousPage),
                  PreferencesStep(onNext: _nextPage, onPrevious: _previousPage),
                  LegalVerificationStep(onNext: _nextPage, onPrevious: _previousPage),
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
