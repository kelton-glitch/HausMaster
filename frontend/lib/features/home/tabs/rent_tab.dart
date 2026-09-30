import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class RentTab extends StatelessWidget {
  const RentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.emptyRentTitle,
      body: l10n.emptyRentBody,
    );
  }
}
