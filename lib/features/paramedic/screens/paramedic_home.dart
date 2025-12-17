import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';

class ParamedicHomeScreen extends StatelessWidget {
  const ParamedicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force Dark Theme for Paramedic App
    return Theme(
      data: AppTheme.paramedicTheme,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Status Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.secondaryTrust),
                        SizedBox(width: 8),
                        Text('Unit 402 - Mumbai, India', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt, color: Colors.green),
                        SizedBox(width: 8),
                        const Text('GPS Strong', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main CTA
              Center(
                child: Animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  effects: [ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms)],
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryAlert.withOpacity(0.1),
                      border: Border.all(color: AppTheme.primaryAlert.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAlert.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => context.go('/paramedic/emergency-type'),
                        customBorder: const CircleBorder(),
                        splashColor: AppTheme.primaryAlert.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emergency, size: 64, color: AppTheme.primaryAlert),
                              const SizedBox(height: 16),
                              Text(
                                'START\nINTAKE',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 32,
                                  color: AppTheme.primaryAlert,
                                  shadows: [
                                    const Shadow(blurRadius: 10, color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
              
              const Text('ResQ-Net Active', style: TextStyle(color: Colors.white30)),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: AppTheme.secondaryTrust,
          unselectedItemColor: Colors.white54,
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) context.push('/paramedic/history');
            if (index == 2) context.push('/paramedic/settings');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
