import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Brand block shared by the login and register screens: the terracotta logo
/// tile, the app name and the tagline.
class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox.square(
              dimension: 64,
              child: Icon(
                Icons.home_outlined,
                color: scheme.onPrimary,
                size: 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Semantics(
          header: true,
          child: Text(
            'HausMaster',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.authTagline.toUpperCase(),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Decorative banner under the welcome text. A warm sunset gradient with a
/// house motif; swap the child for a photo asset when one is available.
class AuthHero extends StatelessWidget {
  const AuthHero({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        height: 132,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6B26B), Color(0xFFD9602F), Color(0xFF8E2F14)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              bottom: -18,
              child: Icon(
                Icons.apartment_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              left: 24,
              top: 22,
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 36,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            Positioned(
              left: 22,
              bottom: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.key_rounded,
                    size: 22,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Langue : Français (FR)" - tapping switches French <-> English.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    return TextButton.icon(
      onPressed: () =>
          ref.read(localeProvider.notifier).set(Locale(isFr ? 'en' : 'fr')),
      icon: const Icon(Icons.language, size: 18),
      label: Text(
        l10n.languageSwitch.toUpperCase(),
        style: const TextStyle(letterSpacing: 1, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
