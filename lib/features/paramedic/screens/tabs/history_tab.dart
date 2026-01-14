import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';

class ParamedicHistoryTab extends StatelessWidget {
  const ParamedicHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Intake History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('paramedic_history')
            .where('user_id', isEqualTo: uid)
            .orderBy('start_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // ... [Keep Error Logic same if needed, or simplify]
            return Center(
                child: Text('Data Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off,
                      size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text('No history records found',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final type = data['emergency_type'] as String? ?? 'General';
              final hospital =
                  data['hospital_name'] as String? ?? 'Unknown Hospital';
              final status = data['status'] as String? ?? 'Completed';
              final timestamp = data['start_time'] as Timestamp?;

              // Determine Color based on Type
              Color typeColor = Colors.grey;
              if (type == 'Cardiac')
                typeColor = Colors.red;
              else if (type == 'Trauma')
                typeColor = Colors.orange;
              else if (type == 'Respiratory')
                typeColor = Colors.blue;
              else
                typeColor = AppTheme.primaryAlert;

              // Format Date
              final dateStr = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                  : 'N/A';

              return InkWell(
                onTap: () {
                  // Navigate to Detail View (Reusing ActiveRescue for now)
                  // Use push to allow going back
                  context.push('/paramedic/active-rescue',
                      extra: docs[index].id);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history, color: typeColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Text(
                              hospital,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                              color: _getStatusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successGreen;
      case 'enroute':
        return Colors.orange;
      case 'admitted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
