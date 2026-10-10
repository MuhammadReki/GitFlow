import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const _tokenKey = 'github_access_token';
  static const _usernameKey = 'github_username';
  static const _avatarKey = 'github_avatar_url';

  /// Simpen token + info user
  static Future<void> saveToken({
    required String token,
    String? username,
    String? avatarUrl,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    if (username != null) {
      await _storage.write(key: _usernameKey, value: username);
    }
    if (avatarUrl != null) {
      await _storage.write(key: _avatarKey, value: avatarUrl);
    }
  }

  /// Ambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Ambil username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Ambil avatar URL
  static Future<String?> getAvatarUrl() async {
    return await _storage.read(key: _avatarKey);
  }

  /// Cek udah login apa belum
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout — hapus semua
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}