import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';

/// Luxury Matte Dark Step for Legal Undertakings and Dual-Method Student Verification.
class LegalVerificationStep extends StatefulWidget {
  const LegalVerificationStep({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<LegalVerificationStep> createState() => _LegalVerificationStepState();
}

class _LegalVerificationStepState extends State<LegalVerificationStep> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final onboarding = context.read<OnboardingProvider>();
    _emailController.text = onboarding.institutionalEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickIdCard(OnboardingProvider onboarding) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        onboarding.setIdCardBytes(bytes);
      }
    } catch (e) {
      debugPrint('Error picking ID card: $e');
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0xFF27272A)),
        ),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Terms & Academic Guarantee',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Self-Concern & Attendance Prediction\n'
                'ScholarSync provides attendance calculators, 75% safe-bunk estimations, and recovery plans for personal planning. The student remains 100% responsible for institutional attendance criteria and official detention lists.\n\n'
                '2. Authentic Sharing & Zero Plagiarism\n'
                'Uploaded study notes, summaries, and chat attachments must be genuine and respectful of intellectual property rights.\n\n'
                '3. Student Verification Integrity\n'
                'Users agree that providing fraudulent or misleading institutional credentials will result in permanent account suspension.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I Understand', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
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
          // ── Section Header ───────────────────────────────────────────────
          Text(
            'Legal Undertaking & Verification',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Acknowledge institutional responsibility guidelines and verify your student status.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Legal Undertaking 1: Self-Concern Guarantee ──────────────────
          _buildUndertakingCard(
            context,
            icon: Icons.verified_user_rounded,
            title: 'Self-Concern & Attendance Guarantee',
            description:
                'I acknowledge that all attendance calculations, safe-bunk estimates (75% threshold), and predictions are strictly for my personal guidance. I am solely responsible for institutional attendance criteria.',
            isChecked: onboarding.legalUndertakingAccepted,
            onChanged: (val) => onboarding.setLegalUndertaking(val ?? false),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // ── Legal Undertaking 2: Terms of Service & Privacy Policy ────────
          _buildUndertakingCard(
            context,
            icon: Icons.shield_outlined,
            title: 'Terms of Service & Responsibility Guarantee',
            description:
                'I agree to the Terms of Service, Privacy Policy, and guarantee all shared study materials are clean, authentic, and authorized.',
            isChecked: onboarding.termsAccepted,
            onChanged: (val) => onboarding.setTermsAccepted(val ?? false),
            actionLabel: 'Read Terms',
            onAction: () => _showTermsDialog(context),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Verification Method Header ───────────────────────────────────
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Student Status Verification (v1.0)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose either instant verification with your college email or upload your student ID photo.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // ── Dual-Method Tabs Switcher ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onboarding.setVerificationMethod('college_id'),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: onboarding.verificationMethod == 'college_id'
                            ? const Color(0xFF27272A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: onboarding.verificationMethod == 'college_id'
                            ? Border.all(color: AppColors.primary.withValues(alpha: 0.6))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card_rounded,
                            size: 16,
                            color: onboarding.verificationMethod == 'college_id'
                                ? AppColors.primary
                                : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'College ID Card',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: onboarding.verificationMethod == 'college_id'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: onboarding.verificationMethod == 'college_id'
                                  ? Colors.white
                                  : Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onboarding.setVerificationMethod('college_email'),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: onboarding.verificationMethod == 'college_email'
                            ? const Color(0xFF27272A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: onboarding.verificationMethod == 'college_email'
                            ? Border.all(color: AppColors.secondary.withValues(alpha: 0.6))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_email_read_rounded,
                            size: 16,
                            color: onboarding.verificationMethod == 'college_email'
                                ? AppColors.secondary
                                : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'College Email OTP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: onboarding.verificationMethod == 'college_email'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: onboarding.verificationMethod == 'college_email'
                                  ? Colors.white
                                  : Colors.white60,
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

          const SizedBox(height: AppDimensions.spacingLg),

          // ── Method Content ──────────────────────────────────────────────
          if (onboarding.verificationMethod == 'college_id') ...[
            _buildCollegeIdUploadSection(context, onboarding),
          ] else ...[
            _buildCollegeEmailOtpSection(context, onboarding),
          ],

          // ── Error Banner ────────────────────────────────────────────────
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
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
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

          // ── Navigation Buttons ──────────────────────────────────────────
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
                  label: 'Save & Continue',
                  onPressed: () {
                    if (onboarding.nextStep()) {
                      widget.onNext();
                    }
                  },
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Undertaking Checkbox Card ─────────────────────────────────────────────
  Widget _buildUndertakingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isChecked ? AppColors.primary.withValues(alpha: 0.5) : const Color(0xFF27272A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox.adaptive(
            value: isChecked,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: isChecked ? AppColors.primary : Colors.white60),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAction,
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── College ID Photo Upload Section ───────────────────────────────────────
  Widget _buildCollegeIdUploadSection(BuildContext context, OnboardingProvider onboarding) {
    final hasCard = onboarding.idCardBytes != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Upload Student ID Card Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Admin verifies your student card. You will immediately get Read-Only Preview of Timetables & Attendance; Community Chat unlocks once verified.',
            style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65), height: 1.3),
          ),
          const SizedBox(height: 14),

          // Upload Box / ID Card Preview
          InkWell(
            onTap: () => _pickIdCard(onboarding),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0E),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: hasCard ? AppColors.success : const Color(0xFF3F3F46),
                  width: hasCard ? 1.5 : 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 1),
                child: hasCard
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            onboarding.idCardBytes!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.credit_card_rounded, color: AppColors.success, size: 48),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              color: Colors.black.withValues(alpha: 0.75),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'ID Card Selected • Tap to Change',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Click to Browse & Upload College ID',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select image from device (JPEG, PNG, JPG)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── College Email OTP Section ─────────────────────────────────────────────
  Widget _buildCollegeEmailOtpSection(BuildContext context, OnboardingProvider onboarding) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Institutional Email Instant Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Instant 100% verified status. Enter your university or college domain email address to receive an instant OTP.',
            style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65), height: 1.3),
          ),
          const SizedBox(height: 14),

          AppTextField(
            label: 'College / University Email',
            hint: 'student@college.edu',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            onChanged: (val) => onboarding.setInstitutionalEmail(val),
          ),
          const SizedBox(height: 10),

          if (onboarding.generatedOtp == null && !onboarding.isEmailVerified) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                onboarding.setInstitutionalEmail(_emailController.text);
                onboarding.sendEmailOtp();
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],

          if (onboarding.generatedOtp != null && !onboarding.isEmailVerified) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test evaluation OTP sent: ${onboarding.generatedOtp}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            AppTextField(
              label: '6-Digit OTP Code',
              hint: '742910',
              controller: _otpController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.lock_outline_rounded,
              onChanged: (val) => onboarding.setOtpInput(val),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                onboarding.verifyOtp(_otpController.text);
              },
              child: const Text('Verify OTP & Unlock Full Access', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],

          if (onboarding.isEmailVerified) ...[
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✓ Institutional Email Verified! Full access unlocked.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
