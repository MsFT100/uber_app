import 'package:BucoRide/controllers/free_ride_controller.dart';
import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../providers/app_state.dart';
import '../../providers/user.dart';
import '../../services/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../custom_text.dart';

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
  final FreeRideController _freeRideController = FreeRideController();

  void selectVehicle(int index) {
    setState(() {
      selectedIndex = index;
      selectedVehicleLabel = vehicles[index]["label"]; // Assign the label
      print("Selected Vehicle: $selectedVehicleLabel");
      print("Selected Index:= $selectedIndex");
      changeRidePrice(index);
    });
  }

  void changeRidePrice(int vehicleIndex) {
    final AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Get the distance in KM
    final double distanceInKm = double.tryParse(locationProvider
                .routeModel?.distance.text
                .replaceAll(RegExp(r'[^0-9.]'), '') ??
            '0') ??
        0;

    // Set the correct price per kilometer and base rate
    double rideMultiplier = (vehicleIndex == 0)
        ? price_per_kilometer_motorbike
        : price_per_kilometer;

    double baseRate = (vehicleIndex == 0) ? base_rate_motorbike : base_rate;

    // Correct price calculation (Base rate + Distance * Rate)
    appState.ridePrice = baseRate + (distanceInKm * rideMultiplier);

    appState.vehicleType = selectedVehicleLabel;
    print("Updated Ride Price: ${appState.ridePrice}");
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
    final AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final user = userProvider.userModel;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.1,
      maxChildSize: 0.65,
      builder: (BuildContext context, ScrollController myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: const BorderRadius.only(
              topLeft: const Radius.circular(25),
              topRight: const Radius.circular(25),
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                offset: const Offset(0, -2),
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

                ///Types of transport
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(vehicles.length, (index) {
                        return GestureDetector(
                            onTap: () => selectVehicle(index),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 90,
                              height: 120,
                              padding:
                                  EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Colors
                                        .yellow.shade600 // Highlighted color
                                    : Colors.grey.shade300, // Default color
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.yellow
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: selectedIndex == index
                                    ? [
                                        BoxShadow(
                                          color: Colors.yellow.shade300,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    vehicles[index]["icon"],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: 8),
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
                            ));
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSize),

                CustomText(
                  text: "Trip Summary",
                  size: 20,
                  weight: FontWeight.bold,
                  color: Colors.black,
                ),
                const SizedBox(height: Dimensions.paddingSize),
                Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSize),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Aligns items at the top
                          children: [
                            Column(
                              children: [
                                Image.asset(Images.pickLocation,
                                    color: Colors.green,
                                    width: Dimensions.iconSizeSmall,
                                    height: Dimensions
                                        .iconSizeSmall), // Pickup Icon
                                Container(
                                  width: 2,
                                  height: 40, // Adjust height to align properly
                                  color: Colors.grey,
                                ),
                                Image.asset(Images.customerDestinationIcon,
                                    color: Colors.red,
                                    width: Dimensions.iconSizeSmall,
                                    height: Dimensions
                                        .iconSizeSmall), // Destination Icon
                              ],
                            ),
                            SizedBox(
                                width: Dimensions
                                    .paddingSize), // Reduce width for better fit
                            Expanded(
                              // ✅ Wrap text inside Expanded to prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locationProvider.routeModel?.startAddress ??
                                        "Pickup location",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow
                                        .ellipsis, // Prevents overflow
                                    maxLines: 1, // Ensures it fits in one line
                                    softWrap:
                                        false, // Avoids wrapping if it doesn't fit
                                  ),
                                  SizedBox(
                                      height:
                                          40), // Space between pickup and destination
                                  Text(
                                    locationProvider.routeModel?.endAddress ??
                                        "Destination",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSize),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          Images.endTrip,
                          width: Dimensions.iconSizeExtraLarge,
                          height: Dimensions.iconSizeExtraLarge,
                        ),
                        const SizedBox(width: Dimensions.paddingSize),
                        CustomText(
                            text: "Distance:",
                            size: Dimensions.fontSizeExtraLarge,
                            color: Colors.black),
                      ],
                    ),
                    CustomText(
                      text:
                          "${locationProvider.routeModel?.distance.text ?? 'N/A'}",
                      size: 16,
                      weight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSize),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          Images.farePrice,
                          width: Dimensions.iconSizeExtraLarge,
                          height: Dimensions.iconSizeExtraLarge,
                        ),
                        const SizedBox(width: 10),
                        CustomText(
                          text: "Estimated Fare:",
                          size: Dimensions.fontSizeLarge,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // show text "Free" if the user has free rides left  and fare is below Kshs.600/=
                    _freeRideController.hasFreeRideAvailable(user!) &&
                            appState.ridePrice <= 600
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: AppConstants.lightPrimary,
                                shape: BoxShape.rectangle),
                            padding: EdgeInsets.all(4.0),
                            child: CustomText(
                              text: "Free Ride",
                              size: 14,
                              weight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : CustomText(
                            text:
                                "ksh: ${appState.ridePrice.toStringAsFixed(2)}",
                            size: 16,
                            weight: FontWeight.bold,
                            color: Colors.black,
                          ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                // show if the user does not have free rides left
                if (!_freeRideController.hasFreeRideAvailable(user))
                  CustomText(
                    text: "Select Payment Method",
                    size: Dimensions.fontSizeSmall,
                    weight: FontWeight.bold,
                  ),
                const SizedBox(height: Dimensions.paddingSize),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_freeRideController.hasFreeRideAvailable(user))
                      OutlinedButton.icon(
                        onPressed: () {
                          appState.showCustomSnackBar(
                              context,
                              "Method not available!",
                              AppConstants.darkPrimary);
                        },
                        icon: const Icon(Icons.credit_card),
                        label: const CustomText(text: "Card"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    if (!_freeRideController.hasFreeRideAvailable(user))
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.monetization_on),
                        label: const CustomText(text: "Cash"),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          side:
                              const BorderSide(color: Colors.blue, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                appState.lookingForDriver
                    ? Center(
                        child: SpinKitFoldingCube(
                            color: black, size: Dimensions.fontSizeSmall))
                    : Column(
                        children: [
                          SizedBox(
                            width:
                                double.infinity, // Makes the button full-width
                            child: ElevatedButton(
                              onPressed: () async {
                                if (userProvider.userModel == null) {
                                  appState.showCustomSnackBar(
                                      context,
                                      "User information is missing!",
                                      Colors.redAccent);
                                  return;
                                }
                                if (selectedIndex == -1) {
                                  appState.showCustomSnackBar(
                                      context,
                                      "Please select a method of transport!",
                                      AppConstants.darkPrimary);
                                  return;
                                }
                                locationProvider.show = Show.SEARCHING_DRIVER;

                                print(
                                    "Updated show state: ${locationProvider.show}");

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
                                );

                                // check if the user has free rides
                                if (appState.ridePrice <= 600.0) {
                                  // check if the user has free remaining rides
                                  if (_freeRideController.hasFreeRideAvailable(user!)) {
                                    final newRides = user.freeRidesRemaining > 0 ? user.freeRidesRemaining - 1: 0;
                                    // update user data
                                    await UserServices().updateUserData(user..freeRidesRemaining = newRides);

                                    // Update in provider
                                    userProvider.updateFreeRides(newRides);

                                    // show a snackbar
                                    appState.showCustomSnackBar(
                                      context,
                                      "You have been offered a free ride!",
                                      Colors.green.shade400);
                                    return;
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Request Ride",
                                style: TextStyle(color: white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Adds spacing between buttons
                          SizedBox(
                            width:
                                double.infinity, // Makes the button full-width
                            child: ElevatedButton(
                              onPressed: () async {
                                locationProvider.cancelRequest();
                                locationProvider.show =
                                    Show.DESTINATION_SELECTION;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: white, fontSize: 16),
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
