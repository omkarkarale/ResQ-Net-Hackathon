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
                  Icons.psychology, '/patient-input'), // brain icon equivalent
              _buildTypeCard(context, 'Pregnancy', const Color(0xFFE91E63),
                  Icons.pregnant_woman, '/patient-input'),
              _buildTypeCard(context, 'Other', Colors.grey, Icons.more_horiz,
                  '/patient-input'),
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
        context.push(route);
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
