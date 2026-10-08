import 'package:dio/dio.dart';

import '../../../core/network/failure.dart';
import '../domain/tenant.dart';

class TenantsRepository {
  TenantsRepository(this._dio);

  final Dio _dio;

  List<T> _list<T>(Response r, T Function(Map<String, dynamic>) from) =>
      (r.data as List).cast<Map<String, dynamic>>().map(from).toList();

  /// An empty text box means "not provided": send null, never `""`.
  static String? _optional(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  Future<List<Tenant>> tenants(int propertyId) async => _list(
    await guardApi(() => _dio.get('/properties/$propertyId/tenants')),
    Tenant.fromJson,
  );

  Future<void> createTenant(
    int propertyId, {
    required String fullName,
    required String phone,
    String? email,
    String? nationalId,
    String? emergencyContact,
  }) => guardApi(
    () => _dio.post(
      '/properties/$propertyId/tenants',
      data: {
        'full_name': fullName,
        'phone': phone,
        'email': _optional(email),
        'national_id': _optional(nationalId),
        'emergency_contact': _optional(emergencyContact),
      },
    ),
  );

  Future<void> updateTenant(
    int propertyId,
    int tenantId, {
    required String fullName,
    required String phone,
    String? email,
    String? nationalId,
    String? emergencyContact,
  }) => guardApi(
    () => _dio.patch(
      '/properties/$propertyId/tenants/$tenantId',
      data: {
        'full_name': fullName,
        'phone': phone,
        'email': _optional(email),
        'national_id': _optional(nationalId),
        'emergency_contact': _optional(emergencyContact),
      },
    ),
  );

  Future<void> deactivateTenant(int propertyId, int tenantId) => guardApi(
    () => _dio.post('/properties/$propertyId/tenants/$tenantId/deactivate'),
  );
}
