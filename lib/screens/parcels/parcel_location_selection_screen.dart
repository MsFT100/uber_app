import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_bar/app_bar.dart';

class ParcelLocationSelectionScreen extends StatefulWidget {
  final String title;

  const ParcelLocationSelectionScreen({super.key, required this.title});

  @override
  State<ParcelLocationSelectionScreen> createState() =>
      _ParcelLocationSelectionScreenState();
}

class _ParcelLocationSelectionScreenState
    extends State<ParcelLocationSelectionScreen> {
  LatLng? _selectedPosition;
  String _selectedAddress = "Pan map to select location";
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.currentPosition != null) {
      final currentPos = LatLng(locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude);
      _selectedPosition = currentPos;
      _getAddressFromLatLng(currentPos);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      _selectedPosition = position;
    });

    String newAddress = "Could not get address";
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a more readable address
        final name = place.name ?? '';
        final street = place.street ?? '';
        newAddress = [name, street, place.locality, place.country]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
      } else {
        newAddress = "No address found for this location";
      }
    } catch (e) {
      newAddress = "Could not get address";
    } finally {
      if (mounted) {
        setState(() {
          _selectedAddress = newAddress;
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _onConfirm() {
    if (_selectedPosition != null) {
      Navigator.pop(context, {
        'address': _selectedAddress,
        'coordinates': _selectedPosition,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        showNavBack: true,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationProvider.center,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (position) {
              _selectedPosition = position.target;
            },
            onCameraIdle: () {
              if (_selectedPosition != null) {
                _getAddressFromLatLng(_selectedPosition!);
              }
            },
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: AppConstants.lightPrimary,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoadingAddress
                      ? const LinearProgressIndicator()
                      : Text(_selectedAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      child: const Text("Confirm Location"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
