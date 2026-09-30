import 'package:dio/dio.dart';

import '../../../core/token_storage.dart';
import '../domain/manager.dart';

/// Locale-independent error code; the UI maps it to a localized message.
enum AuthError { invalidCredentials, emailTaken, invalidData, network, generic }

class AuthException implements Exception {
  AuthException(this.error);
  final AuthError error;
  @override
  String toString() => 'AuthException($error)';
}

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  Future<Manager> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_registerError(e));
    }
    return login(email: email, password: password);
  }

  Future<Manager> login({
    required String email,
    required String password,
  }) async {
    try {
      final r = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _tokens.save(
        access: r.data['access_token'] as String,
        refresh: r.data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw AuthException(
        e.response?.statusCode == 401
            ? AuthError.invalidCredentials
            : _fallback(e),
      );
    }
    return _me();
  }

  /// Restores a session from stored tokens; null if none or expired.
  Future<Manager?> restoreSession() async {
    if (await _tokens.refreshToken == null) return null;
    try {
      return await _me();
    } on DioException {
      return null;
    }
  }

  Future<void> logout() => _tokens.clear();

  Future<Manager> _me() async =>
      Manager.fromJson((await _dio.get('/auth/me')).data);

  AuthError _registerError(DioException e) => switch (e.response?.statusCode) {
    409 => AuthError.emailTaken,
    422 => AuthError.invalidData,
    _ => _fallback(e),
  };

  AuthError _fallback(DioException e) =>
      e.response == null ? AuthError.network : AuthError.generic;
}
