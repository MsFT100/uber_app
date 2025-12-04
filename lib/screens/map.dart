import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/screens/menu.dart';
import 'package:BucoRide/screens/parcels/parcel_page.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/map_action_button.dart';
import '../widgets/loading_widgets/loading_location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final TextEditingController destinationController = TextEditingController();
  // THE FIX: Create the GlobalKey here, once.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _debounce;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Provider.of<LocationProvider>(context, listen: false).Initialize(this);

    destinationController.addListener(() {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingLocationScreen();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error initializing location: ${snapshot.error}'));
        }

        return Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            final position = locationProvider.currentPosition;

            if (position == null) {
              return LoadingLocationScreen();
            }

            final _mapController = locationProvider.mapController;
            final _markers = locationProvider.markers;
            final Set<Polyline> _polyline = locationProvider.polylines;

            return Scaffold(
              // Use the persistent key here
              key: _scaffoldKey,
              body: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      locationProvider.onCreate(controller);
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 17.0),
                    trafficEnabled: false,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    markers: _markers,
                    onCameraMove: locationProvider.onCameraMove,
                    polylines: _polyline,
                  ),

                  // ... (rest of your Stack children are fine) ...

                  // Home Button
                  MapActionButton(
                    top: 45.0,
                    left: 23.0,
                    icon: Icons.home,
                    onPressed: () {
                      locationProvider.cancelRideRequest();
                      changeScreen(context, Menu());
                    },
                  ),

                  // Parcel Button
                  MapActionButton(
                    top: 110.0,
                    left: 23.0,
                    icon: Icons.delivery_dining,
                    onPressed: () => changeScreen(context, ParcelPage()),
                  ),

                  // Center Location Button
                  MapActionButton(
                    top: 170.0,
                    left: 23.0,
                    icon: Icons.my_location,
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      LatLng newPos = LatLng(position.latitude, position.longitude);
                      _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
                    },
                  ),

                  if (locationProvider.destinationCoordinates != null)
                    _buildRideRequestButton(context, locationProvider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRideRequestButton(BuildContext context, LocationProvider locationProvider) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.lightPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        onPressed: () async {
          // Wait for route & estimate to be fetched, then show vehicle selection
          await locationProvider.getRouteAndEstimate();
          locationProvider.show = Show.VEHICLE_SELECTION;
        },
        child: Text(
          'Confirm Destination',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    destinationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
