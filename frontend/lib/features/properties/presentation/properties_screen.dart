import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/property.dart';
import 'properties_providers.dart';
import 'property_detail_screen.dart';
import 'property_form_sheet.dart';
import 'role_badge.dart';

/// The Properties tab: every property the manager can access.
class PropertiesScreen extends ConsumerWidget {
  const PropertiesScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showFormSheet(context, const PropertyFormSheet());
    if (saved && context.mounted) showSnack(context, l10n.propertySaved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addFirstProperty),
          ),
        ),
        data: (list) => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            96, // clear the FAB
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => PropertyCard(property: list[i]),
        ),
      ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addProperty),
            )
          : null,
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = property;
    final ratio = p.unitCount == 0 ? 0.0 : p.occupiedCount / p.unitCount;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: p.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: theme.textTheme.titleMedium),
              if (p.location != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  p.location!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.sm),
              Wrap(children: [RoleBadge(p.role)]),
              const SizedBox(height: Spacing.sm),
              if (p.unitCount > 0) ...[
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: ratio, minHeight: 6),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
              ],
              Text(
                p.unitCount == 0
                    ? l10n.noUnitsYet
                    : l10n.unitsOccupied(p.occupiedCount, p.unitCount),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
