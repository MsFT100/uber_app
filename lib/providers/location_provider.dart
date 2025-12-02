import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/driver.dart';
import '../models/route.dart';
import '../services/map_requests.dart';
import '../utils/images.dart';

enum Show {
  DESTINATION_SELECTION,
  PICKUP_SELECTION,
  PAYMENT_METHOD_SELECTION,
  DRIVER_FOUND,
  TRIP,
  TRIP_COMPLETE,
  SEARCHING_DRIVER
}

class LocationProvider with ChangeNotifier {
  static const PICKUP_MARKER_ID = 'pickup';
  static const LOCATION_MARKER_ID = 'location';
  static const DESTINATION_MARKER_ID = 'destination';
  static const ADDRESS_MARKER_ID = 'address';

  Show _show = Show.DESTINATION_SELECTION;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<QuerySnapshot>? _driverStreamSubscription;
  String? locationAddress;
  RouteModel? routeModel;
  Timer? _debounce;
  String _riderAddress = 'Loading...';
  static LatLng _center = LatLng(0, 0);

  late LatLng destinationCoordinates;
  late LatLng pickupCoordinates = _center;
  LatLng _lastPosition = _center;

  // Getters
  Show get show => _show;
  Position? get currentPosition => _currentPosition;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  String get riderAddress => _riderAddress;
  Set<Polyline> get polylines => _polylines;
  LatLng get center => _center;
  LatLng get lastPosition => _lastPosition;

  bool _isTrafficEnabled = false;
  get isTrafficEnabled => _isTrafficEnabled;

  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor endIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor addressIcon = BitmapDescriptor.defaultMarker;

  LocationProvider() {
    _initialize();
  }

  set show(Show value) {
    _show = value;
    notifyListeners();
  }

  // ===== INITIALIZATION & LIFECYCLE =====

  Future<void> _initialize() async {
    await _loadCustomMarkers();
    await fetchLocation();
    _startPositionStream();
    _listenToDrivers();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _driverStreamSubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  // ===== GOOGLE MAPS CONTROLLER METHODS =====

  void onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    if (show == Show.PICKUP_SELECTION) {
      _lastPosition = position.target;
      changePickupLocationAddress(address: "Loading...");
      _markers.removeWhere((m) => m.markerId.value == PICKUP_MARKER_ID);
      pickupCoordinates = _lastPosition;
      addPickupMarker(position.target);

      _debounce?.cancel();
      _debounce = Timer(Duration(milliseconds: 800), () async {
        try {
          List<Placemark> placemark = await placemarkFromCoordinates(
            position.target.latitude,
            position.target.longitude,
          );
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

  void changePickupLocationAddress({required String address}) {
    pickupLocationController.text = address;
    _center = pickupCoordinates;
    notifyListeners();
  }

  // ===== LOCATION & ADDRESS METHODS =====

  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return Future.error('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
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
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
      if (placemarks.isNotEmpty) {
        locationAddress = "${placemarks.first.street}, ${placemarks.first.locality}";
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('address', locationAddress!);
      }
    } catch (e) {
      print("Error setting location address: $e");
    }
    notifyListeners();
  }

  // ===== STREAMS & LISTENERS =====

  void _startPositionStream() {
    final locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      _currentPosition = position;
      _center = LatLng(position.latitude, position.longitude);
      _addCurrentLocationMarker(_center);
      if (show == Show.TRIP) {
        addRiderRoutePolyline(_center, destinationCoordinates);
      }
      notifyListeners();
    });
  }

  void _listenToDrivers() {
    _driverStreamSubscription = FirebaseFirestore.instance.collection('drivers').where('isOnline', isEqualTo: true).snapshots().listen((snapshot) {
      _updateDriverMarkers(snapshot.docs);
    });
  }

  // ===== MARKER METHODS =====

  void _updateDriverMarkers(List<QueryDocumentSnapshot> driverDocs) {
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
    for (var doc in driverDocs) {
      final data = doc.data() as Map<String, dynamic>?;
      final pos = data?['position'] as GeoPoint?;
      if (data != null && pos != null) {
        final driver = Driver.fromMap(data);
        if (driver.id != null) {
          _markers.add(Marker(
            markerId: MarkerId('driver_${driver.id!}'),
            position: LatLng(pos.latitude, pos.longitude),
            icon: carIcon,
            infoWindow: InfoWindow(title: driver.name),
          ));
        }
      }
    }
    notifyListeners();
  }

  void _addCurrentLocationMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == LOCATION_MARKER_ID);
    _markers.add(Marker(
      markerId: MarkerId(LOCATION_MARKER_ID),
      position: position,
      icon: markerIcon,
    ));
    notifyListeners();
  }

  void addPickupMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == PICKUP_MARKER_ID);
    _markers.add(Marker(
        markerId: MarkerId(PICKUP_MARKER_ID),
        position: position,
        infoWindow: InfoWindow(title: "Pickup"),
        icon: startIcon));
    notifyListeners();
  }

  void addAddressMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId.value == ADDRESS_MARKER_ID);
    _markers.add(Marker(
      markerId: MarkerId(ADDRESS_MARKER_ID),
      position: position,
      icon: addressIcon,
      infoWindow: InfoWindow(title: 'Selected Address'),
    ));
    notifyListeners();
  }

  void addTripHistoryMarkers(LatLng start, LatLng end) {
    clearPolylines();
    clearMarkers();
    _markers.add(Marker(markerId: MarkerId('start'), position: start, icon: startIcon, infoWindow: InfoWindow(title: "From")));
    _markers.add(Marker(markerId: MarkerId('end'), position: end, icon: endIcon, infoWindow: InfoWindow(title: "To")));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(_calculateBounds(start, end), 100));
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromAsset(String asset, {required int width, required int height}) async {
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

  Future<void> _loadCustomMarkers() async {
    carIcon = await _bitmapDescriptorFromAsset(Images.carTop, width: 30, height: 30);
    markerIcon = await _bitmapDescriptorFromAsset(Images.location, width: 30, height: 30);
    startIcon = await _bitmapDescriptorFromAsset(Images.location, width: 30, height: 30);
    endIcon = await _bitmapDescriptorFromAsset(Images.mapLocationIcon, width: 200, height: 200);
    addressIcon = await _bitmapDescriptorFromAsset(Images.mapLocationIcon, width: 200, height: 200);
  }

  // ===== PO LYLINE & ROUTE METHODS =====

  Future<void> addRiderRoutePolyline(LatLng start, LatLng end) async {
    try {
      String? encodedPolyline = await _getDirections(start, end);
      _addDestinationMarker(start, end);
      if (encodedPolyline != null) {
        _polylines.add(Polyline(
          polylineId: PolylineId('rider_route'),
          points: _decodePolyline(encodedPolyline),
          color: AppConstants.lightPrimary,
          width: 5,
        ));
        await _fetchRouteDetails(start, end);
        notifyListeners();
      }
    } catch (e) {
      print("Error adding polyline: $e");
    }
  }

  void _addDestinationMarker(LatLng start, LatLng end) {
    clearMarkers();
    _markers.add(Marker(markerId: MarkerId(LOCATION_MARKER_ID), position: start, icon: startIcon));
    _markers.add(Marker(markerId: MarkerId(DESTINATION_MARKER_ID), position: end, icon: endIcon));
  }

  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }

  Future<void> _fetchRouteDetails(LatLng start, LatLng end) async {
    try {
      routeModel = await GoogleMapsServices().getRouteByCoordinates(start, end);
      notifyListeners();
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<String?> _getDirections(LatLng origin, LatLng destination) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${AppConfig.googleMapsApiKey}';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'OK') return data['routes'][0]['overview_polyline']['points'];
    }
    return null;
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
      southwest: LatLng(start.latitude < end.latitude ? start.latitude : end.latitude, start.longitude < end.longitude ? start.longitude : end.longitude),
      northeast: LatLng(start.latitude > end.latitude ? start.latitude : end.latitude, start.longitude > end.longitude ? start.longitude : end.longitude),
    );
  }

  // ===== UI STATE MANAGEMENT =====

  void updateDestination({required String destination}) {
    destinationController.text = destination;
    notifyListeners();
  }

  void setDestination({required LatLng coordinates}) {
    destinationCoordinates = coordinates;
    notifyListeners();
  }
}