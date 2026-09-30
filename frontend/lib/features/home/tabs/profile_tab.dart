import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/notifications/notification_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/content_width.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/manager.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key, required this.manager});

  final Manager manager;

  String _notificationLabel(AppLocalizations l10n, NotificationType type) =>
      switch (type) {
        NotificationType.rentDue => l10n.notifRentDue,
        NotificationType.overdue => l10n.notifOverdue,
        NotificationType.paymentConfirmed => l10n.notifPayment,
        NotificationType.billIssued => l10n.notifBill,
        NotificationType.leaseExpiring => l10n.notifLease,
      };

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final override = ref.watch(localeProvider)?.languageCode;
    return ContentWidth(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(Spacing.md),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initialsOf(manager.fullName),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(manager.fullName),
              subtitle: Text(manager.email),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(l10n.language, style: theme.textTheme.titleSmall),
          const SizedBox(height: Spacing.sm),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'auto', label: Text(l10n.languageSystem)),
              ButtonSegment(value: 'fr', label: Text(l10n.languageFrench)),
              ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
            ],
            selected: {override ?? 'auto'},
            onSelectionChanged: (s) {
              final v = s.first;
              ref
                  .read(localeProvider.notifier)
                  .set(v == 'auto' ? null : Locale(v));
            },
          ),
          const SizedBox(height: Spacing.lg),
          Text(l10n.appearance, style: theme.textTheme.titleSmall),
          const SizedBox(height: Spacing.sm),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {ref.watch(themeModeProvider)},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: Spacing.lg),
          Text(l10n.notifications, style: theme.textTheme.titleSmall),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.notificationsNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final type in NotificationType.values)
                  SwitchListTile(
                    title: Text(_notificationLabel(l10n, type)),
                    value: ref.watch(notificationPrefsProvider).contains(type),
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .setEnabled(type, v),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: theme.colorScheme.error,
            ),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
