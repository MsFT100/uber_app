import 'package:BucoRide/providers/user_provider.dart';
import 'package:BucoRide/screens/auth/login.dart';
import 'package:BucoRide/screens/home.dart';
import 'package:BucoRide/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    switch (userProvider.status) {
      case Status.Uninitialized:
        return const SplashScreen();

      case Status.Authenticating:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case Status.Authenticated:
        return const HomePage();

      case Status.Unauthenticated:
        return const LoginScreen();

      }
  }
}