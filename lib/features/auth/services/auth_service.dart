import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/device_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceService _deviceService = DeviceService();

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  /// Sign in with Operator ID (mapped to email) and PIN (mapped to password)
  Future<UserCredential?> signIn({
    required String operatorId,
    required String pin,
  }) async {
    try {
      // PROVISIONAL: Map ID to email for this Hackathon
      // User enters "AMB-01", we translate to "amb-01@resqnet.com"
      // This avoids needing a real email for every user in the UI
      final email = _formatEmail(operatorId);

      // 1. Parallelize Device ID fetch (Async) ensuring it runs while waiting for Auth
      final deviceIdFuture = _deviceService.getDeviceId();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pin,
      );

      // Single Device Enforcement Logic
      if (credential.user != null) {
        final deviceId = await deviceIdFuture;
        final deviceModel = await _deviceService.getDeviceModel();

        // 2. Optimistic Write: Don't await server confirmation.
        // Firestore updates local cache immediately, so SessionGuard will see it.
        // This saves 1-2 seconds of latency.
        _firestore.collection('users').doc(credential.user!.uid).set({
          'currentDeviceId': deviceId,
          'currentDeviceModel': deviceModel,
          'lastLogin': FieldValue.serverTimestamp(),
          // 'role': 'paramedic' or 'hospital' (Can be set manually in DB for now)
        }, SetOptions(merge: true)).ignore();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuth Error: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify if the current device matches the one in Firestore
  Future<bool> verifySession() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final currentDeviceId = await _deviceService.getDeviceId();
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return true; // Fail safe

      final registeredDeviceId = doc.data()?['currentDeviceId'] as String?;

      if (registeredDeviceId != null && registeredDeviceId != currentDeviceId) {
        // Mismatch!
        return false;
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Session Verification Error: $e');
      return true; // Fail safe
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to format ID to Email
  String _formatEmail(String id) {
    if (id.contains('@')) return id; // Already an email
    return '${id.trim().toLowerCase()}@resqnet.com';
  }

  /// Stream of the current valid Device ID from Firestore
  Stream<String?> getDeviceStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['currentDeviceId'] as String?);
  }
}
