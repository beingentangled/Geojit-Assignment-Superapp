import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_api.dart';
import 'package:module_contracts/route_registry.dart';

class JobsModule extends SuperModule {
  @override
  String get id => 'jobs';

  @override
  String get version => '0.0.1';

  @override
  String registerRoutes(RouteRegistry registry) {
    registry.add(GoRoute(
      path: '/jobs',
      builder: (ctx, state) => const JobsScreen(),
    ));
    return '/jobs';
  }
}

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: const Center(child: Text('Jobs Module')),
    );
  }
}
