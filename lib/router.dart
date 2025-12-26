import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'features/auth/screens/login_screen.dart';
import 'features/paramedic/screens/paramedic_dashboard.dart';
import 'features/paramedic/screens/emergency_type_screen.dart';
import 'features/paramedic/screens/patient_input_screen.dart';
import 'features/paramedic/screens/hospital_map_screen.dart'; // Added
import 'features/hospital/screens/hospital_dashboard.dart';

final router = GoRouter(
  initialLocation: '/',
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.uri.toString() == '/';

    if (!isLoggedIn && !isLoggingIn) {
      return '/';
    }

    if (isLoggedIn && isLoggingIn) {
      // Role-based redirect for authenticated users trying to access login
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      if (email.contains('admin') || email.startsWith('h')) {
        return '/hospital-dashboard';
      } else {
        return '/paramedic-home';
      }
    }

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
      builder: (context, state) => const PatientInputScreen(),
    ),
    GoRoute(
      // Added to support existing patient_input_screen flow
      path: '/paramedic/hospital-map',
      builder: (context, state) => const HospitalMapScreen(),
    ),

    // Hospital Routes
    GoRoute(
      path: '/hospital-dashboard',
      builder: (context, state) => const HospitalDashboardScreen(),
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
