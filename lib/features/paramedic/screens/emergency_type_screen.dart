import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class EmergencyTypeScreen extends StatelessWidget {
  const EmergencyTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SELECT EMERGENCY TYPE'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildTypeCard(context, 'Cardiac', const Color(0xFFFF5252),
                  Icons.favorite, '/patient-input'),
              _buildTypeCard(context, 'Trauma', const Color(0xFFFF9800),
                  Icons.healing, '/patient-input'),
              _buildTypeCard(context, 'Respiratory', const Color(0xFF448AFF),
                  Icons.air, '/patient-input'),
              _buildTypeCard(context, 'Stroke', const Color(0xFF9C27B0),
                  Icons.psychology, '/patient-input'),
              _buildTypeCard(context, 'Pregnancy', const Color(0xFFE91E63),
                  Icons.pregnant_woman, '/patient-input'),
              _buildTypeCard(context, 'Pediatric', const Color(0xFF009688),
                  Icons.child_care, '/patient-input'),
              _buildTypeCard(context, 'Burns', const Color(0xFFFF5722),
                  Icons.local_fire_department, '/patient-input'),
              _buildTypeCard(context, 'Overdose', const Color(0xFF673AB7),
                  Icons.medication, '/patient-input'),
              _buildTypeCard(context, 'Mass Casualty', const Color(0xFFD32F2F),
                  Icons.warning_amber_rounded, '/patient-input'),
              _buildTypeCard(context, 'Other', Colors.blueGrey,
                  Icons.more_horiz, '/patient-input'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(BuildContext context, String title, Color color,
      IconData icon, String route) {
    return GestureDetector(
      onTap: () {
        context.push(route, extra: title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
