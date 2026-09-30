import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The notification types from FR-17.
enum NotificationType {
  rentDue,
  overdue,
  paymentConfirmed,
  billIssued,
  leaseExpiring,
}

/// Which notification types the user wants. All on by default.
/// Stored locally for now; once FCM lands (Phase 2) this should also be synced
/// to the backend so the server can skip disabled types.
class NotificationPrefs extends Notifier<Set<NotificationType>> {
  static const _key = 'notification_types';

  @override
  Set<NotificationType> build() {
    _load();
    return {...NotificationType.values};
  }

  Future<void> _load() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getStringList(_key);
      if (saved == null) return;
      state = {
        for (final t in NotificationType.values)
          if (saved.contains(t.name)) t,
      };
    } catch (_) {
      // Storage unavailable: keep defaults.
    }
  }

  Future<void> setEnabled(NotificationType type, bool enabled) async {
    state = enabled ? {...state, type} : ({...state}..remove(type));
    try {
      await (await SharedPreferences.getInstance()).setStringList(_key, [
        for (final t in state) t.name,
      ]);
    } catch (_) {}
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefs, Set<NotificationType>>(
      NotificationPrefs.new,
    );
