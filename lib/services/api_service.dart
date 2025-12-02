import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/rider.dart';

class ApiService {
  static final String _baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> registerRider({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/riders/register');
      debugPrint('Registering Rider with URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'name': name,
          'phone': phone,
          'email': email,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        debugPrint('Rider registered successfully: $responseBody');
        return responseBody['rider'] as Map<String, dynamic>;
      } else {
        debugPrint('Failed to register rider: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to register rider.');
      }
    } catch (e) {
      debugPrint('An error occurred during registration: $e');
      rethrow;
    }
  }

  Future<({String accessToken, Rider rider})> loginRider(String firebaseToken, {String? fcmToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/api/riders/login');
      debugPrint('Logging in with URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('Login successful.');
        final rider = Rider.fromMap(responseBody['rider'] as Map<String, dynamic>);
        final accessToken = responseBody['accessToken'] as String;

        return (accessToken: accessToken, rider: rider);
      } else {
        debugPrint('Failed to login: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to login.');
      }
    } catch (e) {
      debugPrint('An error occurred during login: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestTrip({
    required String accessToken,
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    String tripType = 'ride',
    Map<String, dynamic>? parcelDetails,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/trips/request');
      debugPrint('Requesting a new trip with URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'tripType': tripType,
          'pickup': pickup,
          'dropoff': dropoff,
          'parcelDetails': parcelDetails,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        debugPrint('Trip created successfully: $responseBody');
        return responseBody;
      } else {
        debugPrint('Failed to create trip: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to create trip.');
      }
    } catch (e) {
      debugPrint('An error occurred during trip creation: $e');
      rethrow;
    }
  }

  Future<void> cancelTrip({
    required String tripId,
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/trips/$tripId/cancel');
      debugPrint('Cancelling trip with URL: $url');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        debugPrint('Failed to cancel trip: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to cancel trip.');
      }
    } catch (e) {
      debugPrint('An error occurred during trip cancellation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rateTrip({
    required String tripId,
    required int rating,
    String? comment,
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/trips/$tripId/rate');
      debugPrint('Rating trip with URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        debugPrint('Trip rated successfully: $responseBody');
        return responseBody;
      } else {
        debugPrint('Failed to rate trip: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to rate trip.');
      }
    } catch (e) {
      debugPrint('An error occurred during trip rating: $e');
      rethrow;
    }
  }
}
