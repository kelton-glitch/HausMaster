import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('signed-out user sees the login form in French by default', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: SignedOut.new,
      locale: const Locale('fr', 'CM'),
    );
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('login form is English on an English device', (tester) async {
    await pumpApp(
      tester,
      auth: SignedOut.new,
      locale: const Locale('en', 'US'),
    );
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('unsupported device language falls back to French', (
    tester,
  ) async {
    await pumpApp(tester, auth: SignedOut.new, locale: const Locale('de'));
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('signed-in user sees the localized welcome', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));
    expect(find.text('Welcome, Ada Njoh'), findsOneWidget);
  });
}
