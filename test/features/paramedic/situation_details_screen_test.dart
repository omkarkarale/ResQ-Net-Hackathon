import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resq_net/features/paramedic/screens/situation_details_screen.dart';

import '../../test_utils.dart';

void main() {
  testWidgets(
    'SituationDetailsScreen blocks navigation and shows SnackBar when description is empty',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/paramedic/situation-details',
        routes: [
          GoRoute(
            path: '/paramedic/situation-details',
            builder: (context, state) => const SituationDetailsScreen(),
          ),
          GoRoute(
            path: '/paramedic/patient-input',
            builder: (context, state) => const Scaffold(body: Text('PatientInput')),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/paramedic/situation-details');

      final scrollable = find.byType(Scrollable).first;
      final continueButton = find.widgetWithText(ElevatedButton, 'CONTINUE TO TRIAGE');
      await tester.scrollUntilVisible(continueButton, 300, scrollable: scrollable);
      await tester.tap(continueButton);
      await tester.pump();

      expect(find.text('Please provide a situation description.'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/paramedic/situation-details');
    },
  );

  testWidgets(
    'SituationDetailsScreen navigates when description is non-empty',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/paramedic/situation-details',
        routes: [
          GoRoute(
            path: '/paramedic/situation-details',
            builder: (context, state) => const SituationDetailsScreen(),
          ),
          GoRoute(
            path: '/paramedic/patient-input',
            builder: (context, state) => const Scaffold(body: Text('PatientInput')),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      final descriptionField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Describe what happened...',
      );
      await tester.scrollUntilVisible(descriptionField, 300, scrollable: scrollable);
      await tester.enterText(descriptionField, 'Some description');

      final continueButton = find.widgetWithText(ElevatedButton, 'CONTINUE TO TRIAGE');
      await tester.scrollUntilVisible(continueButton, 300, scrollable: scrollable);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/paramedic/patient-input');
      expect(find.text('PatientInput'), findsOneWidget);
    },
  );
}
