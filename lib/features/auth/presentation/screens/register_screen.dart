import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_divider.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_button.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/quick_persona_sheet.dart';
import '../widgets/social_login_button.dart';
import '../widgets/text_button_widget.dart';

/// State-of-the-Art Luxury AMOLED Registration Screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  String _errorMessage = '';
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() => _passwordValue = _passwordController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _openPersonaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickPersonaSheet(
        onSelectCredentials: (email, password, label) async {
          final auth = context.read<AuthProvider>();
          final profileProvider = context.read<ProfileProvider>();

          final success = await auth.signInWithEmail(email: email, password: password);
          if (!mounted) return;

          if (success) {
            final user = auth.currentUser;
            if (user != null) {
              await profileProvider.syncProfile(
                firebaseUid: user.uid,
                email: user.email ?? email,
                fullName: user.displayNameOrEmail,
                avatarUrl: user.photoUrl,
                authProvider: 'password',
              );
              if (!mounted) return;
              await context.read<NotificationProvider>().syncDeviceToken(user.uid);
            }
            if (!mounted) return;
            if (profileProvider.profile?.role.isAdmin ?? false) {
              context.go('/admin');
            } else {
              context.go('/home');
            }
          }
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = '');
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.registerWithEmail(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!success && auth.error != null) {
      setState(() => _errorMessage = auth.error!);
    } else if (success) {
      context.pushReplacement('/verify-email');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _errorMessage = '');
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await auth.signInWithGoogle();

    if (!mounted) return;

    if (!success) {
      if (auth.error != null && auth.error != 'Sign-in was cancelled.') {
        setState(() => _errorMessage = auth.error!);
      }
      return;
    }

    final user = auth.currentUser;
    if (user != null) {
      await profileProvider.syncProfile(
        firebaseUid: user.uid,
        email: user.email ?? '',
        fullName: user.displayNameOrEmail,
        avatarUrl: user.photoUrl,
        authProvider: 'google.com',
      );

      if (!mounted) return;
      await context.read<NotificationProvider>().syncDeviceToken(user.uid);

      if (!mounted) return;
      final isOnboardingDone = profileProvider.profile?.onboardingCompleted ?? false;
      if (isOnboardingDone) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    final hasMinLength = _passwordValue.length >= 8;
    final hasUppercase = _passwordValue.contains(RegExp(r'[A-Z]'));
    final hasNumber = _passwordValue.contains(RegExp(r'[0-9]'));
    final hasSpecial = _passwordValue.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AuthMeshBackground(
        primaryGlowColor: const Color(0xFF22D3EE),
        secondaryGlowColor: const Color(0xFF818CF8),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.authMaxWidth),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.authHorizontalPadding,
                  vertical: AppDimensions.spacingMd,
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top Navigation Row ────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (context.canPop())
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                                onPressed: () => context.pop(),
                                tooltip: 'Back',
                              )
                            else
                              const SizedBox(width: 40),

                            InkWell(
                              onTap: _openPersonaSheet,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '⚡ Quick Demo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Header Brand ─────────────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              const AppLogo(size: LogoSize.small),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.registerTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.registerSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Main Glass Card ──────────────────────────────────────
                        AuthGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage.isNotEmpty) ...[
                                ErrorMessage(
                                  message: _errorMessage,
                                  onDismiss: () => setState(() => _errorMessage = ''),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // ── Full Name ────────────────────────────────────
                              AppTextField(
                                label: AppStrings.fieldFullName,
                                hint: AppStrings.fieldFullNameHint,
                                controller: _nameController,
                                focusNode: _nameFocus,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                validator: AppValidators.fullName,
                                autofillHints: const [AutofillHints.name],
                                prefixIcon: Icons.person_outline_rounded,
                                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                              ),

                              const SizedBox(height: 16),

                              // ── Email ────────────────────────────────────────
                              AppTextField(
                                label: AppStrings.fieldEmail,
                                hint: AppStrings.fieldEmailHint,
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: AppValidators.email,
                                autofillHints: const [AutofillHints.email],
                                prefixIcon: Icons.email_outlined,
                                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                              ),

                              const SizedBox(height: 16),

                              // ── Password ─────────────────────────────────────
                              PasswordField(
                                label: AppStrings.fieldPassword,
                                hint: AppStrings.fieldNewPasswordHint,
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.next,
                                validator: AppValidators.password,
                                autofillHints: const [AutofillHints.newPassword],
                                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                              ),

                              const SizedBox(height: 10),

                              // ── Password Strength Bar ────────────────────────
                              PasswordStrengthIndicator(password: _passwordValue),

                              if (_passwordValue.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                // Real-time Requirement Badges
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildRequirementChip('8+ Chars', hasMinLength),
                                    _buildRequirementChip('Uppercase', hasUppercase),
                                    _buildRequirementChip('Number', hasNumber),
                                    _buildRequirementChip('Symbol', hasSpecial),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 16),

                              // ── Confirm Password ─────────────────────────────
                              PasswordField(
                                label: AppStrings.fieldConfirmPassword,
                                hint: AppStrings.fieldConfirmPasswordHint,
                                controller: _confirmController,
                                focusNode: _confirmFocus,
                                textInputAction: TextInputAction.done,
                                validator: AppValidators.confirmPassword(_passwordController.text),
                                autofillHints: const [AutofillHints.newPassword],
                                onFieldSubmitted: (_) => _submit(),
                              ),

                              const SizedBox(height: 20),

                              // ── Submit Button ────────────────────────────────
                              LoadingButton(
                                label: AppStrings.registerButton,
                                onPressed: _submit,
                                isLoading: auth.isLoading,
                                icon: Icons.person_add_rounded,
                              ),

                              const SizedBox(height: 12),

                              // ── Terms & Privacy Notice ───────────────────────
                              Text(
                                AppStrings.registerTerms,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Divider ─────────────────────────────────────────────
                        const AppDivider(label: AppStrings.registerOrContinueWith),

                        const SizedBox(height: 16),

                        // ── Google One-Tap ──────────────────────────────────────
                        SocialLoginButton(
                          provider: SocialProvider.google,
                          onPressed: _signInWithGoogle,
                          isLoading: auth.isLoading,
                        ),

                        const SizedBox(height: 24),

                        // ── Sign In Link ────────────────────────────────────────
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.registerHaveAccount,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              AppTextButton(
                                label: AppStrings.registerSignIn,
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.success.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
              ? AppColors.success.withValues(alpha: 0.5)
              : const Color(0xFF27272A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 11,
            color: passed ? AppColors.success : Colors.white38,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: passed ? AppColors.success : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
