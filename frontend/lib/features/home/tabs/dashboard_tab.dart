import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_width.dart';
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                icon: Icons.apartment_outlined,
                title: l10n.totalProperties,
                value: totalProperties.toString(),
                color: theme.colorScheme.primary,
              ),
              _StatCard(
                icon: Icons.people_outline,
                title: l10n.totalTenants,
                value: totalTenants.toString(),
                color: theme.colorScheme.secondary,
              ),
              _StatCard(
                icon: Icons.door_front_door_outlined,
                title: l10n.totalUnits,
                value: totalUnits.toString(),
                color: theme.colorScheme.tertiary,
              ),
              _StatCard(
                icon: Icons.person_pin_outlined,
                title: l10n.occupiedUnits,
                value: occupiedUnits.toString(),
                color: theme.colorScheme.primaryContainer,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
