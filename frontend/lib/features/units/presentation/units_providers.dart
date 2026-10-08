import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/units_repository.dart';
import '../domain/unit.dart';

final unitsRepositoryProvider = Provider(
  (ref) => UnitsRepository(ref.watch(dioProvider)),
);

final unitsProvider = FutureProvider.autoDispose.family<List<Unit>, int>((
  ref,
  propertyId,
) {
  ref.watch(authControllerProvider.select((s) => s.value?.id));
  ref.refreshOn<UnitsChanged>(where: (e) => e.propertyId == propertyId);
  // Signing or ending a lease moves occupancy, which this list displays.
  ref.refreshOn<LeasesChanged>(where: (e) => e.propertyId == propertyId);
  return ref.watch(unitsRepositoryProvider).units(propertyId);
});

final unitTypesProvider = FutureProvider.autoDispose
    .family<List<UnitType>, int>((ref, propertyId) {
      ref.watch(authControllerProvider.select((s) => s.value?.id));
      ref.refreshOn<UnitsChanged>(where: (e) => e.propertyId == propertyId);
      return ref.watch(unitsRepositoryProvider).unitTypes(propertyId);
    });
