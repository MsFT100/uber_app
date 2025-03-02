import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../locators/service_locator.dart';
import '../../providers/app_state.dart';
import '../../services/call_sms.dart';
import '../custom_text.dart';

class DriverFoundWidget extends StatefulWidget {
  const DriverFoundWidget({Key? key}) : super(key: key);

  @override
  _DriverFoundWidgetState createState() => _DriverFoundWidgetState();
}

class _DriverFoundWidgetState extends State<DriverFoundWidget> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      if (appState.driverModel == null && appState.rideRequestModel != null) {
        appState.fetchDriver("${appState.rideRequestModel!.driverId}");
      }
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      locationProvider.fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);

    print("SHOWING D++++++++ ${appState.driverArrived}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.driverArrived) {
        locationProvider.show = Show.TRIP; // Update after build finishes
      }
    });
    // if (appState.driverArrived) {
    //   setState(() {
    //     locationProvider.show = Show.TRIP;
    //   });
    // }

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, myscrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(border_radius),
              topRight: Radius.circular(border_radius),
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
            controller: myscrollController,
            children: [
              Center(
                child: CustomText(
                  text: appState.driverArrived
                      ? 'Your ride has arrived'
                      : 'Your ride arrives in ${locationProvider.routeModel?.timeNeeded.text ?? '...'}',
                  size: 14,
                  weight: FontWeight.bold,
                  color: appState.driverArrived ? Colors.green : Colors.grey,
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
      },
    );
  }

  Widget _buildDriverInfo(AppStateProvider appState) {
    return ListTile(
      leading: CircleAvatar(
        radius: 35,
        backgroundImage: appState.driverModel?.photo != null
            ? NetworkImage(appState.driverModel!.photo)
            : null,
        child: appState.driverModel?.photo == null
            ? Icon(Icons.person_outline, size: 30, color: Colors.white)
            : null,
      ),
      title: Text(
        appState.driverModel?.name ?? 'Loading...',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appState.driverModel?.model ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
          ),
          SizedBox(
            width: Dimensions.paddingSize,
          ),
          Text(
            appState.driverModel?.licensePlate ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Dimensions.fontSizeDefault, color: Colors.black),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.call, color: Colors.green, size: 30),
        onPressed: () {
          final phone = appState.driverModel?.phone;
          if (phone != null) {
            _service.call(phone);
          }
        },
      ),
    );
  }

  Widget _buildRideDetails(AppStateProvider appState) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Column(
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
                  Text(locationProvider.locationAddress ?? 'Loading...'),
                  SizedBox(height: 8),
                  Text("Destination",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(locationProvider.requestedDestination ?? 'Loading...'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRidePrice(AppStateProvider appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: "Ride Price", size: 16, weight: FontWeight.bold),
        Text(
          "\$${appState.ridePrice.toStringAsFixed(2)}",
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
          provider.cancelRequestListener();
          provider.cancelRequest();
          locationProvider.cancelRequest();
        },
        child: Text("Cancel Ride",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
