import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/state.dart';
import '../../../models/data_models.dart';

class HospitalMapScreen extends ConsumerWidget {
  const HospitalMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitals = ref.watch(hospitalsProvider);

    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        body: Stack(
          children: [
            // MOCK MAP
            Container(
              color: Colors.grey[800],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 80, color: Colors.white24),
                    const Text('Mumbai, India Map View',
                        style: TextStyle(color: Colors.white24)),
                    // Mock Pins
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          hospitals.map((h) => _MapPin(hospital: h)).toList(),
                    )
                  ],
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 40,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),

            // Bottom Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 400,
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black45, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                        child: Container(
                            width: 40, height: 4, color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Suggested Hospitals',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hospitals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final hospital = hospitals[index];
                          return _HospitalCard(
                            hospital: hospital,
                            onRoute: () {
                              // Navigate to Situation Details instead of finalized alert
                              // We could store the selected hospital in state if needed, but for now we just move forward
                              // In a real app, we'd pass the hospital ID.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Hospital selected. Please provide details.'),
                                  backgroundColor: AppTheme.secondaryTrust,
                                  duration: Duration(milliseconds: 500),
                                ),
                              );
                              context.go('/paramedic/situation-details');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Hospital hospital;
  const _MapPin({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hospital.availabilityColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              '${hospital.icuBeds}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const Icon(Icons.location_on, color: Colors.red, size: 30),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onRoute;

  const _HospitalCard({required this.hospital, required this.onRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospital.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text('ETA: ${hospital.distance}',
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
              _AvailabilityBadge(count: hospital.icuBeds, label: 'ICU'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryTrust,
              ),
              child: const Text('ROUTE TO THIS HOSPITAL'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final int count;
  final String label;

  const _AvailabilityBadge({required this.count, required this.label});

  Color get color {
    if (count >= 5) return AppTheme.successGreen;
    if (count > 0) return AppTheme.warningOrange;
    return AppTheme.primaryAlert;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
