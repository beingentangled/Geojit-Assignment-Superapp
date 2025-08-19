import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_api.dart';
import 'package:module_contracts/route_registry.dart';

class HomeModule extends SuperModule {
  @override
  String get id => "home";

  @override
  String get version => "0.0.1";

  @override
  String registerRoutes(RouteRegistry registry) {
    registry.add(GoRoute(
      path: '/home',
      builder: (ctx, state) => const HomeScreen(),
    ));
    return '/home';
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/profile'),
              child: const Text("Go to Profile"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/jobs'),
              child: const Text("Go to Jobs"),
            ),
          ],
        ),
      ),
    );
  }
}
