import 'package:example/pages/forces/forces_route.dart';
import 'package:example/pages/home/home_route.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        ...HomeRoute.builder,
        ...ForcesRoute.builder,
      };
}
