import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keyToken = 'auth_token';
  static const _keyUsername = 'auth_username';
  static const _keyFullName = 'profile_full_name';
  static const _keyEmail = 'profile_email';
  static const _keyPassword = 'auth_password';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  Future<void> saveLogin(String username, String token) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUsername, value: username);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUsername);
  }

  Future<String?> getFullName() async {
    return await _storage.read(key: _keyFullName);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  Future<void> saveProfile(String fullName, String email) async {
    await _storage.write(key: _keyFullName, value: fullName);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyUsername, value: fullName);
  }

  Future<bool> checkPassword(String current) async {
    final stored = await _storage.read(key: _keyPassword);
    if (stored == null || stored.isEmpty) return true;
    return stored == current;
  }

  Future<void> savePassword(String newPassword) async {
    await _storage.write(key: _keyPassword, value: newPassword);
  }
}
