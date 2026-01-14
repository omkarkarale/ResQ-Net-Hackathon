import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme.dart';
import '../../../core/state.dart';
import '../../../models/data_models.dart';

class HospitalMapScreen extends ConsumerWidget {
  final String? triageId;

  const HospitalMapScreen({super.key, this.triageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitals = ref.watch(hospitalsProvider);

    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          title: const Text('NEARBY HOSPITALS'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: _CancelEmergencyButton(
              triageId: triageId), // Custom Hold-to-Cancel Button
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Select a hospital for transport",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTrust,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Hospital List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: hospitals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return _HospitalCard(
                      hospital: hospital,
                      onRoute: () {
                        // Mock Navigation
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Starting Route Guidance...'),
                          backgroundColor: AppTheme.successGreen,
                          duration: Duration(seconds: 2),
                        ));
                        // In real app, launch Maps URL here
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name,
                        softWrap: true,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppTheme.secondaryTrust),
                        const SizedBox(width: 4),
                        Text('${hospital.distance} away',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: Colors.white54),
                        const SizedBox(width: 4),
                        // Mocking time estimation based on distance (rough approx)
                        Text(
                            '~${(double.parse(hospital.distance.replaceAll(RegExp(r'[^0-9.]'), '')) * 3).round()} min ETA',
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AvailabilityBadge(count: hospital.icuBeds, label: 'ICU Beds'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRoute,
              icon: const Icon(Icons.directions, color: Colors.black),
              label: const Text('ROUTE TO HOSPITAL',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppTheme.secondaryTrust, // Light blue action color
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 24)),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CancelEmergencyButton extends StatefulWidget {
  final String? triageId;
  const _CancelEmergencyButton({this.triageId});

  @override
  State<_CancelEmergencyButton> createState() => _CancelEmergencyButtonState();
}

class _CancelEmergencyButtonState extends State<_CancelEmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_cancelled) {
        _cancelled = true;

        // 1. Delete Logic
        if (widget.triageId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('temp_triages')
                .doc(widget.triageId)
                .delete();
            print("Deleted Triage Doc: ${widget.triageId}");
          } catch (e) {
            print("Error deleting triage doc: $e");
          }
        }

        // 2. Navigate Home
        if (mounted) {
          context.go('/paramedic-home');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Emergency Cancelled"),
              backgroundColor: AppTheme.primaryAlert));
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _cancelled = false;
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        // Show tooltip if tapped normally
        if (!_cancelled) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Hold press to Cancel Emergency"),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.white10,
          ));
        }
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Timer Progress
            SizedBox(
              width: 40,
              height: 40,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _controller.value,
                    color: AppTheme.primaryAlert,
                    backgroundColor:
                        Colors.transparent, // Invisible when not pressing
                    strokeWidth: 3,
                  );
                },
              ),
            ),
            // The Cross Icon
            const Icon(Icons.close, color: AppTheme.textLight, size: 28),
          ],
        ),
      ),
    );
  }
}
