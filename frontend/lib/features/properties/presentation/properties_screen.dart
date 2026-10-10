import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../core/widgets/occupancy_bar.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/property.dart';
import 'properties_providers.dart';
import 'property_detail_screen.dart';
import 'property_form_sheet.dart';
import 'role_badge.dart';

enum _Filter { all, occupied, vacant }

/// The Properties tab: every property the manager can access, with a summary,
/// search and occupancy filters.
class PropertiesScreen extends ConsumerStatefulWidget {
  const PropertiesScreen({super.key});

  @override
  ConsumerState<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends ConsumerState<PropertiesScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showFormSheet(context, const PropertyFormSheet());
    if (saved && mounted) showSnack(context, l10n.propertySaved);
  }

  List<Property> _visible(List<Property> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !(p.location ?? '').toLowerCase().contains(q)) {
        return false;
      }
      return switch (_filter) {
        _Filter.all => true,
        _Filter.occupied => p.occupiedCount > 0,
        _Filter.vacant => p.occupiedCount < p.unitCount,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(propertiesProvider);
    final hasItems = async.value?.isNotEmpty ?? false;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<Property>>(
        value: async,
        onRefresh: () => ref.refresh(propertiesProvider.future),
        isEmpty: (list) => list.isEmpty,
        empty: EmptyState(
          icon: Icons.apartment_outlined,
          title: l10n.emptyPropertiesTitle,
          body: l10n.emptyPropertiesBody,
          action: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(200, 52)),
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(l10n.addFirstProperty),
          ),
        ),
        data: (all) {
          final list = _visible(all);
          final units = all.fold<int>(0, (n, p) => n + p.unitCount);
          final occupied = all.fold<int>(0, (n, p) => n + p.occupiedCount);
          final rate = units == 0 ? 0 : (occupied * 100 / units).round();
          return ContentWidth(
            maxWidth: 720,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.lg,
                Spacing.lg,
                96, // clear the FAB
              ),
              children: [
                Text(
                  '${l10n.propertiesCount(all.length)} · '
                  '${l10n.unitsCount(units)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.door_front_door_outlined,
                        label: l10n.totalUnits,
                        value: '$units',
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: StatCard(
                        icon: Icons.percent,
                        label: l10n.occupancyRate,
                        value: '$rate%',
                        tint: context.appColors.successContainer,
                        onTint: context.appColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchProperties,
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLowest,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  children: [
                    for (final f in _Filter.values)
                      _FilterChip(
                        label: switch (f) {
                          _Filter.all => l10n.filterAll,
                          _Filter.occupied => l10n.filterOccupied,
                          _Filter.vacant => l10n.filterVacant,
                        },
                        selected: _filter == f,
                        onSelected: () => setState(() => _filter = f),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: l10n.noResultsTitle,
                      body: l10n.noResultsBody,
                    ),
                  )
                else
                  for (final p in list) PropertyCard(property: p),
              ],
            ),
          );
        },
      ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(l10n.addProperty),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? scheme.onPrimary : scheme.onSurface,
      ),
      selectedColor: scheme.primary,
      showCheckmark: false,
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property});

  final Property property;

  void _open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PropertyDetailScreen(propertyId: property.id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = property;
    final ratio = p.unitCount == 0 ? 0.0 : p.occupiedCount / p.unitCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.field),
                      ),
                      child: SizedBox.square(
                        dimension: 44,
                        child: Icon(
                          Icons.apartment_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: theme.textTheme.titleMedium),
                          if (p.location != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              p.location!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(children: [RoleBadge(p.role)]),
                const SizedBox(height: Spacing.md),
                if (p.unitCount > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.occupancyLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        l10n.unitsOccupied(p.occupiedCount, p.unitCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  OccupancyBar(ratio: ratio),
                ] else
                  Text(
                    l10n.noUnitsYet,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: Spacing.md),
                OutlinedButton.icon(
                  onPressed: () => _open(context),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(l10n.viewProperty),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
