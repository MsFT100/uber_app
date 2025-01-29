import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;

  const MapWidget({
    super.key,
    required this.initialPosition,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(20.0), // Rounded corners like a banner
        child: Container(
          height: 250.0, // Fixed height like a banner
          width: MediaQuery.of(context).size.width, // Full width of the screen
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 16.0,
            ),
            markers: markers, // Add markers to the map
            onMapCreated: (controller) {
              // Optional: Store the map controller if needed
            },
          ),
        ),
      ),
    );
  }
}
