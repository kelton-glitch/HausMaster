import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/features/auth/domain/manager.dart';
import 'package:hausmaster/features/auth/presentation/auth_controller.dart';
import 'package:hausmaster/main.dart';
import 'package:hausmaster/features/properties/presentation/properties_providers.dart';
import 'package:hausmaster/features/units/presentation/units_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support.dart';

class _SignedOut extends AuthController {
  @override
  Future<Manager?> build() async => null;
}

class _SignedIn extends AuthController {
  @override
  Future<Manager?> build() async =>
      const Manager(id: 1, fullName: 'Ada Njoh', email: 'ada@example.com');

  @override
  Future<void> logout() async => state = const AsyncData(null);
}

Future<void> _pump(
  WidgetTester tester,
  AuthController Function() auth, {
  Locale locale = const Locale('fr'),
}) async {
  SharedPreferences.setMockInitialValues({});
  // Phone-sized window by default (the test default is 800dp wide = tablet layout).
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(auth),
        propertiesRepositoryProvider.overrideWithValue(
          FakePropertiesRepository(FakeBackend()),
        ),
        unitsRepositoryProvider.overrideWithValue(
          FakeUnitsRepository(FakeBackend()),
        ),
      ],
      child: const HausMasterApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('login form', () {
    testWidgets('empty submit shows required errors', (tester) async {
      await _pump(tester, _SignedOut.new);
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Requis'), findsNWidgets(2));
    });

    testWidgets('invalid email is flagged while typing', (tester) async {
      await _pump(tester, _SignedOut.new);
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.pumpAndSettle();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('password visibility toggles', (tester) async {
      await _pump(tester, _SignedOut.new);
      expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);
      await tester.tap(find.byTooltip('Afficher le mot de passe'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);
    });

    testWidgets('register screen opens and returns', (tester) async {
      await _pump(tester, _SignedOut.new);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      expect(find.text('Créer mon compte'), findsOneWidget);
      await tester.tap(find.text('J’ai déjà un compte'));
      await tester.pumpAndSettle();
      expect(find.text('Bon retour'), findsOneWidget);
    });

    testWidgets('password rule turns into a check at 8 characters', (
      tester,
    ) async {
      await _pump(tester, _SignedOut.new);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, 'longenough1');
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('login meets tap-target and label guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _SignedOut.new);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('home meets tap-target and label guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _SignedIn.new);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('no overflow at 200% text scale', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(tester, _SignedOut.new);
      expect(tester.takeException(), isNull);
    });
  });

  group('app shell', () {
    testWidgets('bottom bar on phones, rail on wide screens', (tester) async {
      await _pump(tester, _SignedIn.new);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('tabs show their empty states', (tester) async {
      await _pump(tester, _SignedIn.new);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun bien pour l’instant'), findsOneWidget);
      await tester.tap(find.text('Loyers'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun loyer à suivre'), findsOneWidget);
    });

    testWidgets('language can be switched at runtime', (tester) async {
      await _pump(tester, _SignedIn.new);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Properties'), findsOneWidget);
    });

    testWidgets('logout asks for confirmation', (tester) async {
      await _pump(tester, _SignedIn.new);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Se déconnecter'),
        200,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter ?'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter ?'), findsNothing);
      expect(
        find.widgetWithText(OutlinedButton, 'Se déconnecter'),
        findsOneWidget,
      ); // still signed in

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Se déconnecter'),
        200,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Se déconnecter'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Bon retour'), findsOneWidget);
    });

    testWidgets('theme can be switched and is applied', (tester) async {
      await _pump(tester, _SignedIn.new);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      ThemeMode mode() =>
          tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
      expect(mode(), ThemeMode.system);

      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();
      expect(mode(), ThemeMode.dark);
      await tester.tap(find.text('Clair'));
      await tester.pumpAndSettle();
      expect(mode(), ThemeMode.light);
    });

    testWidgets('notification preferences toggle and persist', (tester) async {
      await _pump(tester, _SignedIn.new);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      final tile = find.widgetWithText(SwitchListTile, 'Paiement confirmé');
      await tester.scrollUntilVisible(tile, 200);
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('notification_types'),
        isNot(contains('paymentConfirmed')),
      );
      expect(prefs.getStringList('notification_types'), contains('rentDue'));
    });
  });
}
