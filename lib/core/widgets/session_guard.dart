import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';
import '../services/device_service.dart';
import '../../features/auth/services/auth_service.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();
  String? _localDeviceId;

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    final id = await _deviceService.getDeviceId();
    if (mounted) setState(() => _localDeviceId = id);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Always wrap with the outer StreamBuilder to maintain tree stability
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        // 2. If no user, just show content (stable node)
        if (user == null) {
          return widget.child;
        }

        // 3. User is Logged In - Check for Active Rescue! (SESSION RESTORE)
        if (ModalRoute.of(context)?.settings.name !=
            '/paramedic/active-rescue') {
          _checkActiveRescue(user.uid, context);
        }

        // 4. User present: Wrap with inner StreamBuilder (stable node)
        return StreamBuilder<String?>(
          stream: _authService.getDeviceStream(user.uid),
          builder: (context, deviceSnapshot) {
            // Logic only runs if we have both remote and local IDs
            if (deviceSnapshot.hasData && _localDeviceId != null) {
              final remoteDeviceId = deviceSnapshot.data;

              if (remoteDeviceId != null && remoteDeviceId != _localDeviceId) {
                // Grace Period: Prevents "Login Gap" race condition.
                // When logging in, Auth updates before Firestore.
                // We wait 2 seconds to let the Firestore local write catch up.
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await Future.delayed(const Duration(seconds: 2));

                  // Re-verify after delay
                  // verifySession returns TRUE if device matches (Valid)
                  // verifySession returns FALSE if mismatch (Invalid)
                  final isValidSession = await _authService.verifySession();

                  if (!isValidSession) {
                    if (mounted && FirebaseAuth.instance.currentUser != null) {
                      await _authService.signOut();
                      try {
                        router.go('/');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'You have been logged out because your account was accessed from another device.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      } catch (e) {
                        print('Navigation Error during logout: $e');
                      }
                    }
                  }
                });
              }
            }
            // Always return child, session check happens in background
            return widget.child;
          },
        );
      },
    );
  }

  Future<void> _checkActiveRescue(String uid, BuildContext context) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('paramedic_history')
          .where('user_id', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final rescueId = query.docs.first.id;
        print(
            "SessionGuard: Found active rescue $rescueId. Restoring session...");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/paramedic/active-rescue', extra: rescueId);
        });
      }
    } catch (e) {
      print("SessionGuard Error checking active rescue: $e");
    }
  }
}
