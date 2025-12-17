import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resq_net/features/paramedic/screens/patient_input_screen.dart';

import '../../test_utils.dart';

void main() {
  testWidgets(
    "PatientInputScreen's confirmation slider triggers navigation when set to completion",
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/paramedic/patient-input',
        routes: [
          GoRoute(
            path: '/paramedic/patient-input',
            builder: (context, state) => const PatientInputScreen(),
          ),
          GoRoute(
            path: '/paramedic/hospital-map',
            builder: (context, state) => const Scaffold(body: Text('HospitalMap')),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/paramedic/patient-input');

      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(1.0);
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/paramedic/hospital-map');
      expect(find.text('HospitalMap'), findsOneWidget);
    },
  );
}
