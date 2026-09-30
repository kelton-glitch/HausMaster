import 'package:dio/dio.dart';

import '../../../core/network/failure.dart';
import '../../../core/token_storage.dart';
import '../domain/manager.dart';

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
    await guardApi(
      () => _dio.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      ),
    );
    return login(email: email, password: password);
  }

  Future<Manager> login({
    required String email,
    required String password,
  }) async {
    final r = await guardApi(
      () => _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      ),
    );
    await _tokens.save(
      access: r.data['access_token'] as String,
      refresh: r.data['refresh_token'] as String,
    );
    return _me();
  }

  /// Restores a session from stored tokens; null if none or expired.
  Future<Manager?> restoreSession() async {
    if (await _tokens.refreshToken == null) return null;
    try {
      return await _me();
    } on Failure {
      return null;
    }
  }

  Future<void> logout() => _tokens.clear();

  Future<Manager> _me() async => Manager.fromJson(
    (await guardApi(() => _dio.get('/auth/me'))).data as Map<String, dynamic>,
  );
}
