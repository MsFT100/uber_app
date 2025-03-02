import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/screens/menu.dart';
import 'package:BucoRide/screens/parcels/parcel_page.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';

import '../widgets/loading_widgets/loading_location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
                        zoom: 17.0),
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

                  ///HOME POSITION BUTTON
                  Positioned(
                    top: 45.0,
                    left: 23.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppConstants
                            .lightPrimary, // Different color for distinction
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3), // Changes position of shadow
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          changeScreen(context, Menu());
                        },
                      ),
                    ),
                  ),

                  /// PARCEL POSITION BUTTON
                  Positioned(
                    top: 110.0,
                    left: 23.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppConstants
                            .lightPrimary, // Different color for distinction
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3), // Changes position of shadow
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delivery_dining,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          changeScreen(context, ParcelPage());
                        },
                      ),
                    ),
                  ),
                  // Floating button positioned at the bottom right

                  // New FAB for Centering Location
                  Positioned(
                    top: 170.0,
                    left: 23.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue, // Different color for distinction
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
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
                              LatLng(position.latitude, position.longitude);
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
