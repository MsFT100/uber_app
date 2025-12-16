import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/driver.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import 'location_provider.dart';

class AppStateProvider with ChangeNotifier {
  final ApiService _apiService;
  LocationProvider? _locationProvider; // Add a reference to LocationProvider

  StreamSubscription<DocumentSnapshot>? _tripSubscription;

  Trip? _currentTrip;
  Driver? _driver;

  Trip? get currentTrip => _currentTrip;
  Driver? get driver => _driver;

  AppStateProvider({required ApiService apiService}) : _apiService = apiService;

  // Method to link providers
  void setLocationProvider(LocationProvider provider) {
    _locationProvider = provider;
  }

  // This is the entry point for push notifications
  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'];
    // FIX: Prioritize 'tripId' from the notification payload, fall back to 'id'.
    final id = (data['tripId'] ?? data['id'])?.toString();

    if (id == null) {
      debugPrint("Notification received without a tripId.");
      return;
    }

    switch (type) {
      case 'DRIVER_ACCEPTED':
        debugPrint("Handling '$type' notification for tripId: $id");
        // For DRIVER_ACCEPTED, the driver info is in the notification payload.
        // We can parse it and update the UI state immediately for a faster response.
        _driver = Driver.fromMap(data);
        _locationProvider?.show = Show.DRIVER_FOUND;
        notifyListeners(); // Notify UI to switch to the DriverFoundWidget
        _fetchTripDetails(id,
            initialDriver:
                _driver); // Fetch full trip details in the background
        break;
      case 'DRIVER_CANCELLED':
      case 'NO_DRIVERS_FOUND':
      case 'DRIVER_ARRIVED':
      case 'TRIP_STARTED':
      case 'TRIP_COMPLETED':
      case 'TRIP_UPDATE': // Generic update
        debugPrint("Handling '$type' notification for tripId: $id");
        // For other updates, we don't have driver data in the payload, so we pass null.
        _fetchTripDetails(id, initialDriver: null);
        break;
      // Handle other notification types as needed
      default:
        debugPrint("Received unhandled notification type: $type");
    }
  }

  void _fetchTripDetails(String id, {Driver? initialDriver}) {
    _tripSubscription?.cancel();
    if (initialDriver != null) {
      _driver = initialDriver;
    }
    _tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentTrip = Trip.fromFirestore(snapshot);

        debugPrint(
            "Trip data updated from Firestore. New status: ${_currentTrip?.status}");

        // This logic is now more robust:
        // Only try to parse the driver from Firestore if we haven't already received
        // it from a previous push notification (i.e., _driver is null).
        if (initialDriver == null && _driver == null) {
          final tripData = snapshot.data() as Map<String, dynamic>;
          if (tripData.containsKey('driver') && tripData['driver'] != null) {
            // If the 'driver' field exists, parse it.
            // --- DEBUGGING: Print the raw driver data from Firestore ---
            debugPrint("Raw driver data from Firestore: ${tripData['driver']}");
            // --- END DEBUGGING ---

            _driver =
                Driver.fromMap(tripData['driver'] as Map<String, dynamic>);
          } else {
            // If not, ensure the local driver object is null.
            _driver = null;
          }
        }

        // Notify LocationProvider to start its own listeners
        _locationProvider?.listenToTrip(id);
        // Update the UI state in LocationProvider based on the trip status
        switch (_currentTrip?.status) {
          case TripStatus.requested:
          case TripStatus.no_drivers_found:
            _locationProvider?.show = Show.SEARCHING_DRIVER;
            break;
          case TripStatus.accepted:
          case TripStatus.en_route_to_pickup:
            _locationProvider?.show = Show.DRIVER_FOUND;
            break;
          case TripStatus.arrived_at_pickup: // Fallthrough
          case TripStatus.in_progress:
            _locationProvider?.show = Show.TRIP;
            break;
          case TripStatus.completed:
          case TripStatus.cancelled_by_driver:
          case TripStatus.cancelled_by_rider:
            _locationProvider?.cancelRideRequest(); // Resets to default
            break;
          default:
            break;
        }
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
        _fetchTripDetails(id, initialDriver: null);
      } else {
        throw Exception("Trip ID was not found in the server response.");
      }
      // --- END OF FIX ---
    } catch (e) {
      debugPrint('Error requesting trip: $e');
      rethrow;
    }
  }

  Future<void> requestNewParcelTrip({
    required Map<String, dynamic> parcelData,
    required String vehicleType,
    required String accessToken,
  }) async {
    try {
      final LatLng pickupCoords = parcelData['pickupCoordinates'];
      final LatLng dropoffCoords = parcelData['dropoffCoordinates'];

      final tripData = await _apiService.requestParcelTrip(
        accessToken: accessToken,
        vehicleType: vehicleType,
        pickup: {
          'address': parcelData['pickupAddress'],
          'lat': pickupCoords.latitude,
          'lng': pickupCoords.longitude
        },
        dropoff: {
          'address': parcelData['dropoffAddress'],
          'lat': dropoffCoords.latitude,
          'lng': dropoffCoords.longitude
        },
        parcelDetails: {
          'recipientName': parcelData['recipientName'],
          'recipientPhone': parcelData['recipientPhone'],
          'description': parcelData['description'],
          'size': parcelData['size'],
        },
      );

      final String tripId = tripData['trip']['id'].toString();
      _fetchTripDetails(tripId, initialDriver: null);
    } catch (e) {
      debugPrint('Error requesting parcel trip: $e');
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
      debugPrint("Rating submitted successfully.");
    } catch (e) {
      debugPrint('Error rating trip: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required int tripId,
    required String phone,
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.initiateMpesaStkPush(
        accessToken: accessToken,
        tripId: tripId,
        phone: phone,
      );
      return response;
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      rethrow;
    }
  }

  // --- CHAT METHODS ---

  Stream<QuerySnapshot> getChatMessages(String tripId) {
    return FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendChatMessage(
      {required String tripId,
      required String text,
      required String senderId}) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp()
    });
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
