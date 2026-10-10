import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum StatusTone { success, warning, danger, neutral, primary }

/// Small tinted pill ("Actif", "En retard", "Occupée" ...). Always pass an
/// [icon] or a clear label: colour alone never carries the meaning.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final (fg, bg) = switch (tone) {
      StatusTone.success => (c.success, c.successContainer),
      StatusTone.warning => (c.warning, c.warningContainer),
      StatusTone.danger => (c.danger, c.dangerContainer),
      StatusTone.neutral => (c.neutral, c.neutralContainer),
      StatusTone.primary => (
        scheme.onPrimaryContainer,
        scheme.primaryContainer,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
