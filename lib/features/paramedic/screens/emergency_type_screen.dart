import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/state.dart';

class EmergencyTypeScreen extends ConsumerWidget {
  const EmergencyTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = [
      {'label': 'Cardiac', 'icon': Icons.favorite, 'color': Colors.red},
      {'label': 'Trauma', 'icon': Icons.medical_services, 'color': Colors.orange},
      {'label': 'Respiratory', 'icon': Icons.air, 'color': Colors.blue},
      {'label': 'Stroke', 'icon': Icons.psychology, 'color': Colors.purple},
      {'label': 'Pregnancy', 'icon': Icons.child_friendly, 'color': Colors.pink},
      {'label': 'Pediatric', 'icon': Icons.child_care, 'color': Color(0xFF00897B)}, // Teal
      {'label': 'Burns', 'icon': Icons.local_fire_department, 'color': Color(0xFFEF6C00)}, // Orange
      {'label': 'Overdose', 'icon': Icons.medication_liquid, 'color': Color(0xFF5E35B1)}, // Purple
      {'label': 'Other', 'icon': Icons.emergency_share, 'color': Colors.grey},
    ];

    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Emergency Type'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return _TypeButton(
                label: type['label'] as String,
                icon: type['icon'] as IconData,
                color: type['color'] as Color,
                onTap: () {
                  ref.read(selectedEmergencyTypeProvider.notifier).state = type['label'] as String;
                  context.go('/paramedic/severity');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.secondaryTrust.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
