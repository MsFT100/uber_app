import 'dart:io';
import 'package:flutter/foundation.dart';

/// A configuration class to manage environment-specific variables.
class AppConfig {
  // Private constructor to prevent instantiation of this class.
  AppConfig._();


// TODO: Add your Google Maps API key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // --- Production URL ---
  // TODO: Replace with your actual online backend URL.
  static const String _prodBaseUrl =
      'https://buco-ride-payment-system.vercel.app';

  // --- Development URL ---
  // This getter dynamically provides the correct localhost URL for the platform.
  static String get _devBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // For web
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001'; // Use 10.0.2.2 for Android emulator
    }
    // For iOS simulator, macOS, etc.
    return 'http://localhost:3000';
  }

  /// Returns the appropriate base URL based on the build mode.
  ///
  /// In `release` mode, it returns the production URL.
  /// In `debug` or `profile` mode, it returns the development URL.
  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;
}
