import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/data_models.dart';

// Mock Hospitals (Mumbai Locations)
final hospitalsProvider = Provider<List<Hospital>>((ref) {
  return [
    const Hospital(
      id: 'h1',
      name: 'Lilavati Hospital',
      distance: '12 mins',
      icuBeds: 5,
      wardBeds: 18,
      hasSpecialists: true,
      latitude: 19.0522,
      longitude: 72.8288,
    ),
    const Hospital(
      id: 'h2',
      name: 'Breach Candy Hospital',
      distance: '25 mins',
      icuBeds: 2,
      wardBeds: 8,
      hasSpecialists: true,
      latitude: 18.9715,
      longitude: 72.8096,
    ),
    const Hospital(
      id: 'h3',
      name: 'P. D. Hinduja Hospital',
      distance: '15 mins',
      icuBeds: 8,
      wardBeds: 25,
      hasSpecialists: true,
      latitude: 19.0336,
      longitude: 72.8384,
    ),
    const Hospital(
      id: 'h4',
      name: 'Nanavati Super Speciality',
      distance: '18 mins',
      icuBeds: 4,
      wardBeds: 15,
      hasSpecialists: true,
      latitude: 19.0963,
      longitude: 72.8427,
    ),
    const Hospital(
      id: 'h5',
      name: 'KEM Hospital',
      distance: '20 mins',
      icuBeds: 0,
      wardBeds: 40,
      hasSpecialists: true, // Public hospital
      latitude: 19.0068,
      longitude: 72.8421,
    ),
    const Hospital(
      id: 'h6',
      name: 'Kokilaben Dhirubhai Ambani',
      distance: '28 mins',
      icuBeds: 12,
      wardBeds: 50,
      hasSpecialists: true,
      latitude: 19.1309,
      longitude: 72.8295,
    ),
    const Hospital(
      id: 'h7',
      name: 'Lokmanya Tilak Municipal (Sion)',
      distance: '14 mins',
      icuBeds: 3,
      wardBeds: 60,
      hasSpecialists: true,
      latitude: 19.0390,
      longitude: 72.8619,
    ),
    const Hospital(
      id: 'h8',
      name: 'Apollo Hospital (Navi Mumbai)',
      distance: '45 mins',
      icuBeds: 15,
      wardBeds: 30,
      hasSpecialists: true,
      latitude: 19.0016,
      longitude: 73.0297,
    ),
    const Hospital(
      id: 'h9',
      name: 'K. J. Somaiya Hospital',
      distance: '16 mins',
      icuBeds: 6,
      wardBeds: 20,
      hasSpecialists: true,
      latitude: 19.0465,
      longitude: 72.8732,
    ),
    const Hospital(
      id: 'h10',
      name: 'H. N. Reliance Foundation',
      distance: '30 mins',
      icuBeds: 35,
      wardBeds: 80,
      hasSpecialists: true,
      latitude: 18.9614,
      longitude: 72.8184,
    ),
    const Hospital(
      id: 'h11',
      name: 'Tata Memorial Hospital',
      distance: '19 mins',
      icuBeds: 10,
      wardBeds: 25,
      hasSpecialists: true,
      latitude: 19.0055,
      longitude: 72.8415,
    ),
  ];
});

// Incoming Alerts State (Shared between Route action and Dashboard)
class AlertsNotifier extends StateNotifier<List<AmbulanceAlert>> {
  AlertsNotifier() : super([]);

  void addAlert(AmbulanceAlert alert) {
    state = [alert, ...state];
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, List<AmbulanceAlert>>((ref) {
  return AlertsNotifier();
});

// Selected Emergency Type State
final selectedEmergencyTypeProvider = StateProvider<String?>((ref) => null);
