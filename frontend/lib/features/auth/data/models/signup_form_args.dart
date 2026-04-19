// lib/features/auth/data/models/signup_form_args.dart

/// Encapsulates the route arguments passed to [SignupFormScreen].
///
/// Using a dedicated class instead of a raw String or Map makes
/// the contract between screens explicit and compiler-checked.
class SignupFormArgs {
  /// 'candidat' or 'recruteur'
  final String role;

  /// 'email' (normal signup) or 'google' (Google OAuth)
  final String method;

  const SignupFormArgs({
    required this.role,
    this.method = 'email',
  });

  bool get isGoogleSignUp => method == 'google';
}
