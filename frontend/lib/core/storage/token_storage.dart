// lib/core/storage/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey    = 'user_role';
  static const _userIdKey  = 'user_id';

  static Future<void> saveSession({
    required String access,
    required String refresh,
    required String role,
    required int userId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey,  value: access),
      _storage.write(key: _refreshKey, value: refresh),
      _storage.write(key: _roleKey,    value: role),
      _storage.write(key: _userIdKey,  value: userId.toString()),
    ]);
  }

  static Future<void> updateAccessToken(String access) =>
      _storage.write(key: _accessKey, value: access);

  static Future<String?> getAccessToken()  => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  static Future<String?> getRole()         => _storage.read(key: _roleKey);
  static Future<int?> getUserId() async {
    final v = await _storage.read(key: _userIdKey);
    return v != null ? int.tryParse(v) : null;
  }

  /// Returns true if a session exists (user was previously logged in).
  static Future<bool> hasSession() async {
    final token = await _storage.read(key: _accessKey);
    return token != null;
  }

  static Future<void> clear() => _storage.deleteAll();
}