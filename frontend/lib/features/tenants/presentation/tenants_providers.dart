import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/tenants_repository.dart';
import '../domain/tenant.dart';

final tenantsRepositoryProvider = Provider(
  (ref) => TenantsRepository(ref.watch(dioProvider)),
);

final tenantsProvider = FutureProvider.autoDispose.family<List<Tenant>, int>((
  ref,
  propertyId,
) {
  ref.watch(authControllerProvider.select((s) => s.value?.id));
  ref.refreshOn<TenantsChanged>(where: (e) => e.propertyId == propertyId);
  return ref.watch(tenantsRepositoryProvider).tenants(propertyId);
});
