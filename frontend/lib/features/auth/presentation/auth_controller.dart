import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/manager.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  return createApiClient(
    ref.watch(tokenStorageProvider),
    // Refresh failed: drop the session so the UI returns to the login screen.
    onSessionExpired: () =>
        ref.read(authControllerProvider.notifier).sessionExpired(),
  );
});

final authRepositoryProvider = Provider(
  (ref) =>
      AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider)),
);

/// State: loading while restoring the session, then Manager? (null = signed out).
class AuthController extends AsyncNotifier<Manager?> {
  @override
  Future<Manager?> build() => ref.read(authRepositoryProvider).restoreSession();

  Future<void> login(String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .login(email: email, password: password),
  );

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) => _run(
    () => ref
        .read(authRepositoryProvider)
        .register(
          fullName: fullName,
          email: email,
          password: password,
          phone: phone,
        ),
  );

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  void sessionExpired() => state = const AsyncData(null);

  /// Drops a stale error so it isn't shown on another auth screen.
  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }

  Future<void> _run(Future<Manager> Function() action) async {
    // No AsyncLoading here: it would swap the form for the splash screen.
    // Screens track their own in-flight flag.
    state = await AsyncValue.guard(action);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Manager?>(
  AuthController.new,
);
