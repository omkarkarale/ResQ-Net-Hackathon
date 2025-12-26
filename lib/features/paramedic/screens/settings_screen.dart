import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _highContrast = false;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.black,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('GENERAL'),
            _buildSwitchTile(
              'Notifications',
              'Receive alerts for dispatch',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildSwitchTile(
              'Offline Mode',
              'Save data locally when no signal',
              _offlineMode,
              (v) => setState(() => _offlineMode = v),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('DISPLAY'),
            _buildSwitchTile(
              'High Contrast',
              'Increase visibility for outdoors',
              _highContrast,
              (v) => setState(() => _highContrast = v),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('ACCOUNT'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Paramedic Unit 402', style: TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () {},
            ),
            const Divider(color: Colors.white12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.logout, color: Colors.white)),
              title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.secondaryTrust, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.secondaryTrust,
    );
  }
}
