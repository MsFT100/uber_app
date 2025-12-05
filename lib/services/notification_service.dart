import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class NotificationService {
  // --- 1. ADD a GlobalKey for navigation from anywhere ---
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {



    // Get and print FCM token for testing
    if (kDebugMode) {
      final String? fcmToken = await _fcm.getToken();
      print("FCM Token: $fcmToken");
    }

    // Configure and initialize local notifications
    await _configureLocalNotifications();

    // Set up all FCM listeners
    _setupFcmListeners();

    // Handle a notification that may have launched the app
    _handleInitialMessage();
  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      // This handles taps on a notification when the app is already open (foreground/background)
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          _handleNotificationAction(data);
        }
      },
    );
  }

  void _setupFcmListeners() {
    // --- Handles messages when the app is in the FOREGROUND ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) print('Foreground message received: ${message.data}');
      // Show a local notification banner so the user sees it
      if (message.notification != null) {
        _showLocalNotification(message);
      }
      // You can also handle immediate UI updates here if needed
      _handleNotificationAction(message.data);
    });

    // --- Handles when a user TAPS a notification and the app opens from the BACKGROUND ---
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('Message opened from background: ${message.data}');
      _handleNotificationAction(message.data);
    });

  }

  // --- Handle a message that launched the app from a terminated state ---
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) print('App launched from terminated state by notification: ${initialMessage.data}');
      _handleNotificationAction(initialMessage.data);
    }
  }

  // --- Displays a local notification banner ---
  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'com.bucoride.urgent', // Channel ID
      'High Importance Notifications', // Channel Name
      channelDescription: 'This channel is used for important trip updates.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      // CRITICAL: The payload must contain the data needed for the action handler
      payload: jsonEncode(message.data),
    );
  }

  // --- 2. Central handler for all notification actions ---
  void _handleNotificationAction(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) print("Cannot handle notification action: Navigator context is null.");
      return;
    }

    final String? type = data['type']?.toString();
    if (kDebugMode) print("Handling notification action for type: $type");

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    switch (type) {
      case 'DRIVER_ACCEPTED':
      case 'DRIVER_CANCELLED':
      case 'NO_DRIVERS_FOUND':
      case 'TRIP_UPDATE': // A generic update type
      // The primary action is to tell the AppStateProvider to get the latest data.
      // The provider will then update its state, and the UI will react automatically.
        appState.handlePushNotification(data);
        break;

    // You can add other cases here for different notifications in the future
    // e.g., case 'PROMOTION_UNLOCKED':
    //   navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => PromotionsScreen()));
    //   break;

      default:
        if (kDebugMode) print("Received unhandled notification type in action handler: $type");
    }
  }
}
