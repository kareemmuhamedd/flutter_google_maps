import 'package:flutter/material.dart';
import 'package:flutter_maps/presentation/screens/login_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) =>  LoginScreen(),
        );
    }
    return null;
  }
}
