import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_net/models/data_models.dart';

void main() {
  test('Hospital.availabilityColor returns green when icuBeds >= 5', () {
    const hospital = Hospital(
      id: 'h',
      name: 'Test',
      distance: '0',
      icuBeds: 5,
      wardBeds: 0,
      hasSpecialists: false,
      latitude: 0,
      longitude: 0,
    );

    expect(hospital.availabilityColor, equals(const Color(0xFF2E7D32)));
  });

  test('Hospital.availabilityColor returns orange when 0 < icuBeds < 5', () {
    const hospital = Hospital(
      id: 'h',
      name: 'Test',
      distance: '0',
      icuBeds: 1,
      wardBeds: 0,
      hasSpecialists: false,
      latitude: 0,
      longitude: 0,
    );

    expect(hospital.availabilityColor, equals(const Color(0xFFEF6C00)));
  });

  test('Hospital.availabilityColor returns red when icuBeds == 0', () {
    const hospital = Hospital(
      id: 'h',
      name: 'Test',
      distance: '0',
      icuBeds: 0,
      wardBeds: 0,
      hasSpecialists: false,
      latitude: 0,
      longitude: 0,
    );

    expect(hospital.availabilityColor, equals(const Color(0xFFD32F2F)));
  });
}
