import 'dart:async';
import 'dart:ui' as ui;

import 'package:BucoRide/services/api_service.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/driver.dart';
import '../models/route.dart';
import '../utils/images.dart';

enum Show {
  CONFIRMATION_SELECTION,
  DESTINATION_SELECTION,
  PICKUP_SELECTION,
  VEHICLE_SELECTION,
  PAYMENT_METHOD_SELECTION,
  DRIVER_FOUND,
  TRIP,
  TRIP_COMPLETE,
  SEARCHING_DRIVER
}

class LocationProvider with ChangeNotifier {
  final ApiService _apiService;
  final String? _accessToken;

  static const PICKUP_MARKER_ID = 'pickup';
  static const LOCATION_MARKER_ID = 'location';
  static const DESTINATION_MARKER_ID = 'destination';
  static const ADDRESS_MARKER_ID = 'address';

  Show _show = Show.DESTINATION_SELECTION;
  bool _isSearching = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _tripStreamSubscription;
  String? locationAddress;
  RouteModel? routeModel;
  Timer? _debounce;
  String _riderAddress = 'Loading...';
  static LatLng _center = LatLng(0, 0);

  LatLng? destinationCoordinates;
  LatLng pickupCoordinates = _center;
  LatLng _lastPosition = _center;

  String? tripId;
  String? tripStatus;
  Driver? driver;
  String? _sessionToken;
  String selectedVehicleType = 'sedan'; // Default vehicle type

  List<dynamic> _predictions = [];

  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor endIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor addressIcon = BitmapDescriptor.defaultMarker;

  Show get show => _show;
  set show(Show newShow) {
    _show = newShow;
    notifyListeners();
  }
  bool get isSearching => _isSearching;
  Position? get currentPosition => _currentPosition;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  String get riderAddress => _riderAddress;
  Set<Polyline> get polylines => _polylines;
  LatLng get center => _center;
  List<dynamic> get predictions => _predictions;

  //--- NEW PROPERTIES FOR ANIMATION ---
  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;

  LocationProvider({required ApiService apiService, String? accessToken})
      : _apiService = apiService,
        _accessToken = accessToken {
  }

  Future<void> Initialize(TickerProvider vsync) async {

    // --- INITIALIZE ANIMATION CONTROLLER ---
    _bounceController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: vsync);
    _bounceAnimation = CurvedAnimation(
        parent: _bounceController!, curve: Curves.bounceOut);
    _bounceAnimation!.addListener(() {
      notifyListeners();
    });
    // --- END INITIALIZATION ---
    await _loadCustomMarkers();
    await fetchLocation();
    _startPositionStream();
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    _positionStreamSubscription?.cancel();
    _tripStreamSubscription?.cancel();
    _debounce?.cancel();
    pickupLocationController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  void onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    if (_show == Show.PICKUP_SELECTION) {
      _lastPosition = position.target;
      pickupCoordinates = _lastPosition;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () async {
        try {
          List<Placemark> placemark = await placemarkFromCoordinates(
              position.target.latitude, position.target.longitude);
          pickupLocationController.text = placemark.isNotEmpty
              ? placemark[0].street ?? 'Unknown location'
              : 'Unknown location';
        } catch (e) {
          pickupLocationController.text = 'Unknown location';
        }
        notifyListeners();
      });
    }
  }

  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) return;
      }

      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _currentPosition = lastKnownPosition;
        _center = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        _addCurrentLocationMarker(_center);
      }

      // FIX: Use LocationSettings instead of the deprecated desiredAccuracy
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _addCurrentLocationMarker(_center);
      await setLocationAddress();

    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> setLocationAddress() async {
    try {
      if (_currentPosition == null) return;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);
      if (placemarks.isNotEmpty) {
        locationAddress =
        "${placemarks.first.street}, ${placemarks.first.locality}";
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('address', locationAddress!);
      }
    } catch (e) {
      print("Error setting location address: $e");
    }
    notifyListeners();
  }

  void _startPositionStream() {
    if (_currentPosition == null) return;

    final locationSettings =
    LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition = position;
      _center = LatLng(position.latitude, position.longitude);
      _addCurrentLocationMarker(_center);
      notifyListeners();
    });
  }

  void listenToTrip(String currentTripId) {
    tripId = currentTripId;
    _tripStreamSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        tripStatus = data['status'];

        if (data.containsKey('driver') && data.containsKey('driver_location')) {
          driver = Driver.fromMap(data['driver']);
          final location = data['driver_location'] as GeoPoint;
          final driverPosition = LatLng(location.latitude, location.longitude);
          _updateDriverMarker(driverPosition, driver!.name);
        } else {
          driver = null;
          _markers.removeWhere((m) => m.markerId.value == 'driver');
        }

        handleTripStatus(tripStatus);
      }
    });
  }

  void handleTripStatus(String? status) {
    if (status == null) return;

    switch (status) {
      case 'requested':
        show = Show.SEARCHING_DRIVER;
        break;
      case 'accepted':
      case 'en_route_to_pickup':
      case 'arrived_at_pickup':
        show = Show.DRIVER_FOUND;
        break;
      case 'in_progress':
        show = Show.TRIP;
        break;
      case 'completed':
        show = Show.TRIP_COMPLETE;
        break;
      default:
        show = Show.DESTINATION_SELECTION;
        break;
    }
  }

  void _updateDriverMarker(LatLng driverPosition, String driverName) {
    _markers.removeWhere((m) => m.markerId.value == 'driver');
    _markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: driverPosition,
      icon: carIcon,
      infoWindow: InfoWindow(title: driverName),
    ));
    notifyListeners();
  }

  void _addCurrentLocationMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == LOCATION_MARKER_ID);
    _markers.add(Marker(
      markerId: MarkerId(LOCATION_MARKER_ID),
      position: position,
      icon: markerIcon,
    ));
  }

  void selectVehicle(String vehicleType) {
    // Normalize vehicleType values so different callers (menu buttons,
    // programmatic selections) map to the labels used in the UI.
    final key = vehicleType.toLowerCase();
    switch (key) {
      case 'motorbike':
      case 'motor bike':
        selectedVehicleType = 'Motorbike';
        break;
      case 'sedan':
      case 'car':
        selectedVehicleType = 'Sedan';
        break;
      case 'van':
        selectedVehicleType = 'Van';
        break;
      case 'tuk-tuk':
      case 'tuktuk':
      case 'tuk_tuk':
        selectedVehicleType = 'Tuk-Tuk';
        break;
      default:
        // Use provided label if unknown — UI will attempt to resolve it.
        selectedVehicleType = vehicleType;
    }
    notifyListeners();
  }

  Future<void> getRouteAndEstimate() async {
    try {
      if (_accessToken == null || destinationCoordinates == null) {
        print("API Service, access token, or destination not initialized.");
        return;
      }

      // UPDATED: Make two API calls in parallel for speed
      final results = await Future.wait([
        _apiService.getDirectionsProxy(
          accessToken: _accessToken,
          origin: _center,
          destination: destinationCoordinates!,
        ),
        _apiService.getFareEstimate(
          accessToken: _accessToken,
          pickup: _center,
          dropoff: destinationCoordinates!,
        )
      ]);

      final routeData = results[0];
      final fareData = results[1] as Map<String, dynamic>;

      if (routeData != null) {
        final encodedPolyline = routeData['polyline'];

        // Parse the list of fares from the new endpoint's response
        final List<Fare> fareList = (fareData['fares'] as List)
            .map((fareMap) => Fare.fromMap(fareMap))
            .toList();

        routeModel = RouteModel(
          points: encodedPolyline,
          distance: Distance.fromMap(routeData['distance']),
          timeNeeded: TimeNeeded.fromMap(routeData['duration']),
          // Pass the list of fares to the model
          fares: fareList,
          startAddress: pickupLocationController.text,
          endAddress: destinationController.text,
        );

        _addDestinationMarker(_center, destinationCoordinates!);

        _polylines.add(Polyline(
          polylineId: const PolylineId('rider_route'),
          points: _decodePolyline(encodedPolyline),
          color: AppConstants.lightPrimary,
          width: 5,
        ));
      }
    } catch (e) {
      print("Error getting route and estimate: $e");
    }
    // We notify listeners here after all async work is done
    notifyListeners();
  }

  void _addDestinationMarker(LatLng start, LatLng end) {
    clearMarkers();
    _markers.add(Marker(markerId: MarkerId(LOCATION_MARKER_ID), position: start, icon: startIcon));
    _markers.add(Marker(markerId: MarkerId(DESTINATION_MARKER_ID), position: end, icon: endIcon));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(_calculateBounds(start, end), 120));
  }

  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void cancelRideRequest() {
    show = Show.DESTINATION_SELECTION;
    selectedVehicleType = 'Motorbike'; // Reset to default
    clearMarkers();
    clearPolylines();
    destinationController.clear();
    destinationCoordinates = null;
    routeModel = null;
    notifyListeners();
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  LatLngBounds _calculateBounds(LatLng start, LatLng end) {
    return LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
  }

  Future<void> searchPlaces(String query) async {
    if (query.length < 2) {
      _predictions = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    if (_accessToken == null) {
      print("Error searching places: ApiService or accessToken is null.");
      _predictions = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    if (_sessionToken == null) {
      _sessionToken = Uuid().v4();
    }

    try {
      final result = await _apiService.searchPlacesProxy(
        accessToken: _accessToken,
        query: query,
        sessiontoken: _sessionToken!,
      );
      _predictions = result;
    } catch (e) {
      print("Error searching places: $e");
      _predictions = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<void> getPlaceDetails(String placeId) async {
    if (_accessToken == null || _sessionToken == null) {
      print("Error getting place details: ApiService, accessToken, or sessionToken is null.");
      return;
    }

    try {
      final result = await _apiService.getPlaceDetailsProxy(
        accessToken: _accessToken,
        placeId: placeId,
        sessiontoken: _sessionToken!,
      );

      destinationCoordinates = LatLng(result['lat'], result['lng']);
      destinationController.text = result['name'];
      _predictions = [];
      _sessionToken = null;

      // 1. Add the animated draggable marker
      _addAnimatedDestinationMarker();

      // 2. Ensure camera animates smoothly to center the destination
      _animateCameraToDestination();

      show = Show.CONFIRMATION_SELECTION;
      notifyListeners();

    } catch (e) {
      print("Error getting place details: $e");
    }
  }

// --- NEW METHOD: Smooth camera animation to destination ---
  Future<void> _animateCameraToDestination() async {
    if (destinationCoordinates == null || _mapController == null) return;

    final targetZoom = 17.0; // Comfortable zoom level for streets

    // Animate camera smoothly
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: destinationCoordinates!,
          zoom: targetZoom,
          bearing: 0,
          tilt: 45, // Slight tilt for better view (optional)
        ),
      ),
    );
  }
  void _addAnimatedDestinationMarker() {
    if (destinationCoordinates == null) return;

    // Calculate the offset for the bounce animation
    final bounceValue = _bounceAnimation?.value ?? 0;
    final markerOffset = Offset(0, -20 * bounceValue);

    // Clear any existing destination markers
    _markers.removeWhere((m) => m.markerId.value == DESTINATION_MARKER_ID);

    // Add the current location marker (if not already present)
    if (!_markers.any((m) => m.markerId.value == LOCATION_MARKER_ID)) {
      _markers.add(Marker(
        markerId: MarkerId(LOCATION_MARKER_ID),
        position: _center,
        icon: startIcon,
      ));
    }

    // Add the draggable destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId(DESTINATION_MARKER_ID),
        position: destinationCoordinates!,
        icon: endIcon,
        infoWindow: InfoWindow(
          title: destinationController.text,
          snippet: 'Drag to adjust location',
        ),
        draggable: true,
        anchor: markerOffset,
        onDragStart: (position) {
          // Optional: Provide haptic feedback when dragging starts
          HapticFeedback.selectionClick();
        },
        onDrag: (position) {
          // Optional: Update in real-time while dragging
          // _onMarkerDragging(position);
        },
        onDragEnd: (newPosition) {
          _onMarkerDragged(newPosition);
          // Re-animate camera to new position
          _animateCameraToMarker(newPosition);
        },
      ),
    );

    // Start bounce animation
    _bounceController?.forward(from: 0.0);
    notifyListeners();
  }

// --- NEW: Camera animation after marker is dragged ---
  Future<void> _animateCameraToMarker(LatLng position) async {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  // --- NEW METHOD: To handle what happens after dragging ---
  Future<void> _onMarkerDragged(LatLng newPosition) async {
    destinationCoordinates = newPosition;


    // THE FIX: We need to manually update the marker's position in the _markers set
    // before calling notifyListeners(). This forces the marker to redraw at the new spot.
    _markers.removeWhere((m) => m.markerId.value == DESTINATION_MARKER_ID);
    _markers.add(
      Marker(
        markerId: const MarkerId(DESTINATION_MARKER_ID),
        position: newPosition,
        icon: endIcon,
        infoWindow: const InfoWindow(title: "Adjusting..."), // Give feedback
        draggable: true,
        onDragEnd: (pos) => _onMarkerDragged(pos), // Re-assign the drag handler
      ),
    );
    notifyListeners(); // Update the UI to show the moved marker

    // Now, perform the reverse geocoding to update the address text.
    // This can happen after the UI has updated.

    // Perform reverse geocoding to get the new address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          newPosition.latitude, newPosition.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Construct a readable address and update the text field
        final street = p.thoroughfare?.isNotEmpty == true ? '${p.thoroughfare}, ' : '';
        final locality = p.locality?.isNotEmpty == true ? '${p.locality}, ' : '';
        final country = p.country ?? '';
        destinationController.text = '$street$locality$country'.trim().replaceAll(RegExp(r',$'), '');
      } else {
        destinationController.text = "Unnamed Location";
      }
    } catch (e) {
      print("Error during reverse geocoding: $e");
      destinationController.text = "Unknown Location";
    }

    // You might want to re-fetch the route and estimate after dragging
    // For now, we just update the state
    notifyListeners();
  }
  void clearPredictions() {
    destinationController.text = '';
    _predictions = [];
    _sessionToken = null;
    notifyListeners();
  }

  Future<void> _loadCustomMarkers() async {
    carIcon = await _bitmapDescriptorFromAsset(Images.carTop, width: 30, height: 30);
    markerIcon = await _bitmapDescriptorFromAsset(Images.location, width: 30, height: 30);
    startIcon = await _bitmapDescriptorFromAsset(Images.location, width: 30, height: 30);
    endIcon =
    await _bitmapDescriptorFromAsset(Images.mapLocationIcon, width: 100, height: 100);
    addressIcon =
    await _bitmapDescriptorFromAsset(Images.mapLocationIcon, width: 100, height: 100);
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromAsset(String asset,
      {required int width, required int height}) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }
}
