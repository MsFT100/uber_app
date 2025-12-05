import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/driver.dart';
import '../models/trip.dart';
import '../services/api_service.dart';

class AppStateProvider with ChangeNotifier {
  final ApiService _apiService;

  StreamSubscription<DocumentSnapshot>? _tripSubscription;

  Trip? _currentTrip;
  Driver? _driver;

  Trip? get currentTrip => _currentTrip;
  Driver? get driver => _driver;

  AppStateProvider({required ApiService apiService, String? accessToken})
      : _apiService = apiService {
    // Initialization logic can go here
  }

  // This is the entry point for push notifications
  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id']?.toString();

    if (id == null) {
      debugPrint("Notification received without a tripId.");
      return;
    }

    switch (type) {
      case 'DRIVER_ACCEPTED':
      case 'DRIVER_CANCELLED':
      case 'NO_DRIVERS_FOUND':
        debugPrint("Handling '$type' notification for tripId: $id");
        _fetchTripDetails(id);
        break;
      case 'TRIP_UPDATE': // Generic update
        debugPrint("Handling '$type' notification for tripId: $id");
        _fetchTripDetails(id);
        break;
      // Handle other notification types as needed
      default:
        debugPrint("Received unhandled notification type: $type");
    }
  }

  void _fetchTripDetails(String id) {
    _tripSubscription?.cancel();
    _tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentTrip = Trip.fromFirestore(snapshot);
        debugPrint(
            "Trip data updated from Firestore. New status: ${_currentTrip?.status}");

        // --- THE FIX: PARSE DRIVER DATA DIRECTLY FROM THE TRIP ---
        // Your backend adds a 'driver' map to the trip document.
        final tripData = snapshot.data() as Map<String, dynamic>;
        if (tripData.containsKey('driver') && tripData['driver'] != null) {
          // If the 'driver' field exists and is not null, parse it.
          _driver = Driver.fromMap(tripData['driver'] as Map<String, dynamic>);
        } else {
          // If the driver cancels or is not assigned, ensure the local driver object is null.
          _driver = null;
        }
        // --- END OF FIX ---
      } else {
        _clearTripState();
      }
      // This is the most important call. It will trigger all listeners in the UI.
      notifyListeners();
    });
  }

  Future<void> requestNewTrip(Trip trip, String accessToken) async {
    try {
      final tripData = await _apiService.requestTrip(
        accessToken: accessToken,
        vehicleType: trip.vehicleType,
        pickup: {'lat': trip.pickup.latitude, 'lng': trip.pickup.longitude},
        dropoff: {
          'lat': trip.destination.latitude,
          'lng': trip.destination.longitude
        },
      );

      final dynamic tripDetails = tripData['trip'];
      if (tripDetails != null && tripDetails['id'] != null) {
        final String id = tripDetails['id'].toString();
        _fetchTripDetails(id);
      } else {
        throw Exception("Trip ID was not found in the server response.");
      }
      // --- END OF FIX ---
    } catch (e) {
      debugPrint('Error requesting trip: $e');
      rethrow;
    }
  }

  Future<void> cancelTrip(String accessToken) async {
    if (_currentTrip?.id != null) {
      try {
        await _apiService.cancelTrip(
          tripId: _currentTrip!.id!,
          accessToken: accessToken,
        );
        _clearTripState();
      } catch (e) {
        debugPrint('Error cancelling trip: $e');
        rethrow;
      }
    }
  }

  Future<void> rateTrip(
      String tripId, int rating, String? comment, String accessToken) async {
    try {
      await _apiService.rateTrip(
        tripId: tripId,
        rating: rating,
        comment: comment,
        accessToken: accessToken,
      );
      // Maybe update the UI to show that the rating was submitted
    } catch (e) {
      debugPrint('Error rating trip: $e');
      rethrow;
    }
  }

  void _clearTripState() {
    _tripSubscription?.cancel();
    _tripSubscription = null;
    _currentTrip = null;
    _driver = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    super.dispose();
  }
}
