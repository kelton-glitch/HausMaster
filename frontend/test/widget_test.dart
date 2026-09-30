import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/features/auth/domain/manager.dart';
import 'package:hausmaster/features/auth/presentation/auth_controller.dart';
import 'package:hausmaster/main.dart';

class _SignedOut extends AuthController {
  @override
  Future<Manager?> build() async => null;
}

class _SignedIn extends AuthController {
  @override
  Future<Manager?> build() async =>
      const Manager(id: 1, fullName: 'Ada Njoh', email: 'ada@example.com');
}

Future<void> _pump(
  WidgetTester tester,
  AuthController Function() auth,
  Locale locale,
) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWith(auth)],
      child: const HausMasterApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed-out user sees the login form in French by default', (
    tester,
  ) async {
    await _pump(tester, _SignedOut.new, const Locale('fr', 'CM'));
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('login form is English on an English device', (tester) async {
    await _pump(tester, _SignedOut.new, const Locale('en', 'US'));
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('unsupported device language falls back to French', (
    tester,
  ) async {
    await _pump(tester, _SignedOut.new, const Locale('de'));
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('signed-in user sees the localized welcome', (tester) async {
    await _pump(tester, _SignedIn.new, const Locale('en'));
    expect(find.text('Welcome, Ada Njoh'), findsOneWidget);
  });
}
