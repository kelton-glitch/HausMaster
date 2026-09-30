import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/properties_repository.dart';
import '../domain/property.dart';

final propertiesRepositoryProvider = Provider(
  (ref) => PropertiesRepository(ref.watch(dioProvider)),
);

/// The signed-in manager's id, or null when signed out. Data providers watch
/// this so signing out (or switching user) never leaves stale data behind.
final _userIdProvider = Provider<int?>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.value?.id)),
);

final propertiesProvider = FutureProvider<List<Property>>((ref) async {
  final userId = ref.watch(_userIdProvider);
  // Refresh when a property changes or when units change (occupancy counts).
  ref.refreshOn<PropertyChanged>();
  ref.refreshOn<UnitsChanged>();
  if (userId == null) return const [];
  return ref.watch(propertiesRepositoryProvider).list();
});

final propertyProvider = FutureProvider.autoDispose.family<Property, int>((
  ref,
  id,
) {
  ref.watch(_userIdProvider);
  ref.refreshOn<PropertyChanged>(
    where: (e) => e.propertyId == null || e.propertyId == id,
  );
  ref.refreshOn<UnitsChanged>(where: (e) => e.propertyId == id);
  return ref.watch(propertiesRepositoryProvider).get(id);
});

final accessProvider = FutureProvider.autoDispose
    .family<List<AccessEntry>, int>((ref, id) {
      ref.watch(_userIdProvider);
      ref.refreshOn<AccessChanged>(where: (e) => e.propertyId == id);
      return ref.watch(propertiesRepositoryProvider).listAccess(id);
    });
