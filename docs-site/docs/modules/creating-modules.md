# Creating Your First Module

## Module Development Masterclass

Learn how to create powerful, independent modules that integrate seamlessly into the SuperApp ecosystem.

## Module Anatomy

Every module in our architecture follows a strict contract that ensures consistency, testability, and independence.

### Basic Module Structure

```
your_module/
├── lib/
│   ├── your_module.dart       # Main module export
│   ├── screens/
│   │   └── your_screen.dart   # UI components
│   ├── services/
│   │   └── your_service.dart  # Business logic
│   └── models/
│       └── your_model.dart    # Data models
├── test/
│   └── your_module_test.dart  # Unit tests
└── pubspec.yaml               # Dependencies
```

## Step-by-Step Module Creation

### Step 1: Create Module Package

```bash
# From superapp root
cd modules
flutter create --template=package your_feature_module
cd your_feature_module
```

### Step 2: Configure Dependencies

```yaml
# pubspec.yaml
name: your_feature_module
description: A feature module for the SuperApp
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^12.0.0
  module_contracts:
    path: ../../packages/module_contracts

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Step 3: Implement Module Contract

```dart
// lib/your_feature_module.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_api.dart';
import 'package:module_contracts/route_registry.dart';

import 'screens/your_feature_screen.dart';

class YourFeatureModule extends SuperModule {
  @override
  String get id => 'your_feature';

  @override
  String get version => '1.0.0';

  @override
  String registerRoutes(RouteRegistry registry) {
    // Register main route
    registry.add(GoRoute(
      path: '/your-feature',
      builder: (context, state) => const YourFeatureScreen(),
    ));

    // Register sub-routes
    registry.add(GoRoute(
      path: '/your-feature/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return YourFeatureDetailScreen(id: id);
      },
    ));

    return '/your-feature'; // Entry route
  }

  @override
  Future<void> onInit() async {
    // Initialize module-specific services
    await YourFeatureService.initialize();
  }

  @override
  Future<void> onDispose() async {
    // Clean up resources
    await YourFeatureService.dispose();
  }
}
```

### Step 4: Create Screen Components

```dart
// lib/screens/your_feature_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class YourFeatureScreen extends StatefulWidget {
  const YourFeatureScreen({super.key});

  @override
  State<YourFeatureScreen> createState() => _YourFeatureScreenState();
}

class _YourFeatureScreenState extends State<YourFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Feature'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Your Feature Module!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a completely independent module that can be developed, tested, and deployed separately.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/your-feature/details/123');
              },
              child: const Text('View Details'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class YourFeatureDetailScreen extends StatelessWidget {
  final String id;
  
  const YourFeatureDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $id'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Detail View for ID: $id',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/your-feature'),
              child: const Text('Back to Feature'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: Add Business Logic Service

```dart
// lib/services/your_feature_service.dart
class YourFeatureService {
  static YourFeatureService? _instance;
  static YourFeatureService get instance => _instance!;

  bool _initialized = false;

  static Future<void> initialize() async {
    _instance = YourFeatureService();
    await _instance!._init();
  }

  Future<void> _init() async {
    // Initialize service dependencies
    _initialized = true;
    print('YourFeatureService initialized');
  }

  static Future<void> dispose() async {
    _instance?._initialized = false;
    _instance = null;
    print('YourFeatureService disposed');
  }

  // Business logic methods
  Future<List<String>> fetchData() async {
    if (!_initialized) throw StateError('Service not initialized');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return ['Item 1', 'Item 2', 'Item 3'];
  }
}
```

### Step 6: Write Comprehensive Tests

```dart
// test/your_feature_module_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_feature_module/your_feature_module.dart';
import 'package:your_feature_module/services/your_feature_service.dart';
import 'package:module_contracts/route_registry.dart';

void main() {
  group('YourFeatureModule', () {
    late YourFeatureModule module;
    late RouteRegistry registry;

    setUp(() {
      module = YourFeatureModule();
      registry = RouteRegistry();
    });

    test('has correct id and version', () {
      expect(module.id, equals('your_feature'));
      expect(module.version, equals('1.0.0'));
    });

    test('registers routes correctly', () {
      final entryRoute = module.registerRoutes(registry);
      
      expect(entryRoute, equals('/your-feature'));
      expect(registry.routes, hasLength(2));
      expect(registry.routes[0].path, equals('/your-feature'));
      expect(registry.routes[1].path, equals('/your-feature/details/:id'));
    });

    test('initializes and disposes properly', () async {
      await module.onInit();
      expect(YourFeatureService.instance, isNotNull);
      
      await module.onDispose();
      // Verify cleanup
    });
  });

  group('YourFeatureService', () {
    setUp(() async {
      await YourFeatureService.initialize();
    });

    tearDown(() async {
      await YourFeatureService.dispose();
    });

    test('fetches data correctly', () async {
      final data = await YourFeatureService.instance.fetchData();
      expect(data, hasLength(3));
      expect(data, contains('Item 1'));
    });
  });
}
```

### Step 7: Register Module in Main App

```dart
// lib/main.dart (in main app)
import 'package:your_feature_module/your_feature_module.dart';

void main() {
  final registry = ModuleRegistry()
    ..register(HomeModule())
    ..register(ProfileModule())
    ..register(JobsModule())
    ..register(YourFeatureModule()); // Add your module

  runApp(SuperApp(registry: registry));
}
```

## Advanced Module Patterns

### State Management Integration

```dart
// Using BLoC pattern within module
class YourFeatureModule extends SuperModule {
  late YourFeatureBloc _bloc;

  @override
  Future<void> onInit() async {
    _bloc = YourFeatureBloc();
  }

  @override
  String registerRoutes(RouteRegistry registry) {
    registry.add(GoRoute(
      path: '/your-feature',
      builder: (context, state) => BlocProvider.value(
        value: _bloc,
        child: const YourFeatureScreen(),
      ),
    ));
    return '/your-feature';
  }
}
```

### Inter-Module Communication

```dart
// Define shared events in module_contracts
abstract class ModuleEvents {
  static const String userUpdated = 'user_updated';
  static const String navigationRequested = 'navigation_requested';
}

// In your module
class YourFeatureModule extends SuperModule {
  @override
  Future<void> onInit() async {
    // Listen to events from other modules
    EventBus.instance.on(ModuleEvents.userUpdated, _handleUserUpdate);
  }

  void _handleUserUpdate(dynamic data) {
    // React to user updates from other modules
  }

  void _triggerNavigation() {
    // Communicate with other modules
    EventBus.instance.emit(ModuleEvents.navigationRequested, {
      'route': '/your-feature/special',
      'data': {'key': 'value'}
    });
  }
}
```

### Feature Flags Integration

```dart
class YourFeatureModule extends SuperModule {
  @override
  String registerRoutes(RouteRegistry registry) {
    if (FeatureFlags.isEnabled('your_feature_v2')) {
      registry.add(GoRoute(
        path: '/your-feature',
        builder: (context, state) => const YourFeatureV2Screen(),
      ));
    } else {
      registry.add(GoRoute(
        path: '/your-feature',
        builder: (context, state) => const YourFeatureScreen(),
      ));
    }
    return '/your-feature';
  }
}
```

## Module Best Practices

### 1. **Independence First**
- Never import from other modules directly
- Use contracts for all external communication
- Maintain separate dependency trees

### 2. **Error Boundaries**
```dart
class YourFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error, stackTrace) {
        // Log error but don't crash the app
        ModuleLogger.error('YourFeature', error, stackTrace);
      },
      child: YourFeatureContent(),
    );
  }
}
```

### 3. **Performance Optimization**
```dart
class YourFeatureModule extends SuperModule {
  @override
  String registerRoutes(RouteRegistry registry) {
    registry.add(GoRoute(
      path: '/your-feature',
      builder: (context, state) => const YourFeatureScreen(),
      // Lazy loading for heavy modules
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const YourFeatureScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ));
    return '/your-feature';
  }
}
```

### 4. **Testing Strategy**
```bash
# Run module tests in isolation
cd modules/your_feature_module
flutter test

# Integration testing with main app
cd ../../
flutter test integration_test/your_feature_integration_test.dart
```

## Module Deployment

### Independent Deployment Pipeline

```yaml
# .github/workflows/your-feature-module.yml
name: Your Feature Module CI/CD

on:
  push:
    paths:
      - 'modules/your_feature_module/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: |
          cd modules/your_feature_module
          flutter pub get
          flutter test
          flutter analyze

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Module
        run: |
          # Update module version in app
          # Trigger app rebuild with new module
```

## Congratulations!

You've created a fully independent, testable, and deployable module that integrates seamlessly with the SuperApp architecture. Your module can now:

- ✅ Be developed by an independent team
- ✅ Be tested in isolation
- ✅ Be deployed independently
- ✅ Handle its own state and routing
- ✅ Communicate with other modules safely

## Next Steps

- [Architecture Overview](../architecture/overview.md)
- [Framework Comparisons](../comparisons/framework-comparison.md)
