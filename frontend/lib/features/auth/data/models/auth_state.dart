// lib/features/auth/data/models/auth_state.dart

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpRequired,
  pendingRoleSelection,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? role;       // 'candidat' | 'recruteur'
  final int? userId;
  final String? email;      // kept for OTP verification screen
  final String? errorMessage;
  final Map<String, String>? pendingGoogleUser; // {email, nom, prenom}

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.userId,
    this.email,
    this.errorMessage,
    this.pendingGoogleUser,
  });

  bool get isLoading       => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Use sentinel [_clear] to explicitly null out optional fields.
  /// Example: copyWith(role: AuthState.clear) resets role to null.
  static const String _clear = '__clear__';

  AuthState copyWith({
    AuthStatus? status,
    Object? role               = _clear,
    Object? userId             = _clear,
    Object? email              = _clear,
    Object? errorMessage       = _clear,
    Object? pendingGoogleUser  = _clear,
  }) =>
      AuthState(
        status:            status ?? this.status,
        role:              role              == _clear ? this.role              : role              as String?,
        userId:            userId            == _clear ? this.userId            : userId            as int?,
        email:             email             == _clear ? this.email             : email             as String?,
        errorMessage:      errorMessage      == _clear ? this.errorMessage      : errorMessage      as String?,
        pendingGoogleUser: pendingGoogleUser == _clear ? this.pendingGoogleUser : pendingGoogleUser as Map<String, String>?,
      );

  /// Convenience: produce a fully-reset unauthenticated state.
  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}