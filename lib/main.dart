import 'dart:io';

import 'package:BucoRide/screens/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import './firebase_options.dart';
import './providers/app_state.dart';
import './providers/location_provider.dart';
import './providers/user_provider.dart';
import './screens/auth/login.dart';
import './services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  // Set up providers
  final appState = AppStateProvider();

  // Initialize NotificationService
  final notificationService = NotificationService(appState: appState);
  await notificationService.initialize();

  runApp(MyApp(appState: appState, notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final AppStateProvider appState;
  final NotificationService notificationService;

  const MyApp({Key? key, required this.appState, required this.notificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => UserProvider.initialize()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'BucoRide',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer<UserProvider>(
          builder: (context, user, _) {
            switch (user.status) {
              case Status.Uninitialized:
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              case Status.Unauthenticated:
              case Status.Authenticating:
                return LoginScreen();
              case Status.Authenticated:
                return Menu();
            }
          },
        ),
      ),
    );
  }
}
