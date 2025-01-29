import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';
import 'package:user_app/utils/app_constants.dart';

import '../helpers/screen_navigation.dart';
import '../providers/app_state.dart';
import '../widgets/loading_location.dart';
import 'menu.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController destinationController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final googlePlaces = th.GoogleMapsPlaces(
      apiKey: AppConstants.GOOGLE_MAPS_API_KEY); // Initialize API client
  List<dynamic> predictions = [];
  LatLng? selectedLocation;
  late LatLng? userLocation = null;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0), // Default position before fetching user location
    zoom: 11.0,
  );
  final LatLng _center = const LatLng(-23.77777, -46.6399);

  @override
  void initState() {
    super.initState();

    _getUserLocation();
    _setCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
        key: scaffoldKey,
        body: userLocation == null
            ? Center(child: LoadingLocationScreen())
            : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: appState.onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            userLocation!.latitude, userLocation!.longitude),
                        zoom: 15.0),
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    markers: appState.markers,
                    onCameraMove: appState.onCameraMove,
                    polylines: appState.poly,
                  ),
                  // Floating button positioned at the bottom right
                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        // Handle button press
                        changeScreen(
                            context,
                            Menu(
                              title: '',
                            ));
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ));
  }

  // Add a marker to the map
  void _addMarker(LatLng position, String title) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final marker = Marker(
      markerId: MarkerId(title),
      position: position,
      icon: appState.customMarker,
      infoWindow: InfoWindow(title: title),
    );

    // Call the AppStateProvider method to add the marker
    appState.addMarker(marker);
  }

  // Load custom marker icon
  Future<void> _setCustomMarker() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    appState.customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust size as needed
      'assets/images/person_placeholder.png',
    );
  }

  Future<void> _getUserLocation() async {
    try {
      // Request permission and fetch location

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      // Animate the camera to the user's location
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 15),
        ),
      );
      //_addMarker(userLocation!, "Your Location");
      // Add marker at user's location
      appState.addMarker(
        Marker(
          markerId: const MarkerId("user_location"),
          position: userLocation!,
          icon: appState.customMarker,
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
    } catch (e) {
      print("Error fetching user location: $e");
    }
  }

  // Fetch Place Predictions
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await googlePlaces.autocomplete(query,
          language: 'en'); // Call the autocomplete method

      if (response.isOkay) {
        setState(() {
          predictions = response.predictions;
        });
      } else {
        print("Error fetching predictions: ${response.errorMessage}");
      }
    } catch (e) {
      print("Search places error: $e");
    }
  }

  // Fetch Place Details and Update Map
  Future<void> getPlaceDetails(String placeId) async {
    try {
      final response = await googlePlaces.getDetailsByPlaceId(
          placeId); // Use `placeDetails` instead of `details`

      if (response.isOkay) {
        final result = response.result;
        final geometry = result.geometry;
        final location = geometry?.location;

        if (location != null) {
          final latLng = LatLng(location.lat, location.lng);

          // Update Map and Clear Predictions
          setState(() {
            //selectedLocation = latLng;

            predictions = [];
            destinationController.clear();
          });

          // Optionally, fetch address
          final placemarks = await placemarkFromCoordinates(
            location.lat,
            location.lng,
          );
          final placemark = placemarks.first;
          print("Selected Location: $latLng");
          print(
              "Address: ${placemark.street}, ${placemark.locality}, ${placemark.country}");
        }
      } else {
        print("Error fetching place details: ${response.errorMessage}");
      }
    } catch (e) {
      print("Error getting place details: $e");
    }
  }
}
