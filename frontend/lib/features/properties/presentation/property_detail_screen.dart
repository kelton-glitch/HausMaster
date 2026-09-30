import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../units/presentation/unit_types_tab.dart';
import '../../units/presentation/units_tab.dart';
import '../domain/policy.dart';
import '../domain/property.dart';
import 'properties_providers.dart';
import 'property_form_sheet.dart';
import 'team_tab.dart';

enum _MenuAction { edit, deactivate }

/// One property: its units, unit types and team. The tabs only receive ids and
/// permission flags, so each can be developed and tested on its own.
class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});

  final int propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(propertyProvider(propertyId));
    final property = async.value;
    if (property == null) {
      // First load or failure: skeleton / retryable error under a plain app bar.
      return Scaffold(
        appBar: AppBar(),
        body: AsyncView<Property>(
          value: async,
          onRefresh: () => ref.refresh(propertyProvider(propertyId).future),
          data: (_) => const SizedBox.shrink(),
        ),
      );
    }
    return _PropertyDetail(property: property);
  }
}

class _PropertyDetail extends ConsumerWidget {
  const _PropertyDetail({required this.property});

  final Property property;

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case _MenuAction.edit:
        final saved = await showFormSheet(
          context,
          PropertyFormSheet(initial: property),
        );
        if (saved && context.mounted) showSnack(context, l10n.propertySaved);
      case _MenuAction.deactivate:
        final ok = await confirmAction(
          context,
          title: l10n.deactivateConfirmTitle,
          body: l10n.deactivateConfirmBody,
          confirmLabel: l10n.deactivateProperty,
          destructive: true,
        );
        if (!ok || !context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        try {
          await ref.read(propertiesRepositoryProvider).deactivate(property.id);
          ref.read(appEventsProvider).emit(PropertyChanged(property.id));
          navigator.pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.propertyDeactivated)));
        } catch (e) {
          if (context.mounted) showSnack(context, failureText(context, e));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canEdit = property.can(PropertyAction.edit);
    final canDeactivate = property.can(PropertyAction.deactivate);
    // An inactive property is read-only everywhere (mirrors the backend rule).
    final active = property.isActive;
    final canUnits = active && property.can(PropertyAction.manageUnits);
    final canAccess = active && property.can(PropertyAction.manageAccess);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(property.name),
          actions: [
            if (active && (canEdit || canDeactivate))
              PopupMenuButton<_MenuAction>(
                onSelected: (a) => _onMenu(context, ref, a),
                itemBuilder: (_) => [
                  if (canEdit)
                    PopupMenuItem(
                      value: _MenuAction.edit,
                      child: Text(l10n.editProperty),
                    ),
                  if (canDeactivate)
                    PopupMenuItem(
                      value: _MenuAction.deactivate,
                      child: Text(l10n.deactivateProperty),
                    ),
                ],
              ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabUnits),
              Tab(text: l10n.tabUnitTypes),
              Tab(text: l10n.tabTeam),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!active)
              MaterialBanner(
                backgroundColor: theme.colorScheme.errorContainer,
                content: Text(l10n.errPropertyInactive),
                actions: const [SizedBox.shrink()],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (property.location != null) property.location!,
                        property.unitCount == 0
                            ? l10n.noUnitsYet
                            : l10n.unitsOccupied(
                                property.occupiedCount,
                                property.unitCount,
                              ),
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  UnitsTab(propertyId: property.id, canManage: canUnits),
                  UnitTypesTab(propertyId: property.id, canManage: canUnits),
                  TeamTab(propertyId: property.id, canManage: canAccess),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
