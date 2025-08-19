import 'package:go_router/go_router.dart';

class RouteRegistry {
  final List<GoRoute> _routes = <GoRoute>[];
  void add(GoRoute route) => _routes.add(route);
  List<GoRoute> get routes => List.unmodifiable(_routes);
}
