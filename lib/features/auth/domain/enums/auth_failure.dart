/// Typed authentication failure — maps Firebase error codes to app-level failures.
///
/// Use this instead of catching raw [FirebaseAuthException] in the UI.
enum AuthFailure {
  /// User cancelled the sign-in flow (e.g. closed Google picker).
  cancelled,

  /// No internet connection available.
  networkError,

  /// The email/password combination is incorrect.
  invalidCredential,

  /// The email address is not associated with any account.
  userNotFound,

  /// The account exists but signed up with a different provider.
  accountExistsWithDifferentCredential,

  /// The account has been disabled by an administrator.
  userDisabled,

  /// The email address is already in use by another account.
  emailAlreadyInUse,

  /// The provided email address is not valid.
  invalidEmail,

  /// The password does not meet minimum requirements.
  weakPassword,

  /// Too many failed attempts — try again later.
  tooManyRequests,

  /// The sign-in provider (e.g. Google) is disabled in Firebase Console.
  operationNotAllowed,

  /// The web domain is not in the list of authorized domains in Firebase Console.
  unauthorizedDomain,

  /// An unknown or unhandled error occurred.
  unknown;

  /// Human-readable message for this failure.
  String get message {
    switch (this) {
      case AuthFailure.cancelled:
        return 'Sign-in was cancelled.';
      case AuthFailure.networkError:
        return 'No internet connection. Please try again.';
      case AuthFailure.invalidCredential:
        return 'Invalid email or password.';
      case AuthFailure.userNotFound:
        return 'No account found with this email.';
      case AuthFailure.accountExistsWithDifferentCredential:
        return 'An account already exists with a different sign-in method.';
      case AuthFailure.userDisabled:
        return 'This account has been disabled. Contact support.';
      case AuthFailure.emailAlreadyInUse:
        return 'An account already exists with this email.';
      case AuthFailure.invalidEmail:
        return 'Please enter a valid email address.';
      case AuthFailure.weakPassword:
        return 'Password must be at least 8 characters with letters and numbers.';
      case AuthFailure.tooManyRequests:
        return 'Too many attempts. Please wait a moment and try again.';
      case AuthFailure.operationNotAllowed:
        return 'Google Sign-In is not enabled in Firebase Console. Please enable Google under Authentication > Sign-in method.';
      case AuthFailure.unauthorizedDomain:
        return 'This domain is not authorized in Firebase Console under Authentication > Settings > Authorized domains.';
      case AuthFailure.unknown:
        return 'Something went wrong. Please check your Firebase Console settings.';
    }
  }
}

/// Wraps an [AuthFailure] as an exception for repository error propagation.
class AuthException implements Exception {
  const AuthException(
    this.failure, {
    this.originalError,
    this.customMessage,
  });

  final AuthFailure failure;
  final Object? originalError;
  final String? customMessage;

  String get message => customMessage ?? failure.message;

  @override
  String toString() => 'AuthException(${failure.name}): $message';
}
