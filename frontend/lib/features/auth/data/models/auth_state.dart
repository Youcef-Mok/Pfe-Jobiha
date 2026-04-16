// lib/features/auth/data/models/auth_state.dart

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? role;       // 'candidat' | 'recruteur'
  final int? userId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.userId,
    this.errorMessage,
  });

  bool get isLoading       => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Use sentinel [_clear] to explicitly null out optional fields.
  /// Example: copyWith(role: AuthState.clear) resets role to null.
  static const String _clear = '__clear__';

  AuthState copyWith({
    AuthStatus? status,
    Object? role       = _clear,
    Object? userId     = _clear,
    Object? errorMessage = _clear,
  }) =>
      AuthState(
        status:       status ?? this.status,
        role:         role       == _clear ? this.role         : role       as String?,
        userId:       userId     == _clear ? this.userId       : userId     as int?,
        errorMessage: errorMessage == _clear ? this.errorMessage : errorMessage as String?,
      );

  /// Convenience: produce a fully-reset unauthenticated state.
  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}