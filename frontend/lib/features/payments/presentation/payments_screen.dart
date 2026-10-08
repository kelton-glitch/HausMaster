import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.payments)),
      body: EmptyState(
        icon: Icons.payments_outlined,
        title: l10n.payments,
        body: l10n.emptyRentBody,
      ),
    );
  }
}
