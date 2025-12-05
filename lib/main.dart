import 'dart:convert';

import 'package:BucoRide/providers/app_state.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/providers/user_provider.dart';
import 'package:BucoRide/screens/auth/auth_wrapper.dart';
import 'package:BucoRide/services/api_service.dart';
import 'package:BucoRide/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';


// Initialize local notifications for background message display
final FlutterLocalNotificationsPlugin _localNotifications =
FlutterLocalNotificationsPlugin();
// This is the required top-level function for handling background messages.
// It must be outside of a class.
// --- 2. IMPLEMENT THE BACKGROUND HANDLER CORRECTLY ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for this background isolate
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("--- Handling a background message ---");
    print("Title: ${message.notification?.title}");
    print("Data: ${message.data}");
  }

  // If the message has a visible notification part, we need to show it manually
  // using flutter_local_notifications for consistency and tap handling.
  if (message.notification != null) {
    // Create an instance of the local notifications plugin
    final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

    // Initialize it (a lightweight initialization is enough for the background)
    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Define the details for the notification appearance
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'com.bucoride.urgent', // This channel ID should match your main one
      'High Importance Notifications',
      channelDescription: 'This channel is used for important trip updates.',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Show the notification
    await localNotifications.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(android: androidDetails),
      // The payload will be used to handle the tap action
      payload: jsonEncode(message.data),
    );
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If you use Firebase, initialize it here:
  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // if using FlutterFire CLI
  );

  // Initialize local notifications for background message handling
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);
  await _localNotifications.initialize(initSettings);

  // Set the background messaging handler.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {

  // --- FIX 2: INITIALIZE NOTIFICATION SERVICE IN initState ---
  @override
  void initState() {
    super.initState();
    // This call is crucial. It sets up all foreground listeners and tap handlers.
    NotificationService().initialize();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide a single instance of ApiService
        Provider<ApiService>(create: (_) => ApiService()),

        // UserProvider depends on nothing
        ChangeNotifierProvider(create: (_) => UserProvider.initialize()),

        // AppStateProvider depends on ApiService
        ChangeNotifierProxyProvider<ApiService, AppStateProvider>(
          create: (_) => AppStateProvider(apiService: ApiService()), // Initial dummy
          update: (context, apiService, previous) => AppStateProvider(apiService: apiService),
        ),
        
        // LocationProvider depends on ApiService and UserProvider
        ChangeNotifierProxyProvider2<UserProvider, ApiService, LocationProvider>(
          create: (context) => LocationProvider(apiService: context.read<ApiService>()),
          update: (context, userProvider, apiService, previousLocationProvider) =>
              LocationProvider(
            apiService: apiService,
            accessToken: userProvider.accessToken,
          ),
        ),
      ],

      child: MaterialApp(
        navigatorKey: NotificationService.navigatorKey,
        home: AuthWrapper(), // Your app's new entry point
      ),
    );
  }
}