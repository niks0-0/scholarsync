import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/loading_button.dart';
import '../widgets/app_divider.dart';
import '../widgets/social_login_button.dart';
import '../widgets/text_button_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/auth_scaffold.dart';

/// Register screen — full name + email + password + confirm password.
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
              const Center(child: AppLogo(size: LogoSize.small)),

              const SizedBox(height: AppDimensions.spacingXxxl),

              Text(
                AppStrings.registerTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              Text(
                AppStrings.registerSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxxl),

              if (_errorMessage.isNotEmpty) ...[
                ErrorMessage(
                  message: _errorMessage,
                  onDismiss: () => setState(() => _errorMessage = ''),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
              ],

              // ── Full Name ─────────────────────────────────────────────────────
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
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
              ),

              const SizedBox(height: AppDimensions.authFormSpacing),

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
                hint: AppStrings.fieldNewPasswordHint,
                controller: _passwordController,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.next,
                validator: AppValidators.password,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              // ── Password Strength ─────────────────────────────────────────────
              PasswordStrengthIndicator(password: _passwordValue),

              const SizedBox(height: AppDimensions.authFormSpacing),

              // ── Confirm Password ──────────────────────────────────────────────
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

              const SizedBox(height: AppDimensions.spacingXxl),

              LoadingButton(
                label: AppStrings.registerButton,
                onPressed: _submit,
                isLoading: auth.isLoading,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // ── Terms note ────────────────────────────────────────────────────
              Text(
                AppStrings.registerTerms,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              const AppDivider(label: AppStrings.registerOrContinueWith),

              const SizedBox(height: AppDimensions.spacingXxl),

              SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: _signInWithGoogle,
                isLoading: auth.isLoading,
              ),

              const SizedBox(height: AppDimensions.spacingXxxl),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.registerHaveAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
    );
  }
}

