import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/unit.dart';
import 'unit_form_sheet.dart';
import 'units_providers.dart';

class UnitsTab extends ConsumerWidget {
  const UnitsTab({
    super.key,
    required this.propertyId,
    required this.canManage,
  });

  final int propertyId;
  final bool canManage;

  Future<void> _openForm(
    BuildContext context,
    List<UnitType> types, {
    Unit? unit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (types.isEmpty && unit == null) {
      showSnack(context, l10n.createTypeFirstTitle);
      return;
    }
    final saved = await showFormSheet(
      context,
      UnitFormSheet(propertyId: propertyId, unitTypes: types, initial: unit),
    );
    if (saved && context.mounted) showSnack(context, l10n.unitSaved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final units = ref.watch(unitsProvider(propertyId));
    final typesAsync = ref.watch(unitTypesProvider(propertyId));
    final types = typesAsync.value ?? const <UnitType>[];
    final noTypes = typesAsync.hasValue && types.isEmpty;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<Unit>>(
        value: units,
        onRefresh: () => ref.refresh(unitsProvider(propertyId).future),
        isEmpty: (l) => l.isEmpty,
        empty: noTypes
            ? EmptyState(
                icon: Icons.category_outlined,
                title: l10n.createTypeFirstTitle,
                body: l10n.createTypeFirstBody,
              )
            : EmptyState(
                icon: Icons.door_front_door_outlined,
                title: l10n.noUnitsTitle,
                body: l10n.noUnitsBody,
                action: canManage
                    ? FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(200, 52),
                        ),
                        onPressed: () => _openForm(context, types),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addUnit),
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
          itemBuilder: (_, i) => _UnitCard(
            unit: list[i],
            onTap: canManage
                ? () => _openForm(context, types, unit: list[i])
                : null,
          ),
        ),
      ),
      floatingActionButton: canManage && (units.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context, types),
              icon: const Icon(Icons.add),
              label: Text(l10n.addUnit),
            )
          : null,
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, this.onTap});

  final Unit unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final occupied = unit.status == UnitStatus.occupied;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minTileHeight: 64,
        onTap: onTap,
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(
              Icons.door_front_door_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          unit.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(unit.unitTypeName),
        trailing: StatusChip(
          icon: occupied ? Icons.person : Icons.check_circle_outline,
          label: occupied ? l10n.statusOccupied : l10n.statusVacant,
          tone: occupied ? StatusTone.primary : StatusTone.success,
        ),
      ),
    );
  }
}
