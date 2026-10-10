import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: EmptyState(
        icon: Icons.account_balance_outlined,
        title: l10n.ledger,
        body: l10n.emptyRentBody,
      ),
    );
  }
}
