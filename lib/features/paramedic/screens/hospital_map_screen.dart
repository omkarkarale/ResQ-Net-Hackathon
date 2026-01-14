import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      onRoute: () async {
                        if (triageId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Error: No Triage Data Found!"),
                                  backgroundColor: AppTheme.primaryAlert));
                          return;
                        }

                        // 1. Move Data: Temp -> Permanent History
                        try {
                          final tempRef = FirebaseFirestore.instance
                              .collection('temp_triages')
                              .doc(triageId);
                          final tempSnapshot = await tempRef.get();

                          if (tempSnapshot.exists) {
                            final tempData = tempSnapshot.data()!;

                            // 1.5. AUTO-COMPLETE Previous Active Rescues
                            // Ensure only ONE rescue is active at a time.
                            final staleRescues = await FirebaseFirestore
                                .instance
                                .collection('paramedic_history')
                                .where('user_id',
                                    isEqualTo: tempData['user_id'])
                                .where('status', isEqualTo: 'active')
                                .get();

                            for (var doc in staleRescues.docs) {
                              await doc.reference.update({
                                'status': 'completed',
                                'end_time': FieldValue.serverTimestamp(),
                                'auto_completed':
                                    true, // Optional flag for debugging
                              });
                            }

                            // Add Rescue Metadata
                            final historyRef = await FirebaseFirestore.instance
                                .collection('paramedic_history')
                                .add({
                              ...tempData,
                              'hospital_name': hospital.name,
                              'hospital_location': GeoPoint(
                                  hospital.latitude,
                                  hospital
                                      .longitude), // If you have coordinates
                              'status':
                                  'active', // CRITICAL FOR SESSION RESTORE
                              'start_time': FieldValue.serverTimestamp(),
                            });

                            // 2. Delete Temp
                            await tempRef.delete();

                            // 3. Clear Cleanup Provider (Handled manually)
                            ref.read(cleanupTriageIdProvider.notifier).state =
                                null;

                            // 4. Launch Maps (Robust Logic)
                            try {
                              final lat = hospital.latitude;
                              final lng = hospital.longitude;
                              final googleMapsSameScheme =
                                  Uri.parse("google.navigation:q=$lat,$lng");
                              final googleMapsWebScheme = Uri.parse(
                                  "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");

                              if (await canLaunchUrl(googleMapsSameScheme)) {
                                await launchUrl(googleMapsSameScheme);
                              } else {
                                // Fallback: Open in Browser / Standard Intent
                                print(
                                    "Maps Intent failed, trying Web Scheme...");
                                if (await canLaunchUrl(googleMapsWebScheme)) {
                                  await launchUrl(googleMapsWebScheme,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Could not open Maps"),
                                          backgroundColor:
                                              AppTheme.primaryAlert));
                                }
                              }
                            } catch (e) {
                              print("Maps Launch Error: $e");
                            }

                            // 5. Navigate to Active Rescue Screen
                            if (context.mounted) {
                              context.go('/paramedic/active-rescue',
                                  extra: historyRef.id);
                            }
                          }
                        } catch (e) {
                          print("Routing Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Failed to start rescue: $e"),
                              backgroundColor: AppTheme.primaryAlert));
                        }
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

class _CancelEmergencyButton extends ConsumerStatefulWidget {
  final String? triageId;
  const _CancelEmergencyButton({this.triageId});

  @override
  ConsumerState<_CancelEmergencyButton> createState() =>
      _CancelEmergencyButtonState();
}

class _CancelEmergencyButtonState extends ConsumerState<_CancelEmergencyButton>
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

            // CLEAR CLEANUP PROVIDER (So LifecycleManager doesn't try to delete again)
            ref.read(cleanupTriageIdProvider.notifier).state = null;

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
