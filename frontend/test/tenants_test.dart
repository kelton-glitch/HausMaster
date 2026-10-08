import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/features/properties/domain/policy.dart';

import 'support.dart';

Finder _button(String label) => find.widgetWithText(FilledButton, label);

/// Opens the property detail with a type, one unit and one tenant already in
/// place, so the tenants and leases tabs have something to work with.
Future<FakeBackend> pumpWithTenant(
  WidgetTester tester, {
  Role role = Role.owner,
}) async {
  final be = FakeBackend(role: role)
    ..seedProperty('Résidence Bonanjo', withType: true, withUnit: true)
    ..seedTenant(1, 'Awa Mbaye', phone: '690111222');
  await pumpApp(tester, backend: be);
  await tester.tap(find.text('Biens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Résidence Bonanjo'));
  await tester.pumpAndSettle();
  return be;
}

void main() {
  group('tenants', () {
    testWidgets('a tenant can be registered and then edited', (tester) async {
      await pumpWithTenant(tester);
      await tapTab(tester, 'Locataires');
      expect(find.text('Awa Mbaye'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Serge Ndiaye');
      await tester.enterText(find.byType(TextFormField).at(1), '690333444');
      await tester.enterText(find.byType(TextFormField).at(2), 's@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'CMR-123');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Serge Ndiaye'), findsOneWidget);
      expect(find.text('690333444 · CMR-123'), findsOneWidget);

      await tester.tap(find.text('Serge Ndiaye'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Serge Diop');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Serge Diop'), findsOneWidget);
    });

    testWidgets('the name and the phone are required', (tester) async {
      await pumpWithTenant(tester);
      await tapTab(tester, 'Locataires');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();

      // The sheet stays open with the required markers rather than saving.
      expect(find.text('Nom complet'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('a phone already used in this property is refused', (
      tester,
    ) async {
      await pumpWithTenant(tester);
      await tapTab(tester, 'Locataires');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Autre');
      await tester.enterText(find.byType(TextFormField).at(1), '690111222');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();

      // A stable, localized message, not a raw server string.
      expect(
        find.text('Ce numéro est déjà utilisé par un autre locataire.'),
        findsOneWidget,
      );
    });

    testWidgets('deactivating asks first, then keeps the record', (
      tester,
    ) async {
      await pumpWithTenant(tester);
      await tapTab(tester, 'Locataires');

      await tester.tap(find.byTooltip('Désactiver ce locataire'));
      await tester.pumpAndSettle();
      expect(find.text('Désactiver ce locataire ?'), findsOneWidget);

      await tester.tap(_button('Désactiver ce locataire'));
      await tester.pumpAndSettle();

      // History is kept: the row stays, marked inactive, and it is not a
      // hard delete.
      expect(find.text('Awa Mbaye'), findsOneWidget);
      expect(find.text('Inactif'), findsOneWidget);
    });

    testWidgets('an inactive tenant cannot sign a new lease', (tester) async {
      final be = await pumpWithTenant(tester);
      await tapTab(tester, 'Locataires');
      await tester.tap(find.byTooltip('Désactiver ce locataire'));
      await tester.pumpAndSettle();
      await tester.tap(_button('Désactiver ce locataire'));
      await tester.pumpAndSettle();
      // Let the confirmation snackbar retire before checking the next one.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tapTab(tester, 'Baux');
      await tester.tap(_button('Ajouter un bail'));
      await tester.pumpAndSettle();

      // Refused before the form opens: nobody is left who can sign.
      expect(
        find.text('Enregistrez un locataire avant de signer un bail.'),
        findsOneWidget,
      );
      expect(find.text('Loyer mensuel (XAF)'), findsNothing);
      // The tenant was deactivated, not deleted.
      expect(be.tenantIds(1), hasLength(1));
    });

    testWidgets('a co-manager can manage tenants', (tester) async {
      await pumpWithTenant(tester, role: Role.coManager);
      await tapTab(tester, 'Locataires');
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
