import 'dart:async';

import 'package:dio/dio.dart';

import 'config.dart';
import 'token_storage.dart';

/// Dio client that injects the Bearer token and transparently refreshes it on 401.
Dio createApiClient(TokenStorage tokens, {void Function()? onSessionExpired}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  // Separate instance without interceptors so refreshing can't recurse.
  final bare = Dio(BaseOptions(baseUrl: apiBaseUrl));
  Future<bool>? inFlight; // single-flight: concurrent 401s share one refresh

  Future<bool> refresh() async {
    final refreshToken = await tokens.refreshToken;
    if (refreshToken == null) return false;
    try {
      final r = await bare.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      await tokens.save(
        access: r.data['access_token'] as String,
        refresh: r.data['refresh_token'] as String,
      );
      return true;
    } on DioException {
      return false;
    }
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokens.accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (err, handler) async {
        final req = err.requestOptions;
        final isAuthCall =
            req.path.startsWith('/auth/login') ||
            req.path.startsWith('/auth/register') ||
            req.path.startsWith('/auth/refresh');
        if (err.response?.statusCode != 401 ||
            isAuthCall ||
            req.extra['retried'] == true) {
          return handler.next(err);
        }
        final ok = await (inFlight ??= refresh().whenComplete(
          () => inFlight = null,
        ));
        if (!ok) {
          await tokens.clear();
          onSessionExpired?.call();
          return handler.next(err);
        }
        req.extra['retried'] = true;
        req.headers['Authorization'] = 'Bearer ${await tokens.accessToken}';
        try {
          handler.resolve(await dio.fetch(req));
        } on DioException catch (e) {
          handler.next(e);
        }
      },
    ),
  );
  return dio;
}
