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

class PaymentMethodSelectionWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const PaymentMethodSelectionWidget({super.key, required this.scaffoldState});

  @override
  State<PaymentMethodSelectionWidget> createState() =>
      _PaymentMethodSelectionWidgetState();
}

class _PaymentMethodSelectionWidgetState
    extends State<PaymentMethodSelectionWidget> {
  int selectedIndex = -1; // No selection by default
  String selectedVehicleLabel = ""; // Store selected vehicle name

  void selectVehicle(int index) {
    setState(() {
      selectedIndex = index;
      selectedVehicleLabel = vehicles[index]["label"]; // Assign the label
    });
  }

  // List of vehicle options
  final List<Map<String, dynamic>> vehicles = [
    {"icon": Images.motorBikeIcon, "label": "Motorbike"},
    {"icon": Images.sedanIcon, "label": "Sedan"},
    {"icon": Images.vanIcon, "label": "Van"},
    {"icon": Images.tuk_tukIcon, "label": "Tuk-Tuk"},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final buttonCount = 3;
    final spacing = 16.0;
    final totalSpacing = spacing * (buttonCount + 1);
    final buttonWidth = (screenWidth - totalSpacing) / buttonCount;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.1,
      maxChildSize: 0.65,
      builder: (BuildContext context, ScrollController myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                offset: Offset(0, -2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSize),
            child: ListView(
              controller: myScrollController,
              children: [
                ScrollSheetBar(),
                const SizedBox(height: Dimensions.paddingSize),
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(vehicles.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? spacing : 8,
                            right: index == vehicles.length - 1 ? spacing : 8,
                          ),
                          child: GestureDetector(
                            onTap: () => selectVehicle(index),
                            child: AnimatedContainer(
                              width: buttonWidth,
                              height: 120,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Colors.yellow.shade600
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.yellow
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              duration: Duration.zero,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    vehicles[index]["icon"],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    vehicles[index]["label"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: Dimensions.fontSizeSmall,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSize),
                const Text(
                  "Trip Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSize),
                // ... (rest of the UI for trip summary)
                const SizedBox(height: 20),
                appState.currentTrip?.status == TripStatus.requested
                    ? Center(
                        child: SpinKitFoldingCube(
                            color: black, size: Dimensions.fontSizeSmall))
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedIndex == -1) {
                                  // Show error: Please select a vehicle
                                  return;
                                }

                                final trip = Trip(
                                  userId: userProvider.user!.uid,
                                  type: TripType.ride,
                                  pickup: locationProvider.pickupCoordinates,
                                  pickupAddress: locationProvider.locationAddress!,
                                  destination: locationProvider.destinationCoordinates,
                                  destinationAddress: locationProvider.destinationController.text,
                                  vehicleType: selectedVehicleLabel,
                                );

                                final accessToken = userProvider.accessToken;
                                if (accessToken != null) {
                                  await appState.requestNewTrip(trip, accessToken);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text(
                                "Request Ride",
                                style: TextStyle(
                                    color: white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                locationProvider.show = Show.DESTINATION_SELECTION;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
