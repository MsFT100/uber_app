import 'package:BucoRide/providers/user_provider.dart';
import 'package:BucoRide/screens/auth/login.dart';
import 'package:BucoRide/screens/home.dart';
import 'package:BucoRide/screens/splash.dart';
import 'package:BucoRide/widgets/loading_widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    switch (userProvider.status) {
      case Status.Uninitialized:
        return SplashScreen();
      case Status.Authenticating:
        return Loading();
      case Status.Authenticated:
        return HomePage();
      case Status.Unauthenticated:
      return LoginScreen();
    }
  }
}