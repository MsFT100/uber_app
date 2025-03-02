import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/parcels/track_package.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../locators/service_locator.dart';
import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../services/call_sms.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/custom_text.dart';
import '../menu.dart';

class FindParcelDriverScreen extends StatefulWidget {
  const FindParcelDriverScreen({super.key});

  @override
  State<FindParcelDriverScreen> createState() => _FindParcelDriverScreenState();
}

class _FindParcelDriverScreenState extends State<FindParcelDriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ShowDriver(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(Dimensions.paddingSize),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDriverInfo(appState),
                    Divider(thickness: 1.5),
                    _buildRideDetails(appState),
                    Divider(thickness: 1.5),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          appState.cancelParcelRequestListener();
                          popScreen(context, widget);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue, // Background color
                          backgroundColor: AppConstants.lightPrimary,
                        ),
                        child: Text(
                          "Cancel",
                          style: const TextStyle(
                            fontSize: Dimensions.paddingSizeSmall,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    locationProvider.fetchRiderAddress(locationProvider.center);

    // print("Driver Arrived: ${appState.driverArrived}");
    // print("Driver found: ${appState.driverFound}");
    // print("Trip Complete: ${appState.tripComplete}");
    // print("Looking For Driver: ${appState.lookingForDriver}");

    return Scaffold(
        appBar: CustomAppBar(
          title: "Delivery Drivers",
          showNavBack: true,
          centerTitle: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Looking for a driver
            if (appState.lookingForDriver) _buildSearchingForDriver(appState),

            // 2. No driver found
            if (!appState.lookingForDriver && !appState.driverFound)
              _buildNoDriversFound(appState, locationProvider),

            // 3. Driver Found but Not Arrived
            if (appState.driverFound && !appState.driverArrived)
              _buildDriverFound(appState),

            // 6. Trip Completed
            if (appState.tripComplete) _buildTripCompleted(appState),
          ],
        ));
  }

  Widget _buildTripCompleted(AppStateProvider appState) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppConstants.lightPrimary),
                ),
              ),
            ),
            Image.asset(Images.parcelDeliveryman),
          ],
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),
        Text("Looking For Drivers near you"),
        SizedBox(height: Dimensions.paddingSizeLarge),
        ElevatedButton(
          onPressed: () {
            appState.cancelParcelRequestListener();
            popScreen(context, widget);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: AppConstants.lightPrimary,
          ),
          child: Text(
            "Cancel Search",
            style: const TextStyle(
              fontSize: Dimensions.paddingSizeSmall,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

// Searching for Driver
  Widget _buildSearchingForDriver(AppStateProvider appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.lightPrimary),
                  ),
                ),
              ),
              Image.asset(
                Images.parcelDeliveryman,
                width: 150, // Adjust size if necessary
              ),
            ],
          ),
          SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            "Looking For Drivers near you",
            style: TextStyle(
                fontSize: Dimensions.paddingSizeDefault,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: Dimensions.paddingSizeLarge),
          ElevatedButton(
            onPressed: () {
              appState.cancelParcelRequestListener();
              popScreen(context, widget);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: AppConstants.lightPrimary,
            ),
            child: Text(
              "Cancel Search",
              style: TextStyle(
                fontSize: Dimensions.paddingSizeSmall,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

// No Drivers Found
  Widget _buildNoDriversFound(
      AppStateProvider appState, LocationProvider locationProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                ),
              ),
              Image.asset(Images.parcelDeliveryman),
            ],
          ),
          SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            "No Drivers found, Try again later.",
            style: TextStyle(
              fontSize: Dimensions.paddingSizeSmall,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: Dimensions.paddingSizeLarge),
          ElevatedButton(
            onPressed: () {
              appState.requestParcelDriver(
                userId: appState.parcelRequestModel!.userId,
                senderName: appState.parcelRequestModel!.senderName,
                senderContact: appState.parcelRequestModel!.senderContact,
                recipientName: appState.parcelRequestModel!.recipientName,
                recipientContact: appState.parcelRequestModel!.recipientContact,
                positionAddress: appState.parcelRequestModel!.positionAddress,
                destination: appState.parcelRequestModel!.destination,
                destinationLatLng:
                    appState.parcelRequestModel!.destinationLatLng,
                lat: locationProvider.center.latitude,
                lng: locationProvider.center.longitude,
                totalPrice: appState.parcelRequestModel!.totalPrice,
                weight: appState.parcelRequestModel!.weight,
                parcelType: appState.parcelRequestModel!.parcelType,
                vehicleType: appState.parcelRequestModel!.vehicleType,
                context: context,
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: AppConstants.lightPrimary,
            ),
            child: Text(
              "Retry Search",
              style: const TextStyle(
                fontSize: Dimensions.paddingSizeSmall,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Driver Found
  Widget _buildDriverFound(AppStateProvider appState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
            CircleAvatar(
              radius: 100,
              backgroundImage: appState.driverModel?.photo != null
                  ? NetworkImage(appState.driverModel!.photo)
                  : null,
              child: appState.driverModel?.photo == null
                  ? Icon(Icons.person_outline, size: 30, color: Colors.white)
                  : null,
            ),
          ],
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),
        Container(
          child: Text("Wait for the driver to arrive at your location"),
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),
        _buildDriverInfo(appState),
        SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeExtraSmall,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _ShowDriver(context, appState);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Background color
                      backgroundColor: Colors.blue,
                    ),
                    child: Text("View Driver Details"),
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeExtraSmall),

                /// Cancel Driver
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      appState.cancelParcelRequestListener();
                      appState.resetPackageVariables();
                      changeScreenReplacement(context, Menu());
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Background color
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

// Driver Arrived
  Widget _buildDriverArrived(
      AppStateProvider appState, LocationProvider locationProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView(
        //controller: myScrollController,
        children: [
          Center(
            child: CustomText(
              text: "Your ride has arrived",
              size: 14,
              weight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Divider(thickness: 1.5),
          _buildDriverInfo(appState),
          Divider(thickness: 1.5),
          _buildRideDetails(appState),
          Divider(thickness: 1.5),
          _buildRidePrice(appState),
          SizedBox(height: 12),
          _buildCancelButton(appState, locationProvider),
        ],
      ),
    );
  }

// Package on the Way
  Widget _buildOnTrip() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Your package is on the way to its destination"),
        ElevatedButton(
          onPressed: () {
            changeScreenReplacement(context, TrackPackage());
          },
          child: Text("Track Package",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildDriverInfo(AppStateProvider appState) {
    final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: appState.driverModel?.photo != null
                  ? NetworkImage(appState.driverModel!.photo)
                  : null,
              child: appState.driverModel?.photo == null
                  ? Icon(Icons.person_outline, size: 30, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.driverModel?.name ?? 'Loading...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    appState.driverModel?.model ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.call, color: Colors.green, size: 30),
              onPressed: () {
                final phone = appState.driverModel?.phone;
                if (phone != null) {
                  _service.call(phone);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetails(AppStateProvider appState) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: "Ride details", size: 16, weight: FontWeight.bold),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pickup Location",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(locationProvider.riderAddress ?? 'Loading...'),
                      SizedBox(height: 8),
                      Text("Destination",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(appState.parcelRequestModel?.destination ??
                          'Loading...'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidePrice(AppStateProvider appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: "Ride Price", size: 16, weight: FontWeight.bold),
        Text(
          "\$${appState.ridePrice.toStringAsFixed(0)}",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCancelButton(
      AppStateProvider provider, LocationProvider locationProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          provider.cancelParcelRequestListener();
          provider.resetPackageVariables();
          locationProvider.cancelRequest();
        },
        child: Text("Cancel Ride",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
