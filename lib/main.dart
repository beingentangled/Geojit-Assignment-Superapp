import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// feature modules
import 'package:home_module/home_module.dart';
import 'package:jobs_module/jobs_module.dart';
import 'package:module_contracts/module_api.dart';
import 'package:module_contracts/route_registry.dart';
import 'package:profile_module/profile_module.dart';

class ModuleRegistry {
  final List<SuperModule> _modules = [];
  void register(SuperModule module) => _modules.add(module);
  List<SuperModule> get modules => List.unmodifiable(_modules);
}

void main() {
  final registry = ModuleRegistry()
    ..register(HomeModule())
    ..register(ProfileModule())
    ..register(JobsModule());

  runApp(SuperApp(registry: registry));
}

class SuperApp extends StatelessWidget {
  final ModuleRegistry registry;
  const SuperApp({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    final routeRegistry = RouteRegistry();
    String? defaultRoute;

    for (final m in registry.modules) {
      final entryRoute = m.registerRoutes(routeRegistry);
      // Set the first module's entry route as default
      defaultRoute ??= entryRoute;
    }

    // Add a root route that redirects to the default module
    routeRegistry.add(
      GoRoute(path: '/', redirect: (context, state) => defaultRoute ?? '/home'),
    );

    final router = GoRouter(
      routes: routeRegistry.routes,
      initialLocation: defaultRoute ?? '/home',
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Route not found: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(defaultRoute ?? '/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Super App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
