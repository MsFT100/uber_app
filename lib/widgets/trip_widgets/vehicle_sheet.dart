import 'package:BucoRide/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/user_provider.dart';
import '../../utils/images.dart';

class VehicleSelectionWidget extends StatefulWidget {
  const VehicleSelectionWidget({super.key});

  @override
  State<VehicleSelectionWidget> createState() => _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  bool _isFetchingInitialEstimate = false;
  int _selectedIndex = 0; // Track which vehicle is selected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialEstimate();
    });
  }

  void _fetchInitialEstimate() async {
    if (!mounted) return;
    setState(() {
      _isFetchingInitialEstimate = true;
    });

    await context.read<LocationProvider>().getRouteAndEstimate();

    if (!mounted) return;
    setState(() {
      _isFetchingInitialEstimate = false;
    });
  }

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
        return Images.sedanIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.3, 0.65, 0.8],
      builder: (BuildContext context, ScrollController myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: _isFetchingInitialEstimate
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(color: Colors.black, size: 30),
                  SizedBox(height: 20),
                  Text(
                    'Calculating fares...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : _buildContent(myScrollController, locationProvider),
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController, LocationProvider locationProvider) {
    if (locationProvider.routeModel == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to fetch trip details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchInitialEstimate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final appState = context.read<AppStateProvider>();
    final userProvider = context.read<UserProvider>();
    final fares = locationProvider.routeModel!.fares;

    // Initialize selected index
    if (fares.isNotEmpty) {
      _selectedIndex = fares.indexWhere((fare) =>
      locationProvider.selectedVehicleType.toLowerCase() == fare.vehicleType.toLowerCase()
      );
      if (_selectedIndex < 0) _selectedIndex = 0;
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose your ride",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                locationProvider.destinationController.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Trip info chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${locationProvider.routeModel!.distance.text} • ${locationProvider.routeModel!.timeNeeded.text}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estimated trip time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.route,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Vehicles list
        Text(
          'Available Vehicles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),

        ...fares.asMap().entries.map((entry) {
          final index = entry.key;
          final fare = entry.value;
          bool isSelected = index == _selectedIndex;

          return _buildVehicleCard(
            iconPath: _getIconForVehicle(fare.vehicleType),
            vehicleType: fare.vehicleType,
            price: fare.value.toStringAsFixed(2),
            time: locationProvider.routeModel!.timeNeeded.text,
            isSelected: isSelected,
            index: index,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              locationProvider.selectVehicle(fare.vehicleType);
            },
          );
        }).toList(),

        const SizedBox(height: 30),

        // Request Ride Button
        _buildRequestRideButton(appState, userProvider, locationProvider),

        const SizedBox(height: 16),

        // Cancel Button
        _buildCancelButton(locationProvider),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildVehicleCard({
    required String iconPath,
    required String vehicleType,
    required String price,
    required String time,
    required bool isSelected,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with selection indicator
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.yellow.shade100 : Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Vehicle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleType.substring(0, 1).toUpperCase() + vehicleType.substring(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "KES $price",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black,
                ),
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
          final selectedType = locationProvider.selectedVehicleType;

          final trip = Trip(
            riderId: userProvider.user!.uid,
            type: TripType.ride,
            pickup: locationProvider.pickupCoordinates,
            pickupAddress: locationProvider.locationAddress ?? "Current Location",
            destination: locationProvider.destinationCoordinates!,
            destinationAddress: locationProvider.destinationController.text,
            vehicleType: selectedType,
          );

          final accessToken = userProvider.accessToken;
          if (accessToken != null) {
            // Add button press animation
            locationProvider.show = Show.SEARCHING_DRIVER;
            await appState.requestNewTrip(trip, accessToken);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 22),
            SizedBox(width: 12),
            Text(
              "Request Ride",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close, size: 20, color: Colors.red.shade600),
            const SizedBox(width: 10),
            Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}