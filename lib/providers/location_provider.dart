import 'dart:async';
import 'dart:convert';

import 'package:BucoRide/models/route.dart';
import 'package:BucoRide/services/map_requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../models/driver.dart';
import '../services/drivers.dart';
import '../utils/images.dart';

enum Show {
  DESTINATION_SELECTION,
  PICKUP_SELECTION,
  PAYMENT_METHOD_SELECTION,
  DRIVER_FOUND,
  TRIP,
  SEARCHING_DRIVER
}

class LocationProvider with ChangeNotifier {
  static const PICKUP_MARKER_ID = 'pickup';
  static const LOCATION_MARKER_ID = 'location';
  //  draggable to show
  Show show = Show.DESTINATION_SELECTION;

  GoogleMapController? _mapController;

  // LIST OBJECTS
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Position? _currentPosition;
  Stream<Position>? _positionStream;
  Stream<List<DriverModel>>? _allDriversStream;
  DriverService? _driverService;
  String? locationAddress;
  RouteModel? routeModel;
  Timer? _debounce; // Declare at the class level

  String _riderAddress = 'Loading...';

  static LatLng _center = LatLng(0, 0);
  late LatLng _bounds;
  //   taxi pin
  late BitmapDescriptor carPin =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  late double requestedDestinationLat;
  late double requestedDestinationLng;
  late String requestedDestination;
  late LatLng destinationCoordinates;
  late LatLng pickupCoordinates = _center;
  LatLng _lastPosition = _center;

  //Getters
  Position? get currentPosition => _currentPosition;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers; // Expose markers
  String get riderAddress => _riderAddress;
  Set<Polyline> get polylines => _polylines;
  LatLng get center => _center;
  LatLng get lastPosition => _lastPosition;

//LatLng get bounds => _bounds;

//SETTERS

  // BOOLEANS

  bool _isTrafficEnabled = false;
  get isTrafficEnabled => _isTrafficEnabled;

//OTHERS
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  LocationProvider() {
    _startPositionStream();
  }

  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠️ Location services are disabled.");
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("⚠️ Location permission denied.");

          notifyListeners();
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      LatLng pos =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _addCustomMarker(pos);
      print("📍 My Position: $_currentPosition");

      // Convert coordinates to address
      setLocationAddress();
    } catch (e) {
      print('❌ Error fetching location: $e');
    } finally {
      notifyListeners();
    }
  }

  void _saveAddressToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', locationAddress!);
    //print("Saving Address:" + "${locationAddress}");
  }

  Future<void> getAddressFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    locationAddress = prefs.getString('address') ?? "No Address";
    notifyListeners(); // This updates the UI
  }

  void _startPositionStream() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // High accuracy for ride-hailing apps
      distanceFilter: 10, // Update only if moved by 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    _positionStream!.listen((Position position) {
      _currentPosition = position;
      print("My stream Position:" + "${_currentPosition}");
      LatLng pos = LatLng(position.latitude, position.longitude);
      //_addCustomMarker(pos);
      // Update the center position
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      _addCustomMarker(pos);
      _addCurrentLocationMarker(position);
      listenToDrivers();
      notifyListeners();
    });
  }

//   Future sendRequest(
//       {required LatLng origin, required LatLng destination}) async {
//     LatLng _org;
//     LatLng _dest;

//     if (origin == null && destination == null) {
//       _org = pickupCoordinates;
//       _dest = destinationCoordinates;
//     } else {
//       _org = origin;
//       _dest = destination;
//     }

//     RouteModel route =
//         await _googleMapsServices.getRouteByCoordinates(_org, _dest);
//     routeModel = route;

//     if (origin == null) {
//       ridePrice =
//           double.parse((routeModel!.distance.value / 500).toStringAsFixed(2));
//     }
//     List<Marker> mks = _markers
//         .where((element) => element.markerId.value == "location")
//         .toList();
//     if (mks.length >= 1) {
//       _markers.remove(mks[0]);
//     }
// // ! another method will be created just to draw the polys and add markers
//     _addCurrentLocationMarker(position)
//     _addLocationMarker(destinationCoordinates, routeModel!.distance.text);
//     _center = destinationCoordinates;
//     _createRoute(route.points, color: Colors.deepOrange);
//     _createRoute(
//       route.points,
//       color: Colors.black54,
//     );

//     notifyListeners();
//   }

//  _clearDriverMarkers() {
//     _markers.forEach((element) {
//       String _markerId = element.markerId.value;
//       if (_markerId != driverModel.id ||
//           _markerId != LOCATION_MARKER_ID ||
//           _markerId != PICKUP_MARKER_ID) {
//         _markers.remove(element);
//         notifyListeners();
//       }
//     });
//   }
  setPickCoordinates({required LatLng coordinates}) {
    pickupCoordinates = coordinates;
    notifyListeners();
  }

  //GETTING AND SETTING ADDRESS
  setLocationAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Fetch the placemarks using coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (placemarks.isNotEmpty) {
      String? countryCode =
          placemarks.isNotEmpty ? placemarks[0].isoCountryCode : null;

      locationAddress =
          "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
      country_global_key = countryCode!;

      _saveAddressToPrefs();

      // Save the country code in lowercase if it's not already set
      if (prefs.getString(COUNTRY) == null && countryCode != null) {
        String country = countryCode.toLowerCase();
        await prefs.setString(COUNTRY, country);
      }

      print('Position: $_currentPosition');
      print('Address:  $locationAddress');
    }
  }

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  toggleTraffic() {
    _isTrafficEnabled = !isTrafficEnabled;
    notifyListeners(); // Update UI
  }

  _addCustomMarker(LatLng position) {
    clearMarkers();
    BitmapDescriptor.asset(
            ImageConfiguration(size: Size(30, 30), devicePixelRatio: 2.5),
            Images.location)
        .then((icon) {
      markerIcon = icon;
    });

    _markers.add(Marker(
        markerId: MarkerId(LOCATION_MARKER_ID),
        position: position,
        icon: markerIcon));
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void updateDestination({required String destination}) {
    destinationController.text = destination;
    notifyListeners();
  }

  changeRequestedDestination(
      {required String reqDestination,
      required double lat,
      required double lng}) {
    requestedDestination = reqDestination;
    requestedDestinationLat = lat;
    requestedDestinationLng = lng;
    notifyListeners();
  }

  setDestination({required LatLng coordinates}) {
    destinationCoordinates = coordinates;
    notifyListeners();
  }

  changeWidgetShowed({required Show showWidget}) {
    show = showWidget;
    if (show == Show.PAYMENT_METHOD_SELECTION) {
      _adjustCameraToFitRoute();
    }
    notifyListeners();
  }

  void _adjustCameraToFitRoute() {
    if (mapController != null &&
        pickupCoordinates != null &&
        destinationCoordinates != null) {
      LatLngBounds bounds =
          _calculateBounds(pickupCoordinates, destinationCoordinates);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  LatLngBounds _calculateBounds(LatLng start, LatLng end) {
    return LatLngBounds(
      southwest: LatLng(
          (start.latitude < end.latitude) ? start.latitude : end.latitude,
          (start.longitude < end.longitude) ? start.longitude : end.longitude),
      northeast: LatLng(
          (start.latitude > end.latitude) ? start.latitude : end.latitude,
          (start.longitude > end.longitude) ? start.longitude : end.longitude),
    );
  }

  changePickupLocationAddress({required String address}) {
    pickupLocationController.text = address;
    if (pickupCoordinates != null) {
      //LatLng(position.latitude, position.longitude);
      _center = pickupCoordinates;
    }
    notifyListeners();
  }

  setLastPosition(LatLng position) {
    _lastPosition = position;
    notifyListeners();
  }

  addPickupMarker(LatLng position) {
    if (pickupCoordinates == null) {
      pickupCoordinates = position;
    }
    _markers.add(Marker(
        markerId: MarkerId(PICKUP_MARKER_ID),
        position: position,
        anchor: Offset(0, 0.85),
        zIndex: 3,
        infoWindow: InfoWindow(title: "Pickup", snippet: "location"),
        icon: markerIcon));
    notifyListeners();
  }

  // ✅ Add Marker for Current Location
  void _addCurrentLocationMarker(Position position) {
    clearMarkers();
    final marker = Marker(
      markerId: MarkerId(LOCATION_MARKER_ID),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: 'You Are Here'),
      //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      icon: markerIcon,
    );

    _markers
      ..removeWhere(
          (m) => m.markerId.value == LOCATION_MARKER_ID) // Remove old marker
      ..add(marker); // Add new marker

    notifyListeners();
  }

  void addRiderLocationMarker(LatLng riderPosition) {
    final riderMarker = Marker(
      markerId: MarkerId('riderMarker'),
      position: riderPosition,
      infoWindow: InfoWindow(title: "Rider Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _markers.add(riderMarker);
    notifyListeners(); // Update UI
  }

  onCameraMove(CameraPosition position) {
    if (show == Show.PICKUP_SELECTION) {
      _lastPosition = position.target;
      changePickupLocationAddress(address: "Loading...");

      // Remove existing markers
      _markers.removeWhere((element) =>
          element.markerId.value == PICKUP_MARKER_ID ||
          element.markerId.value == LOCATION_MARKER_ID);

      // Update pickup coordinates
      pickupCoordinates = _lastPosition;

      // Add new pickup marker
      addPickupMarker(position.target);

      print("ADDING PICKUP MARKER at: ${position.target}");

      // Cancel previous debounce timer
      _debounce?.cancel();

      // Start a new debounce timer
      _debounce = Timer(Duration(milliseconds: 800), () async {
        try {
          List<Placemark> placemark = await placemarkFromCoordinates(
            position.target.latitude,
            position.target.longitude,
          );

          pickupLocationController.text = placemark.isNotEmpty
              ? placemark[0].name ?? 'Unknown location'
              : 'Unknown location'; // Fallback value
        } catch (e) {
          print("Error getting location name: $e");
          pickupLocationController.text = 'Unknown location';
        }

        notifyListeners(); // Notify only after the address is updated
      });
    }
  }

  // This method will fetch the address based on the rider's location
  Future<void> fetchRiderAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        _riderAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      } else {
        _riderAddress = 'Address not found';
      }
    } catch (e) {
      _riderAddress = 'Error fetching address';
      print('Error fetching address: $e');
    }
    notifyListeners();
  }

  // HERE WE CREATE THE POLY LINES
// Create polyline based on rider's and driver's positions
  Future<void> createJourneyPolyline(
      LatLng driverPosition, LatLng destination) async {
    String? encodedPolyline = await getDirections(driverPosition, destination);
    if (encodedPolyline != null) {
      List<LatLng> polylineCoordinates = decodePolyline(encodedPolyline);
      final polyline = Polyline(
          polylineId: PolylineId('journey_path'),
          color: Colors.blue,
          width: 5,
          points:
              polylineCoordinates // You can extend this with more points if needed
          );
      _polylines.add(polyline);
      notifyListeners();
    }
  }

// Add polyline for the rider's journey (from rider's position to destination)
  Future<void> addRiderRoutePolyline(LatLng start, LatLng end) async {
    try {
      String? encodedPolyline = await getDirections(start, end);
      if (encodedPolyline != null) {
        List<LatLng> polylineCoordinates = decodePolyline(encodedPolyline);

        final polyline = Polyline(
          polylineId: PolylineId('rider_route'),
          points: polylineCoordinates,
          color: Colors.green, // Customize color as needed
          width: 5,
        );

        _polylines.add(polyline);

        // ✅ Fetch and store route details
        await fetchRoute(start, end);

        notifyListeners();
      }
    } catch (e) {
      print("Error adding polyline: $e");
    }
  }

  // Optionally clear the polyline if needed
  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }

  Future<void> fetchRoute(LatLng start, LatLng end) async {
    try {
      RouteModel route =
          await GoogleMapsServices().getRouteByCoordinates(start, end);
      routeModel = route; // ✅ Store the fetched route
      notifyListeners();
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<String?> getDirections(LatLng origin, LatLng destination) async {
    final String googleApiKey = GOOGLE_MAPS_API_KEY;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        // Extract polyline from the response
        String polyline = data['routes'][0]['overview_polyline']['points'];
        return polyline;
      } else {
        print("Error fetching directions: ${data['status']}");
        return null;
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      return null;
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  cancelRequest() {
    pickupCoordinates =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    destinationCoordinates =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    _polylines.clear();
    routeModel = null;
    destinationController.clear();
    show = Show.DESTINATION_SELECTION;
    animateCamera();
    notifyListeners();
  }

  void animateCamera() {
    LatLng pos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: 15.0, // Adjust the zoom level as needed
          bearing: 0.0, // Optional: Adjust the bearing (rotation) if needed
          tilt: 4.0, // Optional: Adjust the tilt if needed
        ),
      ),
    );
  }

  // DRIVER FECTHING ALL
  //void _listenToDrivers() {
  //_allDriversStream = _driverService?.getDrivers().listen(onData);
  //}
  void listenToDrivers() {
    //Get online drivers
    // FirebaseFirestore.instance
    //     .collection('drivers')
    //     .where('isOnline', isEqualTo: true) // Fetch only online drivers
    //     .snapshots()
    //     .listen((querySnapshot) {
    //   _updateDriverMarkers(querySnapshot.docs);
    // });
    print("========DriverMarkers Checking=======================:");
    FirebaseFirestore.instance
        .collection("drivers")
        .snapshots()
        .listen((snapshot) {
      List<DriverModel> drivers =
          snapshot.docs.map((doc) => DriverModel.fromSnapshot(doc)).toList();
      _updateDriverMarkers(drivers);
    });
  }

  void _updateDriverMarkers(List<DriverModel> drivers) {
    Set<Marker> newMarkers = {};

    for (var driver in drivers) {
      if (driver.position.lat != null && driver.position.lng != null) {
        Marker marker = Marker(
          markerId: MarkerId(driver.id),
          position: LatLng(driver.position.lat!, driver.position.lng!),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: driver.name ?? "Driver",
          ),
        );
        newMarkers.add(marker);
      }
    }
    print("DriverMarkers Added:");
    _markers = newMarkers;
  }

  // void _updateDriverMarkers(List<QueryDocumentSnapshot> drivers) {
  //   Set<Marker> newMarkers = {};
  //
  //   for (var doc in drivers) {
  //     var data = doc.data() as Map<String, dynamic>;
  //
  //     if (data['latitude'] != null && data['longitude'] != null) {
  //       Marker marker = Marker(
  //         markerId: MarkerId(doc.id),
  //         position: LatLng(data['latitude'], data['longitude']),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         infoWindow: InfoWindow(
  //           title: "Driver",
  //           snippet: "Last Updated: ${data['updatedAt']}",
  //         ),
  //       );
  //       newMarkers.add(marker);
  //     }
  //   }
  //
  //   _markers = newMarkers; // Update markers on the map
  // }

  void _updateMarkers(List<DriverModel> drivers) {
    // Preserve the user’s location marker
    List<Marker> locationMarkers = _markers
        .where((element) => element.markerId.value == 'location')
        .toList();

    clearMarkers();

    // Re-add user's location marker if it exists
    if (locationMarkers.isNotEmpty) {
      _markers.add(locationMarkers[0]);
    }

    // Update driver markers
    for (DriverModel driver in drivers) {
      _addDriverMarker(
        driverId: driver.id,
        position: LatLng(driver.position.lat, driver.position.lng),
        rotation: driver.position.heading,
      );
    }
  }

  void _addDriverMarker(
      {required String driverId,
      required LatLng position,
      double rotation = 0}) {
    final marker = Marker(
      markerId: MarkerId(driverId),
      position: position,
      rotation: rotation,
      icon: carPin, // Custom marker color
      infoWindow: InfoWindow(title: "Driver $driverId"),
    );

    _markers.add(marker);
  }

  _stopListeningToDriversStream() {
//    _clearDriverMarkers();
    //allDriversStream.cancel();
  }
//   _listenToDriver() {
//     driverStream = _driverService.driverStream().listen((event) {
//       event.documentChanges.forEach((change) async {
//         if (change.document.data['id'] == driverModel.id) {
//           driverModel = DriverModel.fromSnapshot(change.document);
//           // code to update marker
// //          List<Marker> _m = _markers
// //              .where((element) => element.markerId.value == driverModel.id).toList();
// //          _markers.remove(_m[0]);
//           clearMarkers();
//           sendRequest(
//               origin: pickupCoordinates,
//               destination: driverModel.getPosition());
//           if (routeModel!.distance.value <= 200) {
//             driverArrived = true;
//           }
//           notifyListeners();

//           _addDriverMarker(
//               position: driverModel.getPosition(),
//               rotation: driverModel.position.heading,
//               driverId: driverModel.id);
//           addPickupMarker(pickupCoordinates);
//           // _updateDriverMarker(_m[0]);
//         }
//       });
//     });

//     show = Show.DRIVER_FOUND;
//     notifyListeners();
//   }
}
