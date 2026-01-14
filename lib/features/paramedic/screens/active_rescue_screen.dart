import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class ActiveRescueScreen extends ConsumerStatefulWidget {
  final String rescueId; // ID from 'paramedic_history'
  const ActiveRescueScreen({super.key, required this.rescueId});

  @override
  ConsumerState<ActiveRescueScreen> createState() => _ActiveRescueScreenState();
}

class _ActiveRescueScreenState extends ConsumerState<ActiveRescueScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _rescueData;

  @override
  void initState() {
    super.initState();
    _fetchRescueData();
  }

  Future<void> _fetchRescueData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('paramedic_history')
          .doc(widget.rescueId)
          .get();

      if (doc.exists) {
        if (mounted) {
          setState(() {
            _rescueData = doc.data();
            _isLoading = false;
          });
        }
      } else {
        // Document not found? Maybe already ended?
        if (mounted) context.go('/paramedic-home');
      }
    } catch (e) {
      print("Error fetching active rescue: $e");
    }
  }

  Future<void> _endRescue() async {
    try {
      // 1. Update Status to 'completed'
      await FirebaseFirestore.instance
          .collection('paramedic_history')
          .doc(widget.rescueId)
          .update({
        'status': 'completed',
        'end_time': FieldValue.serverTimestamp(),
      });

      // 2. Navigate Home
      if (mounted) {
        context.go('/paramedic-home');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Rescue Completed Successfully"),
            backgroundColor: AppTheme.successGreen));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error ending rescue: $e"),
          backgroundColor: AppTheme.primaryAlert));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAlert)),
      );
    }

    final isCompleted = _rescueData?['status'] == 'completed';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false, // FORCE COMPLETE CONTROL
        leading: isCompleted
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(
                        '/paramedic-home'); // Fallback to home if no history
                  }
                },
              )
            : null, // Absolutely NO leading widget for active rescue
        title: Text(isCompleted ? 'RESCUE DETAILS' : 'ACTIVE RESCUE',
            style: isCompleted
                ? const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
                : const TextStyle(
                    color: AppTheme.primaryAlert, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : AppTheme.primaryAlert.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.primaryAlert),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryAlert),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    const Icon(Icons.check_circle,
                        color: AppTheme.successGreen, size: 16),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      isCompleted
                          ? "RESCUE COMPLETED at ${_rescueData?['hospital_name'] ?? 'Hospital'}"
                          : "ON THE WAY TO ${_rescueData?['hospital_name'] ?? 'HOSPITAL'}",
                      style: TextStyle(
                          color: isCompleted
                              ? AppTheme.successGreen
                              : AppTheme.primaryAlert,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          Icons.medical_services,
                          "EMERGENCY",
                          _rescueData?['emergency_type'] ?? 'N/A',
                          Colors.white),
                      const Divider(color: Colors.white10, height: 30),
                      _buildInfoRow(
                          Icons.favorite,
                          "HEART RATE",
                          "${_rescueData?['heart_rate'] ?? '--'} BPM",
                          AppTheme.secondaryTrust),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          Icons.air,
                          "RESPIRATORY",
                          "${_rescueData?['respiratory_rate'] ?? '--'} breaths/min",
                          AppTheme.secondaryTrust),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          Icons.water_drop,
                          "SpO2",
                          "${_rescueData?['o2_saturation'] ?? '--'}",
                          AppTheme.secondaryTrust),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          Icons.compress,
                          "BP",
                          "${_rescueData?['blood_pressure'] ?? '--'}",
                          AppTheme.secondaryTrust),
                      const Divider(color: Colors.white10, height: 30),
                      const Text("AI ASSESSMENT:",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(
                          _rescueData?['clinical_impression'] ??
                              "No Assessment Data",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // End Rescue Button (ONLY SHOW IF ACTIVE)
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _endRescue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("END RESCUE",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2)),
                ),
              ),
            if (!isCompleted) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
