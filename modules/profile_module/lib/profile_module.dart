import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_api.dart';
import 'package:module_contracts/route_registry.dart';

class ProfileModule extends SuperModule {
  @override
  String get id => 'profile';

  @override
  String get version => '0.0.1';

  @override
  String registerRoutes(RouteRegistry registry) {
    registry.add(GoRoute(
      path: '/profile',
      builder: (ctx, state) => const ProfileScreen(),
    ));
    return '/profile';
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        automaticallyImplyLeading: true,
      ),
      body: const Center(child: Text('Profile Module')),
    );
  }
}
