import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'token_storage.dart';
import 'user_model.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Demande l'envoi d'un OTP au numéro fourni.
  /// Retourne le numéro normalisé tel que reçu par le backend.
  Future<String> requestOtp(String phone) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/send',
        data: {'phone': phone},
      );
      final data = response.data;
      return (data?['phone'] as String?) ?? phone;
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Vérifie l'OTP et retourne le token + user.
  Future<({String token, User user})> verifyOtp(
    String phone,
    String code, {
    String? name,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {
          'phone': phone,
          'code': code,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );
      final data = response.data!;
      final token = data['token'] as String;
      final userJson = (data['user'] ?? data['data']) as Map<String, dynamic>;

      await _tokenStorage.save(token);

      return (token: token, user: User.fromJson(userJson));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Met à jour le profil (PUT /me) et retourne le user frais.
  Future<User> updateProfile(
      {String? name, String? email, String? language}) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (language != null) payload['language'] = language;
    final res = await _dio.put<Map<String, dynamic>>('/me', data: payload);
    final userJson = res.data?['user'] as Map<String, dynamic>?;
    return User.fromJson(userJson ?? <String, dynamic>{});
  }

  /// Upload l'avatar (POST /me/avatar) et retourne l'URL.
  Future<String?> uploadAvatar(List<int> bytes, String filename) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post<Map<String, dynamic>>('/me/avatar', data: form);
    return res.data?['avatar_url'] as String?;
  }

  /// Pas d'endpoint /auth/me côté backend — on retourne null si on a juste
  /// le token. L'app demandera re-auth si nécessaire.
  Future<User?> me() async => null;

  /// Déconnecte l'utilisateur (suppression token local + appel logout).
  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } catch (_) {
      // Si le serveur ne répond pas, on déconnecte quand même côté client
    }
    await _tokenStorage.clear();
  }

  Future<String?> readToken() => _tokenStorage.read();

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return e.message ?? 'Erreur réseau';
  }
}

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});
