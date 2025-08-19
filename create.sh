cat > scaffold_superapp.sh <<'EOS'
set -euo pipefail

# melos & shorebird
mkdir -p packages modules
cat > melos.yaml <<'YAML'
name: superapp
packages:
  - packages/**
  - modules/**
YAML

cat > shorebird.yaml <<'YAML'
app_id: com.example.superapp
YAML

# ----- module_contracts -----
mkdir -p packages/module_contracts/lib
cat > packages/module_contracts/pubspec.yaml <<'YAML'
name: module_contracts
description: Contracts and shared interfaces for super app modules.
version: 0.0.1

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^7.1.0
YAML

cat > packages/module_contracts/lib/route_registry.dart <<'DART'
import 'package:go_router/go_router.dart';

class RouteRegistry {
  final List<GoRoute> _routes = <GoRoute>[];
  void add(GoRoute route) => _routes.add(route);
  List<GoRoute> get routes => List.unmodifiable(_routes);
}
DART

cat > packages/module_contracts/lib/module_api.dart <<'DART'
import 'route_registry.dart';

abstract class SuperModule {
  String get id;
  String get version;

  /// Register this module's routes. Return an entry route like '/home'.
  String registerRoutes(RouteRegistry registry);

  Future<void> onInit() async {}
  Future<void> onDispose() async {}
}
DART

# ----- home_module -----
mkdir -p modules/home_module/lib
cat > modules/home_module/pubspec.yaml <<'YAML'
name: home_module
description: The home module of the super app.
version: 0.0.1

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^7.1.0
  module_contracts:
    path: ../../packages/module_contracts
YAML

cat > modules/home_module/lib/home_module.dart <<'DART'
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
              onPressed: () => context.go('/profile'),
              child: const Text("Go to Profile"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/jobs'),
              child: const Text("Go to Jobs"),
            ),
          ],
        ),
      ),
    );
  }
}
DART

# ----- profile_module -----
mkdir -p modules/profile_module/lib
cat > modules/profile_module/pubspec.yaml <<'YAML'
name: profile_module
description: The profile module of the super app.
version: 0.0.1

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^7.1.0
  module_contracts:
    path: ../../packages/module_contracts
YAML

cat > modules/profile_module/lib/profile_module.dart <<'DART'
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
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Module')),
    );
  }
}
DART

# ----- jobs_module -----
mkdir -p modules/jobs_module/lib
cat > modules/jobs_module/pubspec.yaml <<'YAML'
name: jobs_module
description: The jobs module of the super app.
version: 0.0.1

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^7.1.0
  module_contracts:
    path: ../../packages/module_contracts
YAML

cat > modules/jobs_module/lib/jobs_module.dart <<'DART'
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
DART

echo "Scaffold complete."
EOS

bash scaffold_superapp.sh