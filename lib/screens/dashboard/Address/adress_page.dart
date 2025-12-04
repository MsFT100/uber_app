import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/location_provider.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/app_bar/app_bar.dart';

class AddNewAddressPage extends StatefulWidget {
  const AddNewAddressPage({Key? key}) : super(key: key);

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  String _address = "Tap to Select a location";

  // Function to convert LatLng to Address
  Future<void> _getAddressFromLatLng(LatLng position) async {

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String newAddress =
            "${place.street}, ${place.locality}, ${place.country}";
        setState(() {
          _address = newAddress;
        });
      }
      // locationProvider.addAddressMarker(position);
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('addresses') ?? [];
    savedAddresses.add(_address);
    await prefs.setStringList('addresses', savedAddresses);

    if (!mounted) return;

    // Display a success message before popping the context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Address saved successfully!'),
      ),
    );

    // Wait for the SnackBar to be displayed before popping the context
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context, _address); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    final position = locationProvider.currentPosition;
    final _mapController = locationProvider.mapController;

    return Scaffold(
      appBar: CustomAppBar(
          title: "Add New Address", showNavBack: true, centerTitle: true),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position!.latitude, position.longitude),
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    locationProvider.onCreate(controller);
                  },
                  onTap: (LatLng position) {
                    _getAddressFromLatLng(position);
                  },
                  markers: locationProvider.markers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saveAddress,
                      icon: const Icon(Icons.save),
                      label: Text("Save Address",
                          style: TextStyle(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // New FAB for Centering Location
          Positioned(
            bottom: 100,
            right: 15,
            child: FloatingActionButton(
              onPressed: () {
                // Center the map on the user's current location
                LatLng newPos = LatLng(position.latitude, position.longitude);
                _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
