import 'package:flutter/material.dart';

/// Occupancy progress like the mockups: terracotta = occupied, green = free.
class OccupancyBar extends StatelessWidget {
  const OccupancyBar({super.key, required this.ratio, this.height = 6});

  final double ratio;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: ratio.clamp(0.0, 1.0),
          minHeight: height,
          color: scheme.primary,
          backgroundColor: scheme.secondary,
        ),
      ),
    );
  }
}
