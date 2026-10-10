import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/format.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/tenant.dart';
import 'tenant_form_sheet.dart';
import 'tenants_providers.dart';

class TenantsTab extends ConsumerWidget {
  const TenantsTab({
    super.key,
    required this.propertyId,
    required this.canManage,
  });

  final int propertyId;
  final bool canManage;

  Future<void> _openForm(BuildContext context, {Tenant? tenant}) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showFormSheet(
      context,
      TenantFormSheet(propertyId: propertyId, initial: tenant),
    );
    if (saved && context.mounted) showSnack(context, l10n.tenantSaved);
  }

  Future<void> _deactivate(
    BuildContext context,
    WidgetRef ref,
    Tenant tenant,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAction(
      context,
      title: l10n.deactivateTenantTitle,
      body: l10n.deactivateTenantBody,
      confirmLabel: l10n.deactivateTenant,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(tenantsRepositoryProvider)
          .deactivateTenant(propertyId, tenant.id);
      ref.read(appEventsProvider).emit(TenantsChanged(propertyId));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.tenantDeactivated)));
    } catch (e) {
      if (context.mounted) showSnack(context, failureText(context, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tenants = ref.watch(tenantsProvider(propertyId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<Tenant>>(
        value: tenants,
        onRefresh: () => ref.refresh(tenantsProvider(propertyId).future),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.people_outline,
          title: l10n.noTenantsTitle,
          body: l10n.noTenantsBody,
          action: canManage
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addTenant),
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
          itemBuilder: (_, i) => _TenantCard(
            tenant: list[i],
            onTap: canManage ? () => _openForm(context, tenant: list[i]) : null,
            onDeactivate: canManage
                ? () => _deactivate(context, ref, list[i])
                : null,
          ),
        ),
      ),
      floatingActionButton: canManage && (tenants.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addTenant),
            )
          : null,
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({required this.tenant, this.onTap, this.onDeactivate});

  final Tenant tenant;
  final VoidCallback? onTap;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minTileHeight: 64,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: tenant.isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : context.appColors.neutralContainer,
          foregroundColor: tenant.isActive
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : context.appColors.neutral,
          child: Text(
            initialsOf(tenant.fullName),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          tenant.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text([tenant.phone, ?tenant.nationalId].join(' · ')),
        // A deactivated tenant is kept for its leases but cannot be
        // deactivated twice.
        trailing: !tenant.isActive
            ? StatusChip(
                icon: Icons.person_off_outlined,
                label: l10n.statusInactive,
              )
            : onDeactivate == null
            ? null
            : IconButton(
                tooltip: l10n.deactivateTenant,
                icon: const Icon(Icons.person_off_outlined),
                onPressed: onDeactivate,
              ),
      ),
    );
  }
}
