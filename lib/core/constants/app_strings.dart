/// All user-facing strings for ScholarSync.
/// Never hardcode strings inside widget files.
abstract final class AppStrings {
  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'ScholarSync';
  static const String appTagline = 'Your Student Companion';
  static const String appDescription =
      'Organize your college life, stay on top of your work, and keep everything you need in one place.';

  // ── Splash ───────────────────────────────────────────────────────────────
  static const String splashLoading = 'Loading...';

  // ── Welcome ──────────────────────────────────────────────────────────────
  static const String welcomeTitle = 'ScholarSync';
  static const String welcomeTagline = 'Your Student Companion';
  static const String welcomeSubtitle =
      'Organize your college life, stay on top of your work, and keep everything you need in one place.';
  static const String welcomeSignIn = 'Login';
  static const String welcomeGetStarted = 'Get Started';
  static const String welcomeAlreadyHaveAccount = 'Already have an account?';

  // ── Login ─────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome Back!';
  static const String loginSubtitle = 'Login to continue to ScholarSync.';
  static const String loginButton = 'Sign In';
  static const String loginForgotPassword = 'Forgot password?';
  static const String loginNoAccount = "Don't have an account?";
  static const String loginSignUp = 'Sign up';
  static const String loginWithGoogle = 'Continue with Google';
  static const String loginWithApple = 'Continue with Apple';
  static const String loginOrContinueWith = 'or continue with';

  // ── Register ─────────────────────────────────────────────────────────────
  static const String registerTitle = 'Create Your Account';
  static const String registerSubtitle =
      'Start organizing your student life with ScholarSync.';
  static const String registerButton = 'Create Account';
  static const String registerHaveAccount = 'Already have an account?';
  static const String registerSignIn = 'Login';
  static const String registerOrContinueWith = 'or continue with';
  static const String registerTerms =
      'By creating an account, you agree to our Terms of Service and Privacy Policy.';

  // ── Verify Email ──────────────────────────────────────────────────────────
  static const String verifyEmailTitle = 'Check your inbox';
  static const String verifyEmailSubtitle =
      "We've sent a verification link to your email address.";
  static const String verifyEmailInstruction =
      'Click the link in the email to verify your account. Check your spam folder if you don\'t see it.';
  static const String verifyEmailResend = 'Resend email';
  static const String verifyEmailChange = 'Change email address';
  static const String verifyEmailSent = 'Verification email sent!';

  // ── Forgot Password ───────────────────────────────────────────────────────
  static const String forgotPasswordTitle = 'Reset password';
  static const String forgotPasswordSubtitle =
      "Enter your email and we'll send you a reset link.";
  static const String forgotPasswordButton = 'Send Reset Link';
  static const String forgotPasswordBackToLogin = 'Back to sign in';
  static const String forgotPasswordSuccess =
      'Reset link sent! Check your inbox.';

  // ── Reset Password ────────────────────────────────────────────────────────
  static const String resetPasswordTitle = 'New password';
  static const String resetPasswordSubtitle = 'Create a strong new password.';
  static const String resetPasswordButton = 'Update Password';
  static const String resetPasswordSuccess = 'Password updated successfully!';

  // ── Form Fields ───────────────────────────────────────────────────────────
  static const String fieldEmail = 'Email address';
  static const String fieldEmailHint = 'you@example.com';
  static const String fieldPassword = 'Password';
  static const String fieldPasswordHint = 'Enter your password';
  static const String fieldConfirmPassword = 'Confirm password';
  static const String fieldConfirmPasswordHint = 'Re-enter your password';
  static const String fieldFullName = 'Full name';
  static const String fieldFullNameHint = 'Your full name';
  static const String fieldNewPassword = 'New password';
  static const String fieldNewPasswordHint = 'Create a strong password';

  // ── Validation ────────────────────────────────────────────────────────────
  static const String validationEmailRequired = 'Please enter your email';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPasswordRequired = 'Please enter your password';
  static const String validationPasswordTooShort =
      'Password must be at least 8 characters';
  static const String validationPasswordWeak =
      'Password must contain letters and numbers';
  static const String validationPasswordMatch = 'Passwords do not match';
  static const String validationNameRequired = 'Please enter your full name';
  static const String validationNameTooShort = 'Name must be at least 2 characters';

  // ── Password Strength ─────────────────────────────────────────────────────
  static const String strengthWeak = 'Weak';
  static const String strengthFair = 'Fair';
  static const String strengthGood = 'Good';
  static const String strengthStrong = 'Strong';

  // ── Generic ───────────────────────────────────────────────────────────────
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection.';
  static const String comingSoon = 'Coming Soon';
  static const String comingSoonSubtitle =
      'This feature is being built. Stay tuned!';
}
