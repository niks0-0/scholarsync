/// Validates form fields for ScholarSync.
abstract final class AppValidators {
  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  /// Validates a new password (same rules as [password]).
  static String? newPassword(String? value) => password(value);

  /// Validates that [confirmValue] matches [originalValue].
  static String? Function(String?) confirmPassword(String? originalValue) {
    return (String? confirmValue) {
      if (confirmValue == null || confirmValue.isEmpty) {
        return 'Please confirm your password';
      }
      if (confirmValue != originalValue) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // ── Name ──────────────────────────────────────────────────────────────────
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // ── Password Strength (0–4) ────────────────────────────────────────────────
  /// Returns a strength score from 0 (empty) to 4 (strong).
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    int score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    return score.clamp(0, 4);
  }
}

