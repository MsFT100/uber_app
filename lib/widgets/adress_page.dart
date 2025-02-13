import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/location_provider.dart';

class AddNewAddressPage extends StatefulWidget {
  const AddNewAddressPage({Key? key}) : super(key: key);

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  String _address = "Select a location";
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final position = locationProvider.currentPosition;
    _selectedLocation = LatLng(position!.latitude, position!.longitude);
  }

  //Future<void> _getAddress(LatLng position)
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
          _selectedLocation = position;
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // Function to save address in SharedPreferences
  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('addresses') ?? [];
    savedAddresses.add(_address);
    await prefs.setStringList('addresses', savedAddresses);
    Navigator.pop(context, _address); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    final position = locationProvider.currentPosition;
    final _mapController = locationProvider.mapController;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Address')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position!.latitude, position!.longitude),
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    locationProvider.onCreate(controller);
                  },
                  onTap: (LatLng position) {
                    _getAddressFromLatLng(position);
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId("selected-location"),
                      position: LatLng(position.latitude, position.longitude),
                      infoWindow: InfoWindow(title: _address),
                    ),
                  },
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
                      label: const Text("Save Address"),
                    ),
                  ],
                ),
              ),
            ],
          ),

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
                  _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}
