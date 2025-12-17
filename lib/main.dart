import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'core/theme.dart';

void main() {
  runApp(const ProviderScope(child: ResQNetApp()));
}

class ResQNetApp extends StatelessWidget {
  const ResQNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ResQ-Net',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.hospitalTheme, // Default Light for Hospital
      darkTheme: AppTheme.paramedicTheme, // Dark for Paramedic
      themeMode: ThemeMode.system, // Will control this via state if needed, but system is fine for now
      routerConfig: router,
    );
  }
}
