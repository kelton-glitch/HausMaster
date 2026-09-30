import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/core/network/failure.dart';
import 'package:hausmaster/core/provider_retry.dart';
import 'package:hausmaster/features/auth/domain/manager.dart';
import 'package:hausmaster/features/auth/presentation/auth_controller.dart';
import 'package:hausmaster/features/properties/data/properties_repository.dart';
import 'package:hausmaster/features/properties/domain/policy.dart';
import 'package:hausmaster/features/properties/domain/property.dart';
import 'package:hausmaster/features/properties/presentation/properties_providers.dart';
import 'package:hausmaster/features/units/data/units_repository.dart';
import 'package:hausmaster/features/units/domain/unit.dart';
import 'package:hausmaster/features/units/presentation/units_providers.dart';
import 'package:hausmaster/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Prop {
  _Prop(this.id, this.name, {this.address, this.city});
  final int id;
  String name;
  String? address;
  String? city;
  bool active = true;
  final types = <UnitType>[];
  final units = <Unit>[];
  final access = <AccessEntry>[];
}

/// In-memory stand-in for the whole API. Both fake repositories read and write
/// it, so cross-feature effects (unit counts on a property) behave like the
/// real server.
class FakeBackend {
  FakeBackend({this.role = Role.owner});

  Role role;
  int _id = 0;
  final _props = <_Prop>[];

  /// If set, the next `properties.list()` call throws this, once.
  Failure? failNextList;

  /// Artificial latency for `properties.list()`, to observe loading states.
  Duration listDelay = Duration.zero;

  int nextId() => ++_id;

  void seedProperty(
    String name, {
    String? city,
    bool withType = false,
    bool withUnit = false,
  }) {
    final p = _Prop(nextId(), name, city: city);
    p.access.add(
      const AccessEntry(
        managerId: 1,
        fullName: 'Ada Njoh',
        email: 'ada@example.com',
        role: Role.owner,
      ),
    );
    if (withType || withUnit) {
      p.types.add(
        UnitType(
          id: nextId(),
          propertyId: p.id,
          name: 'Studio',
          roomCount: 1,
          baseRent: 85000,
          isActive: true,
        ),
      );
    }
    if (withUnit) {
      p.units.add(
        Unit(
          id: nextId(),
          propertyId: p.id,
          label: 'A1',
          unitTypeId: p.types.first.id,
          unitTypeName: 'Studio',
          status: UnitStatus.vacant,
        ),
      );
    }
    _props.add(p);
  }

  _Prop _p(int id) => _props.firstWhere((p) => p.id == id);

  Property _view(_Prop p) => Property(
    id: p.id,
    name: p.name,
    address: p.address,
    city: p.city,
    isActive: p.active,
    role: role,
    unitCount: p.units.length,
    occupiedCount: p.units.where((u) => u.status == UnitStatus.occupied).length,
  );
}

class FakePropertiesRepository implements PropertiesRepository {
  FakePropertiesRepository(this.b);
  final FakeBackend b;

  @override
  Future<List<Property>> list() async {
    if (b.listDelay > Duration.zero) await Future<void>.delayed(b.listDelay);
    final f = b.failNextList;
    if (f != null) {
      b.failNextList = null;
      throw f;
    }
    return [for (final p in b._props.where((p) => p.active)) b._view(p)];
  }

  @override
  Future<Property> get(int id) async => b._view(b._p(id));

  @override
  Future<Property> create({
    required String name,
    String? address,
    String? city,
  }) async {
    final p = _Prop(b.nextId(), name, address: address, city: city);
    p.access.add(
      const AccessEntry(
        managerId: 1,
        fullName: 'Ada Njoh',
        email: 'ada@example.com',
        role: Role.owner,
      ),
    );
    b._props.add(p);
    return b._view(p);
  }

  @override
  Future<Property> update(
    int id, {
    required String name,
    String? address,
    String? city,
  }) async {
    final p = b._p(id)
      ..name = name
      ..address = address
      ..city = city;
    return b._view(p);
  }

  @override
  Future<void> deactivate(int id) async => b._p(id).active = false;

  @override
  Future<List<AccessEntry>> listAccess(int id) async =>
      List.of(b._p(id).access);

  @override
  Future<void> grantAccess(
    int id, {
    required String email,
    required Role role,
  }) async {
    final p = b._p(id);
    if (p.access.any((a) => a.email == email)) {
      throw const Failure(code: 'already_has_access', statusCode: 409);
    }
    p.access.add(
      AccessEntry(
        managerId: b.nextId(),
        fullName: email.split('@').first,
        email: email,
        role: role,
      ),
    );
  }

  @override
  Future<void> revokeAccess(int id, int managerId) async =>
      b._p(id).access.removeWhere((a) => a.managerId == managerId);
}

class FakeUnitsRepository implements UnitsRepository {
  FakeUnitsRepository(this.b);
  final FakeBackend b;

  @override
  Future<List<Unit>> units(int propertyId) async =>
      List.of(b._p(propertyId).units);

  @override
  Future<List<UnitType>> unitTypes(int propertyId) async =>
      b._p(propertyId).types.where((t) => t.isActive).toList();

  @override
  Future<void> createUnit(
    int propertyId, {
    required String label,
    required int unitTypeId,
  }) async {
    final p = b._p(propertyId);
    if (p.units.any((u) => u.label.toLowerCase() == label.toLowerCase())) {
      throw const Failure(code: 'unit_label_taken', statusCode: 409);
    }
    final type = p.types.firstWhere((t) => t.id == unitTypeId);
    p.units.add(
      Unit(
        id: b.nextId(),
        propertyId: propertyId,
        label: label,
        unitTypeId: type.id,
        unitTypeName: type.name,
        status: UnitStatus.vacant,
      ),
    );
  }

  @override
  Future<void> updateUnit(
    int propertyId,
    int unitId, {
    required String label,
    required int unitTypeId,
  }) async {}

  @override
  Future<void> createUnitType(
    int propertyId, {
    required String name,
    required int roomCount,
    required int baseRent,
  }) async {
    b
        ._p(propertyId)
        .types
        .add(
          UnitType(
            id: b.nextId(),
            propertyId: propertyId,
            name: name,
            roomCount: roomCount,
            baseRent: baseRent,
            isActive: true,
          ),
        );
  }

  @override
  Future<void> updateUnitType(
    int propertyId,
    int unitTypeId, {
    required String name,
    required int roomCount,
    required int baseRent,
  }) async {}

  @override
  Future<void> deactivateUnitType(int propertyId, int unitTypeId) async {}
}

class SignedInAda extends AuthController {
  @override
  Future<Manager?> build() async =>
      const Manager(id: 1, fullName: 'Ada Njoh', email: 'ada@example.com');

  @override
  Future<void> logout() async => state = const AsyncData(null);
}

class SignedOut extends AuthController {
  @override
  Future<Manager?> build() async => null;
}

/// Pumps the whole app on a phone-sized window, French device by default,
/// wired to [backend] (an empty one if omitted).
Future<FakeBackend> pumpApp(
  WidgetTester tester, {
  AuthController Function() auth = SignedInAda.new,
  FakeBackend? backend,
  Locale locale = const Locale('fr'),
  bool settle = true,
}) async {
  final be = backend ?? FakeBackend();
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      retry: noAutoRetry,
      overrides: [
        authControllerProvider.overrideWith(auth),
        propertiesRepositoryProvider.overrideWithValue(
          FakePropertiesRepository(be),
        ),
        unitsRepositoryProvider.overrideWithValue(FakeUnitsRepository(be)),
      ],
      child: const HausMasterApp(),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return be;
}
