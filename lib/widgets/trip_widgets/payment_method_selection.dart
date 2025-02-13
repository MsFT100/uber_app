import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../helpers/style.dart';
import '../../providers/app_state.dart';
import '../../providers/user.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../custom_text.dart';

class PaymentMethodSelectionWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const PaymentMethodSelectionWidget({super.key, required this.scaffoldState});

  @override
  Widget build(BuildContext context) {
    final AppStateProvider appState = Provider.of<AppStateProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    // Update ridePrice to be 100 per kilometer
    final double distanceInKm = double.tryParse(locationProvider
                .routeModel?.distance.text
                .replaceAll(RegExp(r'[^0-9.]'), '') ??
            '0') ??
        0;
    appState.ridePrice = distanceInKm * 100;

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
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Delivery Button
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 10),
                            // GO MOTO Button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey, // Light grey background
                                borderRadius: BorderRadius.circular(
                                    12), // Smooth rounded borders
                              ),
                              padding: EdgeInsets.all(
                                  8), // Padding inside the container
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 70, // Adjust as needed
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            12), // Match outer radius
                                      ),
                                      child: Image.asset(Images.bike,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Space between image and text
                                  Text(
                                    "Go Moto",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Dimensions.fontSizeDefault),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20), // Space between buttons
                            // Delivery Button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(209, 158, 158,
                                    158), // Light grey background
                                borderRadius: BorderRadius.circular(
                                    12), // Smooth rounded borders
                              ),
                              padding: EdgeInsets.all(
                                  8), // Padding inside the container
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      //TODO Implement here
                                    },
                                    child: Container(
                                      width: 70, // Adjust as needed
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            12), // Match outer radius
                                      ),
                                      child: Image.asset(Images.bikeTop,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Space between image and text
                                  Text(
                                    "Delivery",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Dimensions.fontSizeDefault),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          Images.distanceCalculated,
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
                    CustomText(
                      text: "\ksh: ${appState.ridePrice.toStringAsFixed(2)}",
                      size: 16,
                      weight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                CustomText(
                  text: "Select Payment Method",
                  size: 18,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Method not available!")),
                        );
                      },
                      icon: const Icon(Icons.credit_card),
                      label: const CustomText(text: "Card"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.monetization_on),
                      label: const CustomText(text: "Cash"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                appState.lookingForDriver
                    ? const Center(child: SpinKitWave(color: black, size: 30))
                    : Column(
                        children: [
                          SizedBox(
                            width:
                                double.infinity, // Makes the button full-width
                            child: ElevatedButton(
                              onPressed: () async {
                                if (userProvider.userModel == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "User information is missing!")),
                                  );
                                  return;
                                }

                                appState.requestDriver(
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
                                //appState.changeMainContext(context);
                                locationProvider.show = Show.SEARCHING_DRIVER;
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
