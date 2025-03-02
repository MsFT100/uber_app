import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../providers/user.dart';
import '../../utils/dimensions.dart';

class SearchingForDrivers extends StatefulWidget {
  const SearchingForDrivers({super.key});

  @override
  State<SearchingForDrivers> createState() => _SearchingForDriversState();
}

class _SearchingForDriversState extends State<SearchingForDrivers>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.driverFound) {
        locationProvider.show =
            Show.DRIVER_FOUND; // Update after build finishes
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.3, // Starts at 30% of the screen
      minChildSize: 0.3, // Minimum height when collapsed
      maxChildSize: 0.6, // Maximum height when expanded
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Ensures cancel button stays at bottom
            children: [
              Column(
                children: [
                  // Drag handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Show different UI based on search status
                  appState.lookingForDriver
                      ? Column(
                          children: [
                            // Animated searching text
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animation.value,
                                  child: Text(
                                    "Searching for a driver...",
                                    style: TextStyle(
                                        fontSize: Dimensions.fontSizeLarge,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge),
                            const Center(
                              child: // Searching animation (Loading Indicator)
                                  const SpinKitFoldingCube(
                                color: Colors.black,
                                size: Dimensions.iconSizeExtraLarge,
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            const Icon(Icons.warning,
                                size: 50, color: Colors.red),
                            const SizedBox(height: 10),
                            const Text(
                              "No drivers found at the moment. Try again later.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  appState.requestDriver(
                                    vehicleType: appState.vehicleType,
                                    distance: locationProvider
                                        .routeModel!.distance
                                        .toJson(),
                                    user: userProvider.userModel!,
                                    lat: locationProvider
                                        .pickupCoordinates.latitude,
                                    lng: locationProvider
                                        .pickupCoordinates.longitude,
                                    context: context,
                                    address:
                                        locationProvider.requestedDestination,
                                    destinationCoordinates:
                                        locationProvider.destinationCoordinates,
                                  ); // Restart search
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.refresh,
                                        color: Colors.white),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    const Text("Try Again"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                ],
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.cancelRequest();
                    locationProvider.cancelRequest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Cancel Search"),
                ),
              ),
              // Ensure the cancel button is always at the bottom
            ],
          ),
        );
      },
    );
  }
}
