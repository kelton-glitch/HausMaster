import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/core/format.dart';
import 'package:hausmaster/features/properties/domain/policy.dart';
import 'package:hausmaster/features/units/domain/unit.dart';

import 'support.dart';

Finder _button(String label) => find.widgetWithText(FilledButton, label);

/// Seeds one property with a single vacant unit and a single active tenant,
/// then opens its detail screen. Returns the backend to assert against.
Future<FakeBackend> openReady(
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

/// Signs a lease through the form. With one unit and one tenant the dropdowns
/// are already resolved, so only the rent is typed.
Future<void> signLease(WidgetTester tester, {String rent = '90000'}) async {
  // The action lives on the FAB once a lease exists, and on the empty state
  // before that.
  final fab = find.byType(FloatingActionButton);
  if (fab.evaluate().isEmpty) {
    await tester.tap(_button('Ajouter un bail'));
  } else {
    await tester.tap(fab);
  }
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byType(TextFormField).last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).last, rent);
  await tester.tap(_button('Enregistrer'));
  await tester.pumpAndSettle();
}

void main() {
  group('leases', () {
    testWidgets('a lease can be signed and it fills the unit', (tester) async {
      final be = await openReady(tester);
      await tapTab(tester, 'Baux');
      await signLease(tester);

      // The lease reads as "unit · tenant" with its rent.
      expect(find.text('A1 · Awa Mbaye'), findsOneWidget);
      expect(find.textContaining(formatXaf(90000, 'fr')), findsOneWidget);

      // The unit is no longer vacant.
      expect(be.statusOf(1, be.onlyUnitId(1)), UnitStatus.occupied);
      await tapTab(tester, 'Logements');
      expect(find.text('Occupé'), findsOneWidget);
    });

    testWidgets('the property list reflects the new occupancy', (tester) async {
      await openReady(tester);
      await tapTab(tester, 'Baux');
      await signLease(tester);
      // The detail AppBar counts occupants.
      expect(find.textContaining('1/1 occupés'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      // And so does the list behind it, without a manual refresh.
      expect(find.textContaining('1/1 occupés'), findsOneWidget);
    });

    testWidgets('a unit cannot hold two open leases', (tester) async {
      final be = await openReady(tester);
      await tapTab(tester, 'Baux');
      await signLease(tester);
      final unit = be.onlyUnitId(1);
      final lease = be.onlyLease(1)!;
      // Let the confirmation snackbar retire so the FAB is back in place.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // The unit is now taken, so a second lease is refused up front.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(
        find.text('Ajoutez un logement vacant avant de signer un bail.'),
        findsOneWidget,
      );
      // No second record was written.
      expect(be.onlyLease(1)!.id, lease.id);
      expect(be.statusOf(1, unit), UnitStatus.occupied);
    });

    testWidgets('terminating asks first, then frees the unit', (tester) async {
      final be = await openReady(tester);
      await tapTab(tester, 'Baux');
      await signLease(tester);
      final lease = be.onlyLease(1)!;

      await tester.tap(find.byTooltip('Résilier le bail'));
      await tester.pumpAndSettle();
      expect(find.text('Résilier ce bail ?'), findsOneWidget);
      await tester.tap(_button('Résilier le bail'));
      await tester.pumpAndSettle();

      // A terminated lease leaves the default list but keeps its record.
      expect(find.text('A1 · Awa Mbaye'), findsNothing);
      expect(be.leaseOf(1, lease.id)!.isActive, isFalse);
      expect(be.statusOf(1, be.onlyUnitId(1)), UnitStatus.vacant);

      await tapTab(tester, 'Logements');
      expect(find.text('Libre'), findsOneWidget);
    });

    testWidgets('the rent is required', (tester) async {
      final be = await openReady(tester);
      await tapTab(tester, 'Baux');
      await tester.tap(_button('Ajouter un bail'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre invalide'), findsOneWidget);
      expect(be.onlyLease(1), isNull);
    });

    testWidgets('an expiring lease warns but can still be terminated', (
      tester,
    ) async {
      final be = FakeBackend()
        ..seedProperty('Résidence Bonanjo', withType: true, withUnit: true)
        ..seedTenant(1, 'Awa Mbaye', phone: '690111222');
      be.seedLease(
        1,
        be.onlyUnitId(1),
        be.onlyTenantId(1),
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();
      await tapTab(tester, 'Baux');

      expect(find.text('Bientôt échu'), findsOneWidget);
      // Renewing is exactly when termination is needed, so the warning must
      // not hide the action.
      await tester.tap(find.byTooltip('Résilier le bail'));
      await tester.pumpAndSettle();
      expect(find.text('Résilier ce bail ?'), findsOneWidget);
    });

    testWidgets('a co-manager can manage leases', (tester) async {
      await openReady(tester, role: Role.coManager);
      await tapTab(tester, 'Baux');

      await tester.tap(_button('Ajouter un bail'));
      await tester.pumpAndSettle();
      expect(find.text('Loyer mensuel (XAF)'), findsOneWidget);
    });
  });
}
