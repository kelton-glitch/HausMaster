import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/manager.dart';
import '../../properties/presentation/properties_providers.dart';
import '../../properties/domain/property.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key, required this.manager});

  final Manager manager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final propertiesAsync = ref.watch(propertiesProvider);
    final properties = propertiesAsync.value ?? <Property>[];

    int totalProperties = properties.length;
    int totalUnits = 0;
    int occupiedUnits = 0;
    int totalTenants = 0;

    for (final p in properties) {
      totalUnits += p.unitCount;
      occupiedUnits += p.occupiedCount;
    }

    // Sum tenants across properties (approximate by fetching each - but for dashboard, simple)
    // For now, we don't have a global tenants count; skip or show 0 if not loaded
    // This is a UI-only enhancement

    return ContentWidth(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.welcome(manager.fullName),
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.apartment_outlined,
                  label: l10n.totalProperties,
                  value: totalProperties.toString(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.people_outline,
                  label: l10n.totalTenants,
                  value: totalTenants.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.door_front_door_outlined,
                  label: l10n.totalUnits,
                  value: totalUnits.toString(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.person_pin_outlined,
                  label: l10n.occupiedUnits,
                  value: occupiedUnits.toString(),
                  tint: context.appColors.successContainer,
                  onTint: context.appColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Text(l10n.upcomingPayments, style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    l10n.emptyRentBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(l10n.recentActivity, style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(
                l10n.emptyRentBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
