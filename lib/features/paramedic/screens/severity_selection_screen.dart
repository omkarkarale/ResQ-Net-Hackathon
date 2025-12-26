import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/state.dart';

class SeveritySelectionScreen extends ConsumerWidget {
  const SeveritySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyType = ref.watch(selectedEmergencyTypeProvider);

    final severityLevels = [
      {'level': 'Critical', 'color': const Color(0xFFD32F2F), 'icon': Icons.warning}, // Dark Red
      {'level': 'Severe', 'color': const Color(0xFFE53935), 'icon': Icons.error}, // Red
      {'level': 'Moderate', 'color': const Color(0xFFEF6C00), 'icon': Icons.report_problem}, // Orange
      {'level': 'Mild', 'color': const Color(0xFFFDD835), 'icon': Icons.info}, // Yellow
      {'level': 'Stable', 'color': const Color(0xFF43A047), 'icon': Icons.check_circle}, // Green
    ];

    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Severity'),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white10,
              child: Text(
                'TYPE: ${emergencyType?.toUpperCase() ?? "UNKNOWN"}',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: severityLevels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final level = severityLevels[index];
                  return _SeverityButton(
                    label: level['level'] as String,
                    color: level['color'] as Color,
                    icon: level['icon'] as IconData,
                    onTap: () {
                      // Store severity if needed in state, for now we just proceed
                      context.go('/paramedic/hospital-map');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SeverityButton({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 24),
              Text(
                label.toUpperCase(),
                style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
