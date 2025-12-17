import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget buildTestApp({required GoRouter router, ProviderContainer? container}) {
  final app = MaterialApp.router(routerConfig: router);

  if (container != null) {
    return UncontrolledProviderScope(container: container, child: app);
  }

  return ProviderScope(child: app);
}
