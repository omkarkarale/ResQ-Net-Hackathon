import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'router.dart';
import 'firebase_options.dart';
import 'core/widgets/session_guard.dart';
import 'core/widgets/lifecycle_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ResQNetApp()));
}

class ResQNetApp extends StatelessWidget {
  const ResQNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ResQ-Net',
      debugShowCheckedModeBanner: false,

      // Theme Setup
      themeMode: ThemeMode
          .system, // Or explicit based on login, but currently dynamic per screen
      theme: AppTheme.paramedicTheme, // Default light
      darkTheme: AppTheme.paramedicTheme, // Default dark

      // Router Setup
      routerConfig: router,
      builder: (context, child) => SessionGuard(
        child: LifecycleManager(child: child!),
      ),
    );
  }
}
