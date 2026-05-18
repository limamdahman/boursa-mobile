import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Client HTTP central. Provider Riverpod injectable partout.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  // Interceptor logging (dev only)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log(
          '→ ${options.method} ${options.uri}',
          name: 'API',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
          '← ${response.statusCode} ${response.requestOptions.uri}',
          name: 'API',
        );
        handler.next(response);
      },
      onError: (e, handler) {
        developer.log(
          '✗ ${e.response?.statusCode ?? "?"} ${e.requestOptions.uri} — ${e.message}',
          name: 'API',
        );
        handler.next(e);
      },
    ),
  );

  return dio;
});
