import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/device_service.dart';
import '../services/auth_service.dart';
import '../../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isPinVisible = false;

  bool _isLoading = false;
  final _authService = AuthService();
  final _deviceService = DeviceService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    // 1. Check if user is already signed in (Firebase persists session)
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      // 2. Verify Session (Device Check)
      setState(() => _isLoading = true);
      final isValidDevice = await _authService.verifySession();
      if (!mounted) return;

      if (!isValidDevice) {
        // Invalid Device -> Logout
        await _authService.signOut();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session invalid. Please login again.')),
        );
        return;
      }

      // 3. Prompt Biometrics
      try {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        if (canCheckBiometrics) {
          final didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Please authenticate to access ResQ-Net',
            options: const AuthenticationOptions(stickyAuth: true),
          );

          if (didAuthenticate) {
            // DOUBLE CHECK: Race Condition Fix
            // Ensure session is STILL valid after the biometric delay.
            // (Another device might have logged in while the prompt was open)
            final isStillValid = await _authService.verifySession();

            if (isStillValid) {
              _navigate(currentUser.email!);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Session Expired: Account accessed elsewhere.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              await _authService.signOut();
              setState(() => _isLoading = false);
            }
            return;
          } else {
            // Cancelled or Failed -> Exit App (Preserve Session)
            // If they cancel, they probably didn't mean to open the app,
            // or they can just reopen to try again.
            // We DO NOT signOut here, to avoid the delay next time.
            SystemNavigator.pop();
          }
        }
      } catch (e) {
        // Biometric error, fall back to PIN (Stay on screen)
        print('Biometric error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _navigate(String email) {
    if (email.contains('admin') || email.startsWith('h')) {
      context.go('/hospital-dashboard');
    } else {
      context.go('/paramedic-home');
    }
  }

  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (id.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Operator ID and PIN')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(operatorId: id, pin: pin);

      if (!mounted) return;

      // Routing Logic
      // Assuming email is set correctly by AuthService logic
      final userEmail =
          _authService.currentUser?.email ?? _idController.text; // Fallback
      _navigate(userEmail);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'Operator ID not registered';
      } else if (e.code == 'wrong-password') {
        message = 'Invalid PIN';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid Format';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.primaryAlert,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = AppTheme.darkBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title
                Image.asset(
                  'assets/images/resq_logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'EMERGENCY RESPONSE SYSTEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 3.0,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 64),

                // Inputs (No Toggle)
                TextField(
                  controller: _idController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                          text: newValue.text.toUpperCase());
                    }),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'OPERATOR ID',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                    hintText: 'e.g. AMB-402 or ADMIN',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  obscureText: !_isPinVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'SECURE PIN',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isPinVisible = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isPinVisible = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _isPinVisible = false;
                        });
                      },
                      child: Icon(
                        _isPinVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Authenticate Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.primaryAlert, // Consistent Brand Color
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryAlert.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'INITIATE SESSION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 24),
                Center(
                    child: TextButton(
                        onPressed: () => _showHelpDialog(context),
                        child: const Text(
                          'Need Help?',
                          style: TextStyle(color: Colors.grey),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: AppTheme.primaryAlert),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Technical Support',
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: FutureBuilder<Map<String, String>>(
            future: _getDeviceInfo(),
            builder: (context, snapshot) {
              final deviceId = snapshot.data?['id'] ?? 'Loading...';
              final deviceModel = snapshot.data?['model'] ?? '...';

              return SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Emergency Hotline
                  InkWell(
                    onTap: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: '108',
                      );
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAlert.withOpacity(0.1),
                        border: Border.all(
                            color: AppTheme.primaryAlert.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.phone_in_talk,
                              color: AppTheme.primaryAlert),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('EMERGENCY DISPATCH',
                                    style: TextStyle(
                                        color: AppTheme.primaryAlert,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                Text('+91 108',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Device Info for IT
                  const Text('Device Identity (For IT Whitelist):',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: deviceId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Device ID Copied')),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deviceId,
                              style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold)),
                          Text(deviceModel,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '• Contact Supervisor for PIN Resets\n• Accounts are Hospital-Managed',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ));
            }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final id = await _deviceService.getDeviceId();
    final model = await _deviceService.getDeviceModel();
    return {'id': id, 'model': model};
  }
}
