import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../../features/auth/data/token_storage.dart';

class ApiClient {
  static Dio build(TokenStorage tokenStorage) {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // 1. Logging (debug uniquement)
    if (kDebugMode) {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[API] → ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (err, handler) {
          debugPrint('[API] ✗ ${err.response?.statusCode ?? 0} ${err.requestOptions.uri} — ${err.message}');
          handler.next(err);
        },
      ));
    }

    // 2. Auth interceptor — injecte le Bearer token sur chaque requête
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        // Si 401, on supprime le token (sera réinitialisé à la prochaine auth)
        if (err.response?.statusCode == 401) {
          await tokenStorage.clear();
        }
        handler.next(err);
      },
    ));

    return dio;
  }
}

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<Dio>((ref) {
  return ApiClient.build(ref.watch(tokenStorageProvider));
});
