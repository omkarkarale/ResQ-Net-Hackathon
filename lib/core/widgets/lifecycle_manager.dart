import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state.dart';

class LifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  const LifecycleManager({super.key, required this.child});

  @override
  ConsumerState<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends ConsumerState<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performStartupCleanup();
  }

  void _performStartupCleanup() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Cleaning up any left-over data from previous sessions
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('temp_triages')
              .where('user_id', isEqualTo: user.uid)
              .get();

          if (snapshot.docs.isNotEmpty) {
            print(
                "LifecycleManager: Found ${snapshot.docs.length} stale triages. Deleting...");
            for (var doc in snapshot.docs) {
              await doc.reference.delete();
            }
          }
        } catch (e) {
          print("LifecycleManager: Startup Cleanup Error: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _performCleanup();
    }
  }

  Future<void> _performCleanup() async {
    final triageId = ref.read(cleanupTriageIdProvider);
    if (triageId != null) {
      print("LifecycleManager: Cleaning up triage doc: $triageId");
      try {
        await FirebaseFirestore.instance
            .collection('temp_triages')
            .doc(triageId)
            .delete();
        // We probably can't update state here reliably if detached, but good practice
        // ref.read(cleanupTriageIdProvider.notifier).state = null;
      } catch (e) {
        print("LifecycleManager: Cleanup error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
