// lib/core/storage/token_storage.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'web_storage_impl.dart';

class TokenStorage {
  // Mobile/desktop: encrypted secure storage
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessKey      = 'access';
  static const _refreshKey     = 'refresh';
  static const _roleKey        = 'user_role';
  static const _userIdKey      = 'user_id';
  static const _googleUserKey  = 'is_google_user';

  // ── Internal read/write helpers (web → SharedPreferences, mobile → secure) ──

  static Future<String?> _read(String key) async {
    if (kIsWeb) return platformRead(key);
    return _secure.read(key: key);
  }

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) { platformWrite(key, value); return; }
    await _secure.write(key: key, value: value);
  }

  static Future<void> _clearAll() async {
    if (kIsWeb) { platformClear(); return; }
    await _secure.deleteAll();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  static Future<void> saveSession({
    required String access,
    required String refresh,
    required String role,
    required int userId,
    bool isGoogleUser = false,
  }) async {
    await Future.wait([
      _write(_accessKey,     access),
      _write(_refreshKey,    refresh),
      _write(_roleKey,       role),
      _write(_userIdKey,     userId.toString()),
      _write(_googleUserKey, isGoogleUser.toString()),
    ]);
  }

  static Future<void> updateAccessToken(String access) =>
      _write(_accessKey, access);

  static Future<String?> getAccessToken()  => _read(_accessKey);
  static Future<String?> getRefreshToken() => _read(_refreshKey);
  static Future<String?> getRole()         => _read(_roleKey);

  static Future<int?> getUserId() async {
    final v = await _read(_userIdKey);
    return v != null ? int.tryParse(v) : null;
  }

  static Future<bool> getIsGoogleUser() async {
    final val = await _read(_googleUserKey);
    return val == 'true';
  }

  static Future<bool> hasSession() async {
    final token = await _read(_accessKey);
    return token != null;
  }

  static Future<void> clear() => _clearAll();

  static Future<void> saveIsGoogleUser(bool value) =>
      _write(_googleUserKey, value.toString());
}
