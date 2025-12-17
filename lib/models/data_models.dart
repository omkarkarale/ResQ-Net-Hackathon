import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Hospital {
  final String id;
  final String name;
  final String distance;
  final int icuBeds;
  final int wardBeds;
  final bool hasSpecialists;
  final double latitude;
  final double longitude;

  const Hospital({
    required this.id,
    required this.name,
    required this.distance,
    required this.icuBeds,
    required this.wardBeds,
    required this.hasSpecialists,
    required this.latitude,
    required this.longitude,
  });

  Color get availabilityColor {
    if (icuBeds >= 5) return const Color(0xFF2E7D32); // Green
    if (icuBeds > 0) return const Color(0xFFEF6C00); // Orange
    return const Color(0xFFD32F2F); // Red
  }
}

class AmbulanceAlert {
  final String id;
  final String ambulanceId;
  final String emergencyType;
  final String notes;
  final String eta;
  final bool isCritical;
  final DateTime timestamp;

  const AmbulanceAlert({
    required this.id,
    required this.ambulanceId,
    required this.emergencyType,
    required this.notes,
    required this.eta,
    this.isCritical = false,
    required this.timestamp,
  });
}
