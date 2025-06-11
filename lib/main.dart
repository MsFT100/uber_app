import 'dart:io';

import 'package:BucoRide/providers/app_state.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/providers/user.dart';
import 'package:BucoRide/screens/permission_gate.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/firebase_api.dart';
import 'firebase_options.dart';
import 'locators/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    //appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );
  //debugToken: 45d13be1-c481-4b69-89f8-3763b80bdf90
  // Wait a bit before requesting the token to avoid race conditions
  await Future.delayed(Duration(seconds: 2));

  try {
    String? appCheckToken = await FirebaseAppCheck.instance.getToken(true);
    debugPrint("🔥 Firebase App Check Debug Token: $appCheckToken");
  } catch (e) {
    debugPrint("❌ Error fetching App Check token: $e");
  }

  FirebaseApi firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  setupLocator();
  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
    ],
    child: MaterialApp(
      //navigatorKey: firebaseApi.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: LocationPermissionGate(), // display this screen before the splash screen
    ),
  ));
}
