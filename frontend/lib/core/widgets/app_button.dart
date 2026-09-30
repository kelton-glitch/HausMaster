import 'package:flutter/material.dart';

/// Primary action button with a built-in loading state.
/// While [loading] the tap is ignored (no double submits) and the label is kept
/// for screen readers so the button's size and meaning don't change.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Semantics(
      button: true,
      enabled: onPressed != null && !loading,
      label: label,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: loading
              ? SizedBox(
                  key: const ValueKey('spinner'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: onPrimary,
                  ),
                )
              : Text(label, key: const ValueKey('label')),
        ),
      ),
    );
  }
}
