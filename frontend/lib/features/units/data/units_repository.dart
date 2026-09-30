import 'package:dio/dio.dart';

import '../../../core/network/failure.dart';
import '../domain/unit.dart';

class UnitsRepository {
  UnitsRepository(this._dio);

  final Dio _dio;

  List<T> _list<T>(Response r, T Function(Map<String, dynamic>) from) =>
      (r.data as List).cast<Map<String, dynamic>>().map(from).toList();

  Future<List<Unit>> units(int propertyId) async => _list(
    await guardApi(() => _dio.get('/properties/$propertyId/units')),
    Unit.fromJson,
  );

  Future<List<UnitType>> unitTypes(int propertyId) async => _list(
    await guardApi(() => _dio.get('/properties/$propertyId/unit-types')),
    UnitType.fromJson,
  );

  Future<void> createUnit(
    int propertyId, {
    required String label,
    required int unitTypeId,
  }) => guardApi(
    () => _dio.post(
      '/properties/$propertyId/units',
      data: {'label': label, 'unit_type_id': unitTypeId},
    ),
  );

  Future<void> updateUnit(
    int propertyId,
    int unitId, {
    required String label,
    required int unitTypeId,
  }) => guardApi(
    () => _dio.patch(
      '/properties/$propertyId/units/$unitId',
      data: {'label': label, 'unit_type_id': unitTypeId},
    ),
  );

  Future<void> createUnitType(
    int propertyId, {
    required String name,
    required int roomCount,
    required int baseRent,
  }) => guardApi(
    () => _dio.post(
      '/properties/$propertyId/unit-types',
      data: {'name': name, 'room_count': roomCount, 'base_rent': baseRent},
    ),
  );

  Future<void> updateUnitType(
    int propertyId,
    int unitTypeId, {
    required String name,
    required int roomCount,
    required int baseRent,
  }) => guardApi(
    () => _dio.patch(
      '/properties/$propertyId/unit-types/$unitTypeId',
      data: {'name': name, 'room_count': roomCount, 'base_rent': baseRent},
    ),
  );

  Future<void> deactivateUnitType(int propertyId, int unitTypeId) => guardApi(
    () =>
        _dio.post('/properties/$propertyId/unit-types/$unitTypeId/deactivate'),
  );
}
