// lib/core/api/api_client.dart

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(_AuthInterceptor());

  static Dio get instance => _dio;
}

class _AuthInterceptor extends QueuedInterceptor {
  Future<bool>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    assert(() {
      // ignore: avoid_print
      print('[ApiClient] ${options.method.toUpperCase()} ${options.uri}');
      return true;
    }());

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;

    if (status == 403) {
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error:
              'Acces refuse. Vous n\'avez pas les droits necessaires pour cette action.',
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
    }

    if (status == 401) {
      final alreadyRetried = err.requestOptions.extra['__retried__'] == true;
      if (alreadyRetried || _isAuthRoute(err.requestOptions.path)) {
        return handler.next(err);
      }

      final refreshed = await _refreshOnce();
      if (refreshed) {
        try {
          final newToken = await TokenStorage.getAccessToken();
          final opts = err.requestOptions;
          opts.extra['__retried__'] = true;
          if (newToken != null && newToken.isNotEmpty) {
            opts.headers['Authorization'] = 'Bearer $newToken';
          }
          final response = await ApiClient.instance.fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // fall through
        }
      }

      final hadSession = await TokenStorage.hasSession();
      if (hadSession) {
        await TokenStorage.clear();
      }
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Session expiree. Veuillez vous reconnecter.',
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
    }

    handler.next(err);
  }

  bool _isAuthRoute(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/token/refresh') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/google');
  }

  Future<bool> _refreshOnce() async {
    if (_refreshFuture != null) return _refreshFuture!;
    _refreshFuture = _tryRefreshToken();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

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

String parseDioError(DioException e) {
  final data = e.response?.data;
  if (data == null) return 'Erreur reseau. Verifiez votre connexion.';

  if (data is Map) {
    if (data.containsKey('detail')) return data['detail'] as String;
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
