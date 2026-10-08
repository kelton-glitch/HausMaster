import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: EmptyState(
        icon: Icons.analytics_outlined,
        title: l10n.reports,
        body: l10n.emptyRentBody,
      ),
    );
  }
}
