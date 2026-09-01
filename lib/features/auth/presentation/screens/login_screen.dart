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
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/app_divider.dart';
import '../widgets/social_login_button.dart';
import '../widgets/text_button_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/auth_scaffold.dart';

/// Login screen — email + password form.
/// No auth logic yet (Phase 1 stub).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      if (profileProvider.profile?.role.isAdmin ?? false) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  void _fillAdminCredentials() {
    setState(() {
      _emailController.text = 'admin@scholarsync.com';
      _passwordController.text = 'Admin@123456';
      _errorMessage = '';
    });
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
      // Sync Supabase Profile (lookup or create)
      await profileProvider.syncProfile(
        firebaseUid: user.uid,
        email: user.email ?? '',
        fullName: user.displayNameOrEmail,
        avatarUrl: user.photoUrl,
        authProvider: 'google.com',
      );

      if (!mounted) return;

      // Sync FCM device token to Supabase public.user_devices
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
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Back',
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ────────────────────────────────────────────────────────
              const Center(child: AppLogo(size: LogoSize.small)),

              const SizedBox(height: AppDimensions.spacingXxxl),

              // ── Heading ──────────────────────────────────────────────────────
              Text(
                AppStrings.loginTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              Text(
                AppStrings.loginSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: _fillAdminCredentials,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '⚡ Fill App Owner Admin (admin@scholarsync.com)',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // ── Error ─────────────────────────────────────────────────────────
              if (_errorMessage.isNotEmpty) ...[
                ErrorMessage(
                  message: _errorMessage,
                  onDismiss: () => setState(() => _errorMessage = ''),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
              ],

              // ── Email ─────────────────────────────────────────────────────────
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
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),

              const SizedBox(height: AppDimensions.authFormSpacing),

              // ── Password ──────────────────────────────────────────────────────
              PasswordField(
                label: AppStrings.fieldPassword,
                hint: AppStrings.fieldPasswordHint,
                controller: _passwordController,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.done,
                validator: AppValidators.password,
                onFieldSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              // ── Forgot password ────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: AppTextButton(
                  label: AppStrings.loginForgotPassword,
                  onPressed: () => context.push('/forgot-password'),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // ── Submit ────────────────────────────────────────────────────────
              LoadingButton(
                label: AppStrings.loginButton,
                onPressed: _submit,
                isLoading: auth.isLoading,
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // ── Divider ───────────────────────────────────────────────────────
              const AppDivider(label: AppStrings.loginOrContinueWith),

              const SizedBox(height: AppDimensions.spacingXxl),

              // ── Social ────────────────────────────────────────────────────────
              SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: _signInWithGoogle,
                isLoading: auth.isLoading,
              ),

              const SizedBox(height: AppDimensions.authFormSpacing),

              SocialLoginButton(
                provider: SocialProvider.apple,
                onPressed: () {
                  // TODO(Phase 2): Apple Sign In
                },
              ),

              const SizedBox(height: AppDimensions.spacingXxxl),

              // ── Sign-up link ──────────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.loginNoAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
    );
  }
}

