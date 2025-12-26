import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme.dart';
import '../../../auth/services/auth_service.dart';

class ParamedicProfileTab extends StatefulWidget {
  const ParamedicProfileTab({super.key});

  @override
  State<ParamedicProfileTab> createState() => _ParamedicProfileTabState();
}

class _ParamedicProfileTabState extends State<ParamedicProfileTab> {
  final _authService = AuthService();
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryAlert,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Name/ID
            Text(
              _user?.email?.split('@')[0].toUpperCase() ?? 'UNKNOWN',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Paramedic Unit',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Info Cards
            _buildInfoCard(Icons.badge, 'Operator ID',
                _user?.email?.split('@')[0].toUpperCase() ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.email, 'Contact', _user?.email ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.perm_device_information, 'Session ID',
                _user?.uid.substring(0, 8) ?? 'N/A'),

            const SizedBox(height: 48),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _authService.signOut();
                  // Router will handle redirect
                },
                icon: const Icon(Icons.logout),
                label: const Text('END SHIFT (LOGOUT)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
