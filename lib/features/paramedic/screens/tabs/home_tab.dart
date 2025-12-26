import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme.dart';

class ParamedicHomeTab extends StatelessWidget {
  const ParamedicHomeTab({super.key});

  String _getDynamicHeader(User? user) {
    if (user?.email == null) return 'AMBULANCE';

    // email format: id@resqnet.com -> split to get 'id'
    final idPart = user!.email!.split('@')[0].toUpperCase();

    // Strict requirement: Only expand 'AMB-' to 'AMBULANCE '
    if (idPart.startsWith('AMB-')) {
      return idPart.replaceFirst('AMB-', 'AMBULANCE ');
    }

    return idPart;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  return Text(
                    _getDynamicHeader(snapshot.data),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Icon(Icons.gps_fixed, color: AppTheme.successGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'GPS: STRONG',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Big Red Button
        Center(
          child: GestureDetector(
            onTap: () {
              context.push('/emergency-type');
            },
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryAlert,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAlert.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: AppTheme.primaryAlert.withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'START\nINTAKE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Spacer(),

        // Bottom status or version could go here
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            'RESQ-NET MOBILE v1.0',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
