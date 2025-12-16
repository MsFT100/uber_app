import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/route.dart';
import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/loading_widgets/loading.dart';

class ParcelVehicleSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> parcelData;

  const ParcelVehicleSelectionScreen({super.key, required this.parcelData});

  @override
  State<ParcelVehicleSelectionScreen> createState() =>
      _ParcelVehicleSelectionScreenState();
}

class _ParcelVehicleSelectionScreenState
    extends State<ParcelVehicleSelectionScreen> {
  Future<Map<String, dynamic>>? _fareEstimateFuture;
  String _selectedVehicle = 'motorbike'; // Parcels usually start with motorbikes

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    final userProvider = context.read<UserProvider>();
    _fareEstimateFuture = locationProvider.getFareEstimateForParcel(
      pickup: widget.parcelData['pickupCoordinates'],
      dropoff: widget.parcelData['dropoffCoordinates'],
      accessToken: userProvider.accessToken!,
    );
  }

  void _requestParcelDelivery() async {
    final appState = context.read<AppStateProvider>();
    final userProvider = context.read<UserProvider>();
    final locationProvider = context.read<LocationProvider>();

    try {
      await appState.requestNewParcelTrip(
        parcelData: widget.parcelData,
        vehicleType: _selectedVehicle,
        accessToken: userProvider.accessToken!,
      );
      // This will trigger the AppStateProvider to listen for the trip
      // and update the UI to the "Searching for driver" screen.
      locationProvider.show = Show.SEARCHING_DRIVER;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to request parcel delivery: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Select Vehicle",
        showNavBack: true,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fareEstimateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Loading());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text(
                    "Error fetching fares: ${snapshot.error ?? 'No data'}"));
          }

          final fareData = snapshot.data!;
          final List<Fare> fares = (fareData['fares'] as List)
              .map((f) => Fare.fromMap(f))
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: fares.length,
                  itemBuilder: (context, index) {
                    final fare = fares[index];
                    // Simple mapping of vehicle type to an icon
                    final icon = fare.vehicleType == 'motorbike'
                        ? Icons.two_wheeler
                        : Icons.directions_car;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: RadioListTile<String>(
                        title: Text(fare.vehicleType.toUpperCase()),
                        subtitle: Text(
                            'KES ${double.parse(fare.value as String).toStringAsFixed(2)}'),
                        secondary: Icon(icon, color: AppConstants.lightPrimary), // No change here, icon is already IconData
                        value: fare.vehicleType,
                        groupValue: _selectedVehicle,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedVehicle = value);
                          }
                        },
                        activeColor: AppConstants.lightPrimary,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requestParcelDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.lightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeLarge),
                    ),
                    child: const Text("Request Delivery",
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}