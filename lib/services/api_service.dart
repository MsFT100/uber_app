import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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


      // This is the request body that will be sent.
      final requestBody = jsonEncode({'fcmToken': fcmToken});
      debugPrint('Request Body: $requestBody'); // Logging the actual body being sent.

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: requestBody,
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
    required String vehicleType,
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
          'vehicleType': vehicleType,
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

    Future<Map<String, dynamic>> initiateMpesaStkPush({
    required String accessToken,
    required int tripId,
    required String phone,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/payments/mpesa/stk-push');
      debugPrint('Initiating STK push with URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'tripId': tripId,
          'phone': phone,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('STK push initiated successfully: $responseBody');
        return responseBody;
      } else {
        debugPrint('Failed to initiate STK push: ${response.body}');
        throw Exception(responseBody['error'] ?? 'Failed to initiate STK push.');
      }
    } catch (e) {
      debugPrint('An error occurred during STK push initiation: $e');
      rethrow;
    }
  }

  // Methods for Places API via proxy

  Future<List<dynamic>> searchPlacesProxy({
    required String accessToken,
    required String query,
    required String sessiontoken,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/api/maps/search-places').replace(queryParameters: {
      'input': query,
      'sessiontoken': sessiontoken,
    });
    debugPrint('Searching places with URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['predictions'] as List<dynamic>;
    } else {
      throw Exception(
          'Failed to search places. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetailsProxy({
    required String accessToken,
    required String placeId,
    required String sessiontoken,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/api/maps/place-details').replace(queryParameters: {
      'placeId': placeId,
      'sessiontoken': sessiontoken,
    });
    debugPrint('Getting place details with URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    debugPrint('Place Details Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['details'] as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to get place details. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // ... (other methods like loginRider, registerRider, etc. are fine)

  Future<Map<String, dynamic>?> getDirectionsProxy({
    required String accessToken,
    required LatLng origin,
    required LatLng destination,
    // REMOVED: No longer need vehicleType here
    // required String vehicleType,
  }) async {
    final uri =
    Uri.parse('$_baseUrl/api/maps/directions').replace(queryParameters: {
      'originLat': origin.latitude.toString(),
      'originLng': origin.longitude.toString(),
      'destinationLat': destination.latitude.toString(),
      'destinationLng': destination.longitude.toString(),
      // REMOVED: 'vehicleType': vehicleType,
    });
    debugPrint('Getting directions with URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['route'] as Map<String, dynamic>?;
    } else {
      throw Exception(
          'Failed to get directions. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // ADDED: New method for the dedicated fare estimation endpoint
  Future<Map<String, dynamic>> getFareEstimate({
    required String accessToken,
    required LatLng pickup,
    required LatLng dropoff,
  }) async {
    final url = Uri.parse('$_baseUrl/api/trips/estimate');
    debugPrint('Getting fare estimate with URL: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
        'dropoff': {'lat': dropoff.latitude, 'lng': dropoff.longitude},
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      debugPrint('Fare estimate successful: $responseBody');
      return responseBody['data'] as Map<String, dynamic>;
    } else {
      debugPrint('Failed to get fare estimate: ${response.body}');
      throw Exception(responseBody['error'] ?? 'Failed to get fare estimate.');
    }
  }
}


