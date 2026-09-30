import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/policy.dart';

/// Role label. Text + icon, never colour alone.
class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final Role role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final owner = role == Role.owner;
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        owner ? Icons.verified_user_outlined : Icons.group_outlined,
        size: 16,
      ),
      label: Text(owner ? l10n.roleOwner : l10n.roleCoManager),
    );
  }
}
