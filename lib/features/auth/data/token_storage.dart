import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stocke le Bearer token Sanctum.
///
/// Sur mobile (Android/iOS) → flutter_secure_storage (KeyStore/Keychain).
/// Sur Web → SharedPreferences (localStorage), car secure_storage_web demande
/// une clé d'encryption fournie par l'utilisateur, complexe à gérer en dev.
abstract class TokenStorage {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();

  factory TokenStorage() {
    if (kIsWeb) {
      return _WebTokenStorage();
    }
    return _SecureTokenStorage();
  }
}

class _SecureTokenStorage implements TokenStorage {
  static const _key = 'boursa.auth.token';
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> save(String token) => _storage.write(key: _key, value: token);

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class _WebTokenStorage implements TokenStorage {
  static const _key = 'boursa.auth.token';

  @override
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  @override
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
