// lib/features/auth/data/models/auth_response.dart

class AuthResponse {
  final String access;
  final String refresh;
  final String role;   // 'candidat' | 'recruteur'
  final int userId;

  const AuthResponse({
    required this.access,
    required this.refresh,
    required this.role,
    required this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        access:  json['access']  as String,
        refresh: json['refresh'] as String,
        role:    json['role']    as String,
        // Backend returns { "user": { "id": 1, ... } }, not a top-level "user_id"
        userId:  (json['user'] as Map<String, dynamic>)['id'] as int,
      );
}