import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../network/failure.dart';
import '../theme/app_theme.dart';

/// One consistent way to render any async screen data:
/// skeleton while loading, a retryable error, an empty state, or the data
/// inside a pull-to-refresh. Every list in the app goes through this.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.data,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;

  /// Must build a scrollable (use [AlwaysScrollableScrollPhysics]).
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  Future<void> _safeRefresh() async {
    try {
      await onRefresh();
    } catch (_) {
      // The provider now holds the error; the UI renders it.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep showing the old data during a background refresh.
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const SkeletonList(),
      error: (error, _) => _ErrorState(error: error, onRetry: _safeRefresh),
      data: (d) {
        final showEmpty = empty != null && (isEmpty?.call(d) ?? false);
        return RefreshIndicator(
          onRefresh: _safeRefresh,
          child: showEmpty
              ? LayoutBuilder(
                  builder: (context, c) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [SizedBox(height: c.maxHeight, child: empty)],
                  ),
                )
              : data(d),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offline = Failure.from(error).offline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offline ? Icons.wifi_off_outlined : Icons.error_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: Spacing.md),
              Text(l10n.errorTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.xs),
              Text(
                failureText(context, error),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder cards shown on first load. Pulses gently, but holds still when
/// the user has "remove animations" enabled.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4});

  final int count;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: AppLocalizations.of(context)!.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Spacing.lg),
          itemCount: widget.count,
          itemBuilder: (_, _) => AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Opacity(
              opacity: 0.45 + 0.4 * _pulse.value,
              child: Container(
                height: 88,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
