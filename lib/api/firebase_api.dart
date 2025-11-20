import 'package:BucoRide/helpers/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool hasNewRideRequest = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initNotifications() async {
    // Request permission
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');

      // Get FCM Token
      final fcmToken = await _firebaseMessaging.getToken();
      print("📌 FCM Token: $fcmToken");

      // Foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📩 New Notification: ${message.notification?.title}");

        // Show local notification for foreground messages
        _showNotification(message);

        // Handle driver & request ID
        if (message.data.isNotEmpty) {
          String? driverId = message.data['driverId'];
          String? requestId = message.data['id'];

          print("🔹 Driver ID: $driverId");
          print("🔹 Request ID: $requestId");

          if (message.data['type'] == 'REQUEST_ACCEPTED') {
            setDriver();
          }
        }
      });

      // Handle notification click when the app is in the **background**
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📂 Notification Clicked: ${message.notification?.title}");
        //_handleRideRequest(message);
      });

      // Handle notification when the app is **terminated** (cold start)
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print("🚀 App launched via notification");
        //_handleRideRequest(initialMessage);
      }
    } else {
      print('❌ User denied notification permission');
    }
  }

  void setDriver() {
    showDriverSheet = true;
    // 🚨 Make sure the UI gets updated (use ChangeNotifier or setState)
  }

  void _handleRideRequest(RemoteMessage message) {
    if (message.data['type'] == "RIDE_REQUEST") {
      hasNewRideRequest = true;

      // Extract ride request details
      Map<String, dynamic> requestData = {
        "username": message.data['username'],
        "destination": message.data['destination'],
        "distance_text": message.data['distance_text'],
        "distance_value": int.parse(message.data['distance_value']),
        "destination_latitude":
            double.parse(message.data['destination_latitude']),
        "destination_longitude":
            double.parse(message.data['destination_longitude']),
        "user_latitude": double.parse(message.data['user_latitude']),
        "user_longitude": double.parse(message.data['user_longitude']),
        "id": message.data['id'],
        "userId": message.data['userId'],
      };

      // 🚀 Navigate to Ride Request Screen
      //navigatorKey.currentState?.pushNamed('/rideDetails', arguments: requestData);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ride_request_channel', // Unique channel ID
      'Ride Responses', // Channel Name
      channelDescription: 'Notifications for driver responses',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Ensure this exists in your app
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? "You Have Found A Driver",
      message.notification?.body ?? "Your Driver will Arrive shortly",
      notificationDetails,
    );
  }
}
