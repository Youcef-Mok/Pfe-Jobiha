// lib/core/api/api_client.dart

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Singleton Dio instance.
/// - Attaches Bearer token to every request automatically.
/// - On 401, silently refreshes the token and retries once.
/// - On refresh failure, clears the session (forces re-login).
class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.100.9:8000/api/v1', //for my phone linking (same network as pc)
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(_AuthInterceptor()); 

  static Dio get instance => _dio;
}

// ── Interceptor ───────────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  /// Attach access token before every request.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// On 401 — try a silent refresh, then retry the original request.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request with the new token.
        try {
          final newToken = await TokenStorage.getAccessToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final response = await ApiClient.instance.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          // Retry also failed — fall through to clear session.
        }
      }
      // Both the original request and the refresh failed.
      await TokenStorage.clear();
      // Propagate a clean error so the app can redirect to login.
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Session expirée. Veuillez vous reconnecter.',
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
    }
    handler.next(err);
  }

  /// Use a fresh Dio (no interceptor) to avoid an infinite 401 loop.
  Future<bool> _tryRefreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await Dio().post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refresh},
      );
      final newAccess = response.data['access'] as String;
      await TokenStorage.updateAccessToken(newAccess);
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── Error helper (used by repositories + screens) ────────────────────────────

/// Parses DRF error responses into a human-readable string.
/// Handles both {"detail": "..."} and {"field": ["msg", ...]} formats.
String parseDioError(DioException e) {
  final data = e.response?.data;
  if (data == null) return 'Erreur réseau. Vérifiez votre connexion.';

  if (data is Map) {
    if (data.containsKey('detail')) return data['detail'] as String;

    // Field-level validation errors
    final messages = <String>[];
    data.forEach((key, value) {
      if (value is List) {
        messages.add('$key: ${value.join(", ")}');
      }
    });
    if (messages.isNotEmpty) return messages.join('\n');
  }
  return 'Erreur inconnue (${e.response?.statusCode})';
}