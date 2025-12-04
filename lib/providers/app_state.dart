import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/driver.dart';
import '../models/trip.dart';
import '../services/api_service.dart';

class AppStateProvider with ChangeNotifier {
  final ApiService _apiService;
  final String? _accessToken;
  
  StreamSubscription<DocumentSnapshot>? _tripSubscription;

  Trip? _currentTrip;
  Driver? _driver;

  Trip? get currentTrip => _currentTrip;
  Driver? get driver => _driver;

  AppStateProvider({required ApiService apiService, String? accessToken})
      : _apiService = apiService,
        _accessToken = accessToken {
    // Initialization logic can go here
  }

  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'];
    final tripId = data['tripId'];

    switch (type) {
      case 'DRIVER_ACCEPTED':
      case 'TRIP_UPDATE':
        if (tripId != null) {
          _fetchTripDetails(tripId);
        }
        break;
      // Handle other notification types
    }
  }

  void _fetchTripDetails(String tripId) {
    _tripSubscription?.cancel();
    _tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentTrip = Trip.fromFirestore(snapshot);
        if (_currentTrip!.driverId != null) {
          // Assuming you have a way to fetch driver details by ID
          _fetchDriverDetails(_currentTrip!.driverId!);
        }
      } else {
        _clearTripState();
      }
      notifyListeners();
    });
  }

  Future<void> _fetchDriverDetails(String driverId) async {
    // This is a placeholder. You need to implement fetching driver details
    // from your backend or another Firestore collection.
    // For now, we'll create a dummy driver.
    try {
      // Example: final driverData = await _apiService.getDriver(driverId);
      // _driver = Driver.fromMap(driverData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching driver details: $e');
    }
  }

  Future<void> requestNewTrip(Trip trip, String accessToken) async {
    try {
      final tripData = await _apiService.requestTrip(
        accessToken: accessToken,
        pickup: {'lat': trip.pickup.latitude, 'lng': trip.pickup.longitude},
        dropoff: {'lat': trip.destination.latitude, 'lng': trip.destination.longitude},
      );
      _fetchTripDetails(tripData['id']);
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

  Future<void> rateTrip(String tripId, int rating, String? comment, String accessToken) async {
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
