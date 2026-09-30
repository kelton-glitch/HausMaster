import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client-side twin of the backend's event bus.
///
/// A feature *announces* a fact ("units changed"); any other feature that cares
/// *listens* and refreshes itself. Neither imports the other, so a new screen
/// can react to existing facts without touching the feature that emits them.
sealed class AppEvent {
  const AppEvent();
}

/// A property was created, edited or deactivated.
class PropertyChanged extends AppEvent {
  const PropertyChanged([this.propertyId]);
  final int? propertyId;
}

/// Units or unit types of a property changed (affects occupancy counts).
class UnitsChanged extends AppEvent {
  const UnitsChanged(this.propertyId);
  final int propertyId;
}

/// Who has access to a property changed.
class AccessChanged extends AppEvent {
  const AccessChanged(this.propertyId);
  final int propertyId;
}

class AppEvents {
  final _controller = StreamController<AppEvent>.broadcast();

  void emit(AppEvent event) => _controller.add(event);

  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  void dispose() => _controller.close();
}

final appEventsProvider = Provider<AppEvents>((ref) {
  final events = AppEvents();
  ref.onDispose(events.dispose);
  return events;
});

extension AppEventRefresh on Ref {
  /// Re-runs this provider whenever an event of type [T] (passing [where]) fires.
  void refreshOn<T extends AppEvent>({bool Function(T event)? where}) {
    final sub = read(appEventsProvider).on<T>().listen((event) {
      if (where == null || where(event)) invalidateSelf();
    });
    onDispose(sub.cancel);
  }
}
