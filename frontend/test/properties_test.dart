import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausmaster/core/network/failure.dart';
import 'package:hausmaster/core/widgets/async_view.dart';
import 'package:hausmaster/features/properties/domain/policy.dart';

import 'support.dart';

Finder _button(String label) => find.widgetWithText(FilledButton, label);

void main() {
  group('Failure', () {
    test('reads the backend error code', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 409,
          data: {'detail': 'English text', 'code': 'unit_label_taken'},
        ),
      );
      final f = Failure.from(e);
      expect(
        (f.code, f.statusCode, f.offline),
        ('unit_label_taken', 409, false),
      );
    });

    test(
      'no response means offline; 422 without a code is a validation error',
      () {
        final offline = Failure.from(
          DioException(requestOptions: RequestOptions(path: '/x')),
        );
        expect(offline.offline, isTrue);
        final invalid = Failure.from(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            response: Response(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: 422,
              data: {'detail': []},
            ),
          ),
        );
        expect(invalid.code, 'validation_error');
      },
    );
  });

  group('properties list', () {
    testWidgets(
      'shows a skeleton first, then the empty state with a call to action',
      (tester) async {
        final be = FakeBackend()..listDelay = const Duration(seconds: 1);
        await pumpApp(tester, backend: be, settle: false);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Biens'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(SkeletonList), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(find.text('Aucun bien pour l’instant'), findsOneWidget);
        expect(_button('Ajouter mon premier bien'), findsOneWidget);
      },
    );

    testWidgets('a failed load shows a localized error and Retry recovers', (
      tester,
    ) async {
      final be = FakeBackend()..seedProperty('Résidence Bonanjo');
      be.failNextList = const Failure(offline: true);
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Impossible de joindre le serveur'),
        findsOneWidget,
      );

      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.text('Résidence Bonanjo'), findsOneWidget);
    });

    testWidgets('create a property from the empty state', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      await tester.tap(_button('Ajouter mon premier bien'));
      await tester.pumpAndSettle();

      // Required-field validation first.
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Requis'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Villa Akwa');
      await tester.enterText(find.byType(TextFormField).at(2), 'Douala');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Villa Akwa'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
      expect(find.text('Propriétaire'), findsOneWidget);
      expect(find.text('Bien enregistré.'), findsOneWidget);
    });
  });

  group('the orchestra: features reacting to each other', () {
    testWidgets('adding a type and a unit updates the property list counts', (
      tester,
    ) async {
      final be = FakeBackend()
        ..seedProperty('Résidence Bonanjo', city: 'Douala');
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun logement'), findsOneWidget);

      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();
      // No unit types yet: the Units tab says so.
      expect(find.text('Créez d’abord un type de logement'), findsOneWidget);

      // Unit type.
      await tester.tap(find.text('Types'));
      await tester.pumpAndSettle();
      await tester.tap(_button('Ajouter un type'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Studio');
      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.enterText(find.byType(TextFormField).at(2), '85000');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Studio'), findsOneWidget);
      expect(find.textContaining('XAF'), findsOneWidget);

      // Unit (the single type is preselected).
      await tester.tap(find.text('Logements'));
      await tester.pumpAndSettle();
      await tester.tap(_button('Ajouter un logement'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'a1');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('a1'), findsOneWidget);
      expect(find.text('Libre'), findsOneWidget);
      // The header counts refreshed by themselves.
      expect(find.textContaining('0/1 occupés'), findsOneWidget);

      // ...and so did the list behind this screen.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('0/1 occupés'), findsOneWidget);
    });

    testWidgets('a server error code becomes a localized message in the form', (
      tester,
    ) async {
      final be = FakeBackend()
        ..seedProperty('Résidence Bonanjo', withUnit: true);
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'A1');
      await tester.tap(_button('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Un logement porte déjà ce numéro.'), findsOneWidget);
    });

    testWidgets('the same error is English on an English device', (
      tester,
    ) async {
      final be = FakeBackend()
        ..seedProperty('Bonanjo Residence', withUnit: true);
      await pumpApp(tester, backend: be, locale: const Locale('en'));
      await tester.tap(find.text('Properties'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bonanjo Residence'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'A1');
      await tester.tap(_button('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('A unit with this label already exists.'),
        findsOneWidget,
      );
    });
  });

  group('roles', () {
    testWidgets(
      'a co-manager can work on units but not edit, deactivate or invite',
      (tester) async {
        final be = FakeBackend(role: Role.coManager)
          ..seedProperty('Résidence Bonanjo', withUnit: true);
        await pumpApp(tester, backend: be);
        await tester.tap(find.text('Biens'));
        await tester.pumpAndSettle();
        expect(find.text('Co-gestionnaire'), findsOneWidget);
        await tester.tap(find.text('Résidence Bonanjo'));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => w is PopupMenuButton),
          findsNothing,
        ); // no edit/deactivate
        expect(
          find.byType(FloatingActionButton),
          findsOneWidget,
        ); // can add units

        await tester.tap(find.text('Équipe'));
        await tester.pumpAndSettle();
        expect(
          find.byType(FloatingActionButton),
          findsNothing,
        ); // cannot invite
      },
    );

    testWidgets('an owner can invite a co-manager', (tester) async {
      final be = FakeBackend()..seedProperty('Résidence Bonanjo');
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Équipe'));
      await tester.pumpAndSettle();
      expect(find.text('Ada Njoh (vous)'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'bob@example.com',
      );
      await tester.tap(_button('Inviter'));
      await tester.pumpAndSettle();
      expect(find.text('bob'), findsOneWidget);
      expect(find.text('Accès accordé.'), findsOneWidget);
    });

    testWidgets(
      'deactivating a property asks first, then removes it from the list',
      (tester) async {
        final be = FakeBackend()..seedProperty('Résidence Bonanjo');
        await pumpApp(tester, backend: be);
        await tester.tap(find.text('Biens'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Résidence Bonanjo'));
        await tester.pumpAndSettle();

        await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Désactiver le bien'));
        await tester.pumpAndSettle();
        expect(find.text('Désactiver ce bien ?'), findsOneWidget);
        await tester.tap(
          find.widgetWithText(FilledButton, 'Désactiver le bien'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Résidence Bonanjo'), findsNothing);
        expect(find.text('Bien désactivé.'), findsOneWidget);
      },
    );
  });

  group('accessibility of the property screens', () {
    Future<void> openDetail(WidgetTester tester) async {
      final be = FakeBackend()
        ..seedProperty('Résidence Bonanjo', city: 'Douala', withUnit: true);
      await pumpApp(tester, backend: be);
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle();
    }

    testWidgets('list and detail meet tap-target and label guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();
      for (final tab in ['Logements', 'Types', 'Équipe']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      }
      handle.dispose();
    });

    testWidgets('no overflow at 200% text scale', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openDetail(tester);
      await tester.tap(find.text('Résidence Bonanjo'));
      await tester.pumpAndSettle();
      for (final tab in ['Logements', 'Types', 'Équipe']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  });
}
