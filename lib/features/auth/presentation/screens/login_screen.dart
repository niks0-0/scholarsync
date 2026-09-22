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
import '../widgets/quick_persona_sheet.dart';
import '../widgets/social_login_button.dart';
import '../widgets/text_button_widget.dart';

/// State-of-the-Art Luxury AMOLED Login Screen with Tabbed Student & Admin Portals.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _openPersonaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickPersonaSheet(
        onSelectCredentials: (email, password, label) {
          setState(() {
            _emailController.text = email;
            _passwordController.text = password;
            _errorMessage = '';
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = '');
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await auth.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!success && auth.error != null) {
      setState(() => _errorMessage = auth.error!);
    } else if (success) {
      final user = auth.currentUser;
      if (user != null) {
        await profileProvider.syncProfile(
          firebaseUid: user.uid,
          email: user.email ?? '',
          fullName: user.displayNameOrEmail,
          avatarUrl: user.photoUrl,
          authProvider: 'password',
        );
        if (!mounted) return;
        await context.read<NotificationProvider>().syncDeviceToken(user.uid);
      }
      if (!mounted) return;
      final profile = profileProvider.profile;
      if (profile?.role.isAdmin ?? false) {
        context.go('/admin');
      } else if (profile?.onboardingCompleted ?? false) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
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

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AuthMeshBackground(
        primaryGlowColor: const Color(0xFF38BDF8),
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
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                                onPressed: () => context.go('/welcome'),
                                tooltip: 'Back to Welcome',
                              ),

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
                                    Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
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

                        const SizedBox(height: 16),

                        // ── App Brand Header ─────────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              const AppLogo(size: LogoSize.medium),
                              const SizedBox(height: 14),
                              const Text(
                                AppStrings.loginTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.loginSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Main Obsidian Glass Form Card ────────────────────────
                        AuthGlassCard(
                          padding: const EdgeInsets.all(22),
                          hasActiveGlow: false,
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

                              // ── Email Input ──────────────────────────────────
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

                              // ── Password Input ───────────────────────────────
                              PasswordField(
                                label: AppStrings.fieldPassword,
                                hint: AppStrings.fieldPasswordHint,
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                validator: AppValidators.password,
                                onFieldSubmitted: (_) => _submit(),
                              ),

                              const SizedBox(height: 8),

                              // ── Forgot Password ──────────────────────────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: AppTextButton(
                                  label: AppStrings.loginForgotPassword,
                                  onPressed: () => context.push('/forgot-password'),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Submit Button ────────────────────────────────
                              LoadingButton(
                                label: AppStrings.loginButton,
                                onPressed: _submit,
                                isLoading: auth.isLoading,
                                icon: Icons.login_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Divider ─────────────────────────────────────────────
                        const AppDivider(label: AppStrings.loginOrContinueWith),

                        const SizedBox(height: 16),

                        // ── Social Sign-In ──────────────────────────────────────
                        SocialLoginButton(
                          provider: SocialProvider.google,
                          onPressed: _signInWithGoogle,
                          isLoading: auth.isLoading,
                        ),

                        const SizedBox(height: 24),

                        // ── Create Account Link ─────────────────────────────────
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.loginNoAccount,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              AppTextButton(
                                label: AppStrings.loginSignUp,
                                onPressed: () => context.push('/register'),
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
}
