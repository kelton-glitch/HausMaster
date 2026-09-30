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
import '../domain/unit.dart';
import 'unit_type_form_sheet.dart';
import 'units_providers.dart';

class UnitTypesTab extends ConsumerWidget {
  const UnitTypesTab({
    super.key,
    required this.propertyId,
    required this.canManage,
  });

  final int propertyId;
  final bool canManage;

  Future<void> _openForm(BuildContext context, {UnitType? type}) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showFormSheet(
      context,
      UnitTypeFormSheet(propertyId: propertyId, initial: type),
    );
    if (saved && context.mounted) showSnack(context, l10n.unitTypeSaved);
  }

  Future<void> _deactivate(
    BuildContext context,
    WidgetRef ref,
    UnitType type,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAction(
      context,
      title: l10n.deactivateUnitType,
      body: l10n.deactivateTypeBody,
      confirmLabel: l10n.deactivateUnitType,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref
          .read(unitsRepositoryProvider)
          .deactivateUnitType(propertyId, type.id);
      ref.read(appEventsProvider).emit(UnitsChanged(propertyId));
      if (context.mounted) showSnack(context, l10n.unitTypeDeactivated);
    } catch (e) {
      if (context.mounted) showSnack(context, failureText(context, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final types = ref.watch(unitTypesProvider(propertyId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<UnitType>>(
        value: types,
        onRefresh: () => ref.refresh(unitTypesProvider(propertyId).future),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.category_outlined,
          title: l10n.noUnitTypesTitle,
          body: l10n.noUnitTypesBody,
          action: canManage
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addUnitType),
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
          itemBuilder: (_, i) {
            final t = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                minTileHeight: 64,
                onTap: canManage ? () => _openForm(context, type: t) : null,
                leading: const Icon(Icons.category_outlined),
                title: Text(t.name),
                subtitle: Text(
                  '${l10n.roomsCount(t.roomCount)} · ${formatXaf(t.baseRent, locale)}',
                ),
                trailing: canManage
                    ? IconButton(
                        tooltip: l10n.deactivateUnitType,
                        icon: const Icon(Icons.archive_outlined),
                        onPressed: () => _deactivate(context, ref, t),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      floatingActionButton: canManage && (types.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addUnitType),
            )
          : null,
    );
  }
}
