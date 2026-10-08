import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bills)),
      body: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.bills,
        body: l10n.emptyRentBody,
      ),
    );
  }
}
