// lib/features/auth/data/users_repository.dart

import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/user_model.dart';

class UsersRepository {
  final Dio _dio = ApiClient.instance;

  /// Fetch all users with optional role filter
  /// role: 'candidat', 'recruteur', or null for all users
  Future<List<UserModel>> getUsers({String? role}) async {
    final response = await _dio.get(
      ApiEndpoints.users,
      queryParameters: role != null ? {'role': role} : null,
    );
    
    final results = response.data['results'] as List;
    return results.map((json) => UserModel.fromJson(json)).toList();
  }
}
