import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/saved_address.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/app_bar/app_bar.dart';

class AddNewAddressPage extends StatefulWidget {
  final bool isEditing;
  final SavedAddress? savedAddress;
  final int? addressIndex;

  const AddNewAddressPage(
      {Key? key,
      this.isEditing = false,
      this.savedAddress,
      this.addressIndex})
      : super(key: key);

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  String _address = "Tap to Select a location";
  String _selectedLabel = 'Other';
  final List<String> _predefinedLabels = ['Home', 'Work'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.savedAddress != null) {
      _address = widget.savedAddress!.address;
      _selectedLabel = widget.savedAddress!.label;
    }
  }

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
    List<String> savedAddressesJson = prefs.getStringList('addresses') ?? [];

    final newSavedAddress = SavedAddress(label: _selectedLabel, address: _address);
    final newAddressJson = newSavedAddress.toJson();

    if (widget.isEditing && widget.addressIndex != null) {
      // Update the existing address
      if (widget.addressIndex! < savedAddressesJson.length) {
        savedAddressesJson[widget.addressIndex!] = newAddressJson;
      }
    } else {
      // Add a new address
      savedAddressesJson.add(newAddressJson);
    }

    await prefs.setStringList('addresses', savedAddressesJson);

    if (!mounted) return;

    // Display a success message before popping the context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address saved successfully!'),
      ),
    );

    // Wait for the SnackBar to be displayed before popping the context
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.pop(context, true); // Return true to indicate success
  }

  Future<void> _showCustomLabelDialog() async {
    final customLabelController = TextEditingController();
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Label'),
        content: TextField(
          controller: customLabelController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., "Gym"'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, customLabelController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLabel != null && newLabel.isNotEmpty) {
      setState(() => _selectedLabel = newLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    final position = locationProvider.currentPosition;
    final _mapController = locationProvider.mapController;

    return Scaffold(
      appBar: CustomAppBar(
          title: widget.isEditing ? "Edit Address" : "Add New Address",
          showNavBack: true,
          centerTitle: true),
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
                    const Text("Choose a label",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ..._predefinedLabels.map((label) => ChoiceChip(
                              label: Text(label),
                              selected: _selectedLabel == label,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedLabel = label);
                                }
                              },
                            )),
                        ChoiceChip(
                          label: Text(_predefinedLabels.contains(_selectedLabel)
                              ? 'Other'
                              : _selectedLabel),
                          selected: !_predefinedLabels.contains(_selectedLabel),
                          onSelected: (selected) {
                            if (selected) _showCustomLabelDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saveAddress,
                      icon: Icon(widget.isEditing ? Icons.check : Icons.save),
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
