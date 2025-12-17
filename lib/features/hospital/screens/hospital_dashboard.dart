import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/state.dart';
import '../../../models/data_models.dart';

class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: AppTheme.hospitalTheme,
      child: Scaffold(
        body: Row(
          children: [
            // SIDEBAR
            Container(
              width: 250,
              color: const Color(0xFFF0F2F5),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: [
                        Icon(Icons.local_hospital, color: AppTheme.secondaryTrust, size: 32),
                        SizedBox(width: 12),
                        Text('ResQ-Net', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                  _SidebarItem(icon: Icons.dashboard, label: 'Dashboard', isSelected: true),
                  _SidebarItem(icon: Icons.bedroom_child, label: 'Bed Inventory', isSelected: false),
                  _SidebarItem(icon: Icons.history, label: 'Incoming History', isSelected: false),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('City General Hospital\nLogged in as Dr. Smith', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.black12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Command Center', style: Theme.of(context).textTheme.headlineSmall),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now()),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(32),
                      children: [
                        // STATS ROW
                        const Row(
                          children: [
                            Expanded(child: _StatusCard(title: 'ICU Beds', count: '3 / 20', color: AppTheme.primaryAlert)),
                            SizedBox(width: 24),
                            Expanded(child: _StatusCard(title: 'General Ward', count: '15 / 50', color: AppTheme.secondaryTrust)),
                            SizedBox(width: 24),
                            Expanded(child: _SpecialistCard()),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // ALERTS SECTION
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppTheme.primaryAlert, size: 32),
                            SizedBox(width: 12),
                            Text('Live Incoming Ambulances', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // ALERTS LIST
                        Consumer(
                          builder: (context, ref, _) {
                            final alerts = ref.watch(alertsProvider);
                            if (alerts.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(48),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: const Text('No incoming alerts active.', style: TextStyle(color: Colors.grey)),
                              );
                            }
                            return Column(
                              children: alerts.map((alert) => _AlertCard(alert: alert)).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _SidebarItem({required this.icon, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.secondaryTrust : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.secondaryTrust : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _StatusCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              Switch(value: true, onChanged: (_) {}, activeColor: color),
            ],
          ),
          const SizedBox(height: 16),
          Text(count, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          const Text('Available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specialists On-Site', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 16),
          _SpecialistRow(label: 'Cardiologist', isAvailable: true),
          const SizedBox(height: 8),
          _SpecialistRow(label: 'Neurologist', isAvailable: false),
        ],
      ),
    );
  }
}

class _SpecialistRow extends StatelessWidget {
  final String label;
  final bool isAvailable;
  
  const _SpecialistRow({required this.label, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isAvailable ? Icons.check_circle : Icons.cancel, 
             color: isAvailable ? AppTheme.successGreen : Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AmbulanceAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert.isCritical ? AppTheme.primaryAlert : Colors.black12, width: alert.isCritical ? 2 : 1),
        boxShadow: alert.isCritical 
            ? [BoxShadow(color: AppTheme.primaryAlert.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)] 
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryAlert.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_share, color: AppTheme.primaryAlert, size: 32),
          ),
          const SizedBox(width: 24),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Ambulance #${alert.ambulanceId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                      child: Text(alert.emergencyType.toUpperCase(), style: const TextStyle(color: AppTheme.primaryAlert, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('ETA: ${alert.eta}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy, size: 16, color: AppTheme.secondaryTrust),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Summary: ${alert.notes}',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Actions
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: const Text('Acknowledge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryTrust,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () {}, child: const Text('View Vitals')),
            ],
          ),
        ],
      ),
    );
  }
}
