import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_width.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/manager.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.manager});

  final Manager manager;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = [
      (Icons.apartment_outlined, l10n.stepProperty),
      (Icons.person_add_alt_outlined, l10n.stepTenant),
      (Icons.description_outlined, l10n.stepLease),
    ];
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
          Text(l10n.gettingStarted, style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          for (final (icon, label) in steps)
            Card(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              child: ListTile(
                minTileHeight: kMinTapTarget + Spacing.sm,
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(label),
                trailing: Chip(
                  label: Text(l10n.comingSoon),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
