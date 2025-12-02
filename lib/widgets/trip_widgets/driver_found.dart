import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../locators/service_locator.dart';
import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/user_provider.dart';
import '../../services/call_sms.dart';

class DriverFoundWidget extends StatefulWidget {
  const DriverFoundWidget({Key? key}) : super(key: key);

  @override
  _DriverFoundWidgetState createState() => _DriverFoundWidgetState();
}

class _DriverFoundWidgetState extends State<DriverFoundWidget> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, myscrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            boxShadow: const [
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
                child: Text(
                  appState.currentTrip?.status == TripStatus.arrived_at_pickup
                      ? 'Your ride has arrived'
                      : 'Your ride arrives in ${locationProvider.routeModel?.timeNeeded.text ?? '...'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appState.currentTrip?.status == TripStatus.arrived_at_pickup ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const Divider(thickness: 1.5),
              _buildDriverInfo(appState),
              const Divider(thickness: 1.5),
              _buildRideDetails(appState),
              const Divider(thickness: 1.5),
              _buildRidePrice(appState),
              const SizedBox(height: 12),
              _buildCancelButton(appState, locationProvider, userProvider),
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
        backgroundImage: null,
        child: appState.driver?.profilePhotoUrl == null
            ? const Icon(Icons.person_outline, size: 30, color: Colors.white)
            : null,
      ),
      title: Text(
        appState.driver?.name ?? 'Loading...',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appState.driver?.carModel ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
          ),
          const SizedBox(
            width: Dimensions.paddingSize,
          ),
          Text(
            appState.driver?.licensePlate ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Dimensions.fontSizeDefault, color: Colors.black),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green, size: 30),
        onPressed: () {
            _service.call(appState.driver!.name);
        },
      ),
    );
  }

  Widget _buildRideDetails(AppStateProvider appState) {
    final locationProvider = Provider.of<LocationProvider>(context);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ride details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pickup Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(locationProvider.locationAddress ?? 'Loading...'),
                  const SizedBox(height: 8),
                  const Text("Destination",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(appState.currentTrip!.destinationAddress),
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
        const Text("Ride Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          "\Ksh ${appState.currentTrip?.price}",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCancelButton(
      AppStateProvider provider, LocationProvider locationProvider, UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          final accessToken = userProvider.accessToken;
          if (accessToken != null) {
            provider.cancelTrip(accessToken);
          }
        },
        child: const Text("Cancel Ride",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
