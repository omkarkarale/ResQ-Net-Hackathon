import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resq_net/core/state.dart';
import 'package:resq_net/features/paramedic/screens/emergency_type_screen.dart';

import '../../test_utils.dart';

void main() {
  testWidgets(
    'EmergencyTypeScreen updates selectedEmergencyTypeProvider when a type is tapped',
    (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/paramedic/emergency-type',
        routes: [
          GoRoute(
            path: '/paramedic/emergency-type',
            builder: (context, state) => const EmergencyTypeScreen(),
          ),
          GoRoute(
            path: '/paramedic/severity',
            builder: (context, state) => const Scaffold(body: Text('Severity')),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(router: router, container: container));
      await tester.pumpAndSettle();

      expect(container.read(selectedEmergencyTypeProvider), isNull);

      await tester.tap(find.text('Cardiac'));
      await tester.pumpAndSettle();

      expect(container.read(selectedEmergencyTypeProvider), equals('Cardiac'));
      expect(router.routeInformationProvider.value.uri.path, '/paramedic/severity');
    },
  );
}
