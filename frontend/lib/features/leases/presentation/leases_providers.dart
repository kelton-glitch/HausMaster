import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/leases_repository.dart';
import '../domain/lease.dart';

final leasesRepositoryProvider = Provider(
  (ref) => LeasesRepository(ref.watch(dioProvider)),
);

final leasesProvider = FutureProvider.autoDispose.family<List<Lease>, int>((
  ref,
  propertyId,
) {
  ref.watch(authControllerProvider.select((s) => s.value?.id));
  ref.refreshOn<LeasesChanged>(where: (e) => e.propertyId == propertyId);
  return ref.watch(leasesRepositoryProvider).leases(propertyId);
});
