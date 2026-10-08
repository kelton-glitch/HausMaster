import 'package:dio/dio.dart';

import '../../../core/network/failure.dart';
import '../domain/lease.dart';

class LeasesRepository {
  LeasesRepository(this._dio);

  final Dio _dio;

  List<T> _list<T>(Response r, T Function(Map<String, dynamic>) from) =>
      (r.data as List).cast<Map<String, dynamic>>().map(from).toList();

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<List<Lease>> leases(
    int propertyId, {
    bool includeTerminated = false,
  }) async => _list(
    await guardApi(
      () => _dio.get(
        '/properties/$propertyId/leases',
        queryParameters: {if (includeTerminated) 'include_terminated': true},
      ),
    ),
    Lease.fromJson,
  );

  /// Rent and dates are locked at signing, so there is no update: a change of
  /// rent means terminating this lease and signing a new one.
  Future<void> createLease(
    int propertyId, {
    required int unitId,
    required int tenantId,
    required DateTime startDate,
    required DateTime endDate,
    required int monthlyRent,
  }) => guardApi(
    () => _dio.post(
      '/properties/$propertyId/leases',
      data: {
        'unit_id': unitId,
        'tenant_id': tenantId,
        'start_date': _date(startDate),
        'end_date': _date(endDate),
        'monthly_rent': monthlyRent,
      },
    ),
  );

  Future<void> terminateLease(int propertyId, int leaseId) => guardApi(
    () => _dio.post('/properties/$propertyId/leases/$leaseId/terminate'),
  );
}
