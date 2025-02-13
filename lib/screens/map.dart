import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';

import '../helpers/screen_navigation.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);

    final position = locationProvider.currentPosition;
    final showTraffic = locationProvider.isTrafficEnabled;
    final _mapController = locationProvider.mapController;
    final _markers = locationProvider.markers;
    // Get the current polyline to be drawn on the map
    final Set<Polyline> _polyline = locationProvider.polylines;

    return Scaffold(
        key: scaffoldKey,
        body: position == null
            ? Center(child: LoadingLocationScreen())
            : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      locationProvider.onCreate(
                          controller); // This ensures the map controller is set
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 20.0),
                    trafficEnabled: showTraffic,
                    mapType: MapType.normal,
                    compassEnabled: true, // Enables the compass for orientation
                    rotateGesturesEnabled:
                        true, // Allows users to rotate the map
                    zoomGesturesEnabled:
                        true, // Enables zooming using pinch gestures
                    zoomControlsEnabled: true, // Shows zoom in/out buttons
                    scrollGesturesEnabled: true, // Allows scrolling (panning)
                    tiltGesturesEnabled: true,
                    markers: _markers,
                    onCameraMove: locationProvider.onCameraMove,
                    polylines: _polyline,
                  ),

                  Positioned(
                    top: 36.0,
                    left: 26.0,
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
                      child: const Icon(Icons.menu),
                    ),
                  ),

                  // Floating button positioned at the bottom right

                  // New FAB for Centering Location
                  Positioned(
                    top: 730, // Positioned below the first button
                    right: 15,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue, // Different color for distinction
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3), // Changes position of shadow
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Center the map on the user's current location
                          LatLng newPos =
                              LatLng(position!.latitude, position.longitude);
                          _mapController
                              ?.animateCamera(CameraUpdate.newLatLng(newPos));
                        },
                      ),
                    ),
                  ),
                ],
              ));
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
