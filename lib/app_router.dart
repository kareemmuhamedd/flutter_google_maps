import 'package:flutter/material.dart';
import 'package:flutter_maps/presentation/screens/login_screen.dart';
import 'package:flutter_maps/presentation/screens/otp_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) =>  LoginScreen(),
        );

      case OtpScreen.routeName:
        return MaterialPageRoute(
          builder: (_) =>  OtpScreen(phoneNumber: '123'),
        );
    }
    return null;
  }
}
