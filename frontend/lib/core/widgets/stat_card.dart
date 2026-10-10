import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// KPI tile: tinted icon square, small label, big value. Used on the
/// dashboard and at the top of list screens.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.tint,
    this.onTint,
    this.footnote,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  /// Background and foreground of the icon square (defaults: primary tint).
  final Color? tint;
  final Color? onTint;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tint ?? scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    icon,
                    color: onTint ?? scheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (footnote != null)
                      Text(
                        footnote!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
