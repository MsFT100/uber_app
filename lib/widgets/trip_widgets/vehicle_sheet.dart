import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/user_provider.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';

class VehicleSelectionWidget extends StatefulWidget {
  const VehicleSelectionWidget({super.key});

  @override
  State<VehicleSelectionWidget> createState() => _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  // This flag will now only be used for the initial loading of all fares.
  bool _isFetchingInitialEstimate = false;

  // We no longer need a separate vehicle list here, we'll get it from the fares.

  @override
  void initState() {
    super.initState();
    // When the widget first appears, fetch all the route and fare data once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialEstimate();
    });
  }

  void _fetchInitialEstimate() async {
    if (!mounted) return;
    setState(() {
      _isFetchingInitialEstimate = true;
    });

    // We only need to call this once to get all fares.
    await context.read<LocationProvider>().getRouteAndEstimate();

    if (!mounted) return;
    setState(() {
      _isFetchingInitialEstimate = false;
    });
  }

  // Helper to map vehicle type strings from the backend to local image assets.
  String _getIconForVehicle(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'motorbike':
        return Images.motorBikeIcon;
      case 'sedan':
        return Images.sedanIcon;
      case 'van':
        return Images.vanIcon;
      case 'tuk-tuk':
        return Images.tuk_tukIcon;
      default:
        return Images.sedanIcon; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.65, // Adjust as needed
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, -2),
                blurRadius: 10,
              ),
            ],
          ),
          child: _isFetchingInitialEstimate
              ? const Center(child: SpinKitThreeBounce(color: Colors.black, size: 30))
              : _buildContent(myScrollController, locationProvider),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController, LocationProvider locationProvider) {
    if (locationProvider.routeModel == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Could not get trip details. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    // Get providers for the request button
    final appState = context.read<AppStateProvider>();
    final userProvider = context.read<UserProvider>();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
      children: [
        const ScrollSheetBar(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Title
        const Text(
          "Choose your ride",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Vertical List of Vehicles
        ...locationProvider.routeModel!.fares.map((fare) {
          // THE FIX: Access the 'vehicleType' property from the 'fare' object.
          bool isSelected = locationProvider.selectedVehicleType.toLowerCase() == fare.vehicleType.toLowerCase();
          return _buildVehicleListItem(
            // FIX 2: Use vehicleType here as well
            iconPath: _getIconForVehicle(fare.vehicleType),
            vehicleType: fare.vehicleType,
            price: fare.value.toStringAsFixed(2),
            time: locationProvider.routeModel!.timeNeeded.text,
            isSelected: isSelected,
            onTap: () {
              // FIX 3: And here
              locationProvider.selectVehicle(fare.vehicleType);
            },
          );
        }).toList(),

        const SizedBox(height: 30),

        // The main action button
        _buildRequestRideButton(appState, userProvider, locationProvider),

        const SizedBox(height: 10),

        // The cancel button
        _buildCancelButton(locationProvider),
      ],
    );
  }

  Widget _buildVehicleListItem({
    required String iconPath,
    required String vehicleType,
    required String price,
    required String time,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.yellow.shade800 : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 50, height: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Capitalize the first letter for display
                    vehicleType.substring(0, 1).toUpperCase() + vehicleType.substring(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "KES $price",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRideButton(AppStateProvider appState, UserProvider userProvider, LocationProvider locationProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // The selected vehicle type is already in the provider
          final selectedType = locationProvider.selectedVehicleType;

          final trip = Trip(
            userId: userProvider.user!.uid,
            type: TripType.ride, // Assuming it's always a ride for now
            pickup: locationProvider.pickupCoordinates,
            pickupAddress: locationProvider.locationAddress ?? "Current Location",
            destination: locationProvider.destinationCoordinates!,
            destinationAddress: locationProvider.destinationController.text,
            vehicleType: selectedType, // Pass the selected vehicle type
          );

          final accessToken = userProvider.accessToken;
          if (accessToken != null) {
            // Trigger the driver search
            locationProvider.show = Show.SEARCHING_DRIVER;
            await appState.requestNewTrip(trip, accessToken);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          "Request Ride",
          style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCancelButton(LocationProvider locationProvider) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          locationProvider.cancelRideRequest();
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Cancel",
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ),
    );
  }
}
