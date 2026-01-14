import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'features/auth/screens/login_screen.dart';
import 'features/paramedic/screens/paramedic_dashboard.dart';
import 'features/paramedic/screens/emergency_type_screen.dart';
import 'features/paramedic/screens/patient_input_screen.dart';
import 'features/paramedic/screens/hospital_map_screen.dart'; // Added

final router = GoRouter(
  initialLocation: '/',
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.uri.toString() == '/';
    if (!isLoggedIn && !isLoggingIn) return '/';
    return null;
  },
  routes: [
    // Initial Route (Login)
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),

    // Paramedic Routes
    GoRoute(
      path: '/paramedic-home',
      builder: (context, state) => const ParamedicDashboardScreen(),
    ),
    GoRoute(
      path: '/emergency-type',
      builder: (context, state) => const EmergencyTypeScreen(),
    ),
    GoRoute(
      path: '/patient-input',
      builder: (context, state) {
        final emergencyType = state.extra as String?;
        return PatientInputScreen(emergencyType: emergencyType ?? 'General');
      },
    ),
    GoRoute(
      // Added to support existing patient_input_screen flow
      path: '/paramedic/hospital-map',
      builder: (context, state) {
        final triageId = state.extra as String?;
        return HospitalMapScreen(triageId: triageId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri.toString()}'),
    ),
  ),
);

// Stream wrapper for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
