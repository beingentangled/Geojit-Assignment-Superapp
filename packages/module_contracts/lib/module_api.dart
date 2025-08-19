import 'route_registry.dart';

abstract class SuperModule {
  String get id;
  String get version;

  /// Register this module's routes. Return an entry route like '/home'.
  String registerRoutes(RouteRegistry registry);

  Future<void> onInit() async {}
  Future<void> onDispose() async {}
}
