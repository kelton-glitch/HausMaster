import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/format.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../tenants/domain/tenant.dart';
import '../../tenants/presentation/tenants_providers.dart';
import '../../units/domain/unit.dart';
import '../../units/presentation/units_providers.dart';
import '../domain/lease.dart';
import 'lease_form_sheet.dart';
import 'leases_providers.dart';

/// Matches the "lease expiring (D-30)" reminder the backend will send (FR-12).
const _expiryWarningDays = 30;

class LeasesTab extends ConsumerWidget {
  const LeasesTab({
    super.key,
    required this.propertyId,
    required this.canManage,
  });

  final int propertyId;
  final bool canManage;

  Future<void> _openForm(
    BuildContext context, {
    required List<Unit> units,
    required List<UnitType> unitTypes,
    required List<Tenant> tenants,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    // A unit may hold only one open lease, so only vacant ones can be offered.
    final vacant = units.where((u) => u.status == UnitStatus.vacant).toList();
    // Deactivation means "keeps its leases but signs no new one", so an
    // inactive tenant must never reach the form.
    final eligible = tenants.where((t) => t.isActive).toList();
    if (vacant.isEmpty || eligible.isEmpty) {
      showSnack(
        context,
        vacant.isEmpty ? l10n.errNoVacantUnit : l10n.errNoTenantYet,
      );
      return;
    }
    final saved = await showFormSheet(
      context,
      LeaseFormSheet(
        propertyId: propertyId,
        units: vacant,
        unitTypes: unitTypes,
        tenants: eligible,
      ),
    );
    if (saved && context.mounted) showSnack(context, l10n.leaseSaved);
  }

  Future<void> _terminate(
    BuildContext context,
    WidgetRef ref,
    Lease lease,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAction(
      context,
      title: l10n.terminateLeaseTitle,
      body: l10n.terminateLeaseBody,
      confirmLabel: l10n.terminateLease,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(leasesRepositoryProvider)
          .terminateLease(propertyId, lease.id);
      // Occupancy moved too: units and the property counts must follow.
      ref.read(appEventsProvider)
        ..emit(LeasesChanged(propertyId))
        ..emit(UnitsChanged(propertyId));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.leaseTerminated)));
    } catch (e) {
      if (context.mounted) showSnack(context, failureText(context, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final leases = ref.watch(leasesProvider(propertyId));
    final units = ref.watch(unitsProvider(propertyId)).value ?? const <Unit>[];
    final types =
        ref.watch(unitTypesProvider(propertyId)).value ?? const <UnitType>[];
    final tenants =
        ref.watch(tenantsProvider(propertyId)).value ?? const <Tenant>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<Lease>>(
        value: leases,
        onRefresh: () => ref.refresh(leasesProvider(propertyId).future),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.description_outlined,
          title: l10n.noLeasesTitle,
          body: l10n.noLeasesBody,
          action: canManage
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                  onPressed: () => _openForm(
                    context,
                    units: units,
                    unitTypes: types,
                    tenants: tenants,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addLease),
                )
              : null,
        ),
        data: (list) => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            96,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => _LeaseCard(
            lease: list[i],
            onTerminate: canManage
                ? () => _terminate(context, ref, list[i])
                : null,
          ),
        ),
      ),
      floatingActionButton: canManage && (leases.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(
                context,
                units: units,
                unitTypes: types,
                tenants: tenants,
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addLease),
            )
          : null,
    );
  }
}

class _LeaseCard extends StatelessWidget {
  const _LeaseCard({required this.lease, this.onTerminate});

  final Lease lease;
  final VoidCallback? onTerminate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final expiring = lease.expiresWithin(_expiryWarningDays);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minTileHeight: 72,
        leading: const Icon(Icons.description_outlined),
        title: Text('${lease.unitLabel} · ${lease.tenantName}'),
        subtitle: Text(
          '${formatXaf(lease.monthlyRent, locale)} · '
          '${l10n.leaseDate(lease.startDate)} – ${l10n.leaseDate(lease.endDate)}',
        ),
        trailing: expiring || onTerminate == null
            ? (expiring
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.schedule, size: 16),
                          visualDensity: VisualDensity.compact,
                          label: Text(l10n.leaseExpiring),
                          backgroundColor: theme.colorScheme.tertiaryContainer,
                        ),
                        // Renewing an expiring lease is exactly when you need to
                        // terminate it, so the action never disappears.
                        if (onTerminate != null) ...[
                          const SizedBox(width: Spacing.xs),
                          IconButton(
                            tooltip: l10n.terminateLease,
                            icon: const Icon(Icons.logout),
                            onPressed: onTerminate,
                          ),
                        ],
                      ],
                    )
                  : null)
            : IconButton(
                tooltip: l10n.terminateLease,
                icon: const Icon(Icons.logout),
                onPressed: onTerminate,
              ),
      ),
    );
  }
}
