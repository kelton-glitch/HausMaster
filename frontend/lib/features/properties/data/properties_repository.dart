import 'package:dio/dio.dart';

import '../../../core/network/failure.dart';
import '../domain/policy.dart';
import '../domain/property.dart';

class PropertiesRepository {
  PropertiesRepository(this._dio);

  final Dio _dio;

  List<T> _list<T>(Response r, T Function(Map<String, dynamic>) from) =>
      (r.data as List).cast<Map<String, dynamic>>().map(from).toList();

  Future<List<Property>> list() async =>
      _list(await guardApi(() => _dio.get('/properties')), Property.fromJson);

  Future<Property> get(int id) async => Property.fromJson(
    (await guardApi(() => _dio.get('/properties/$id'))).data
        as Map<String, dynamic>,
  );

  Future<Property> create({
    required String name,
    String? address,
    String? city,
  }) async => Property.fromJson(
    (await guardApi(
          () => _dio.post(
            '/properties',
            data: {'name': name, 'address': address, 'city': city},
          ),
        )).data
        as Map<String, dynamic>,
  );

  Future<Property> update(
    int id, {
    required String name,
    String? address,
    String? city,
  }) async => Property.fromJson(
    (await guardApi(
          () => _dio.patch(
            '/properties/$id',
            data: {'name': name, 'address': address, 'city': city},
          ),
        )).data
        as Map<String, dynamic>,
  );

  Future<void> deactivate(int id) =>
      guardApi(() => _dio.post('/properties/$id/deactivate'));

  Future<List<AccessEntry>> listAccess(int id) async => _list(
    await guardApi(() => _dio.get('/properties/$id/managers')),
    AccessEntry.fromJson,
  );

  Future<void> grantAccess(
    int id, {
    required String email,
    required Role role,
  }) => guardApi(
    () => _dio.post(
      '/properties/$id/managers',
      data: {'email': email, 'role': role.value},
    ),
  );

  Future<void> revokeAccess(int id, int managerId) =>
      guardApi(() => _dio.delete('/properties/$id/managers/$managerId'));
}
