import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/paramedic/screens/paramedic_home.dart';
import '../features/paramedic/screens/emergency_type_screen.dart';
import '../features/paramedic/screens/hospital_map_screen.dart';
import '../features/paramedic/screens/patient_input_screen.dart';
import '../features/paramedic/screens/severity_selection_screen.dart';
import '../features/paramedic/screens/situation_details_screen.dart';
import '../features/paramedic/screens/history_screen.dart';
import '../features/paramedic/screens/settings_screen.dart';
import '../features/hospital/screens/hospital_dashboard.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/paramedic',
      builder: (context, state) => const ParamedicHomeScreen(),
      routes: [
        GoRoute(
          path: 'emergency-type',
          builder: (context, state) => const EmergencyTypeScreen(),
        ),
        GoRoute(
          path: 'severity',
          builder: (context, state) => const SeveritySelectionScreen(),
        ),
        GoRoute(
          path: 'hospital-map',
          builder: (context, state) => const HospitalMapScreen(),
        ),
        GoRoute(
          path: 'situation-details',
          builder: (context, state) => const SituationDetailsScreen(),
        ),
        GoRoute(
          path: 'patient-input',
          builder: (context, state) => const PatientInputScreen(),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/hospital',
      builder: (context, state) => const HospitalDashboardScreen(),
    ),
  ],
);
