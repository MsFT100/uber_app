import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final position = locationProvider.currentPosition;
    final _markers = locationProvider.markers;
    final Set<Polyline> _polyline = locationProvider.polylines;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(20.0), // Rounded corners like a banner
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
            //border: Border.all(color: AppConstants.lightPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(25),
          ),
          height: 250.0, // Fixed height like a banner
          width: MediaQuery.of(context).size.width, // Full width of the screen
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(position!.latitude, position.longitude),
              zoom: 16.0,
            ),

            markers: _markers, // Add markers to the map
            onMapCreated: (GoogleMapController controller) {
              // Optional: Store the map controller if needed
              locationProvider.onCreate(controller);
            },
            polylines: _polyline,
          ),
        ),
      ),
    );
  }
}
