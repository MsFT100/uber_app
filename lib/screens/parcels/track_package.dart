import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../locators/service_locator.dart';
import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../services/call_sms.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/custom_text.dart';
import '../map.dart';

class TrackPackage extends StatefulWidget {
  const TrackPackage({super.key});

  @override
  State<TrackPackage> createState() => _TrackPackageState();
}

class _TrackPackageState extends State<TrackPackage> {
  double totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    final locationProvider = Provider.of<LocationProvider>(context);
    final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

    totalPrice = appState.parcelPrice;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Parcel',
        showNavBack: true,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          MapScreen(),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (BuildContext context, myscrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(0, -3),
                        blurRadius: 8),
                  ],
                ),
                child: ListView(
                  controller: myscrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    Center(
                      child: CustomText(
                        text: 'ON TRANSIT',
                        weight: FontWeight.bold,
                        color: Colors.green,
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slide(begin: Offset(0, -0.3), end: Offset(0, 0)),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: appState.driverModel?.photo != null
                            ? NetworkImage(appState.driverModel!.photo)
                            : null,
                        child: appState.driverModel?.photo == null
                            ? Icon(Icons.person_outline, size: 30)
                            : null,
                      ).animate().fadeIn(duration: 600.ms),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            appState.driverModel?.name ?? "Loading...",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            appState.driverModel?.model ?? "",
                            style: TextStyle(
                                fontSize: 14, color: AppConstants.lightPrimary),
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
                    ),
                    Divider(),

                    ///Ride Details
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomText(
                          text: "Ride details",
                          size: 16,
                          weight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Icon(Icons.location_on, color: Colors.redAccent),
                            Container(height: 40, width: 2, color: Colors.blue),
                            Icon(Icons.flag, color: Colors.black),
                          ],
                        ).animate().fadeIn(duration: 700.ms),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pickup Location",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(locationProvider.locationAddress ??
                                  'Loading...'),
                              SizedBox(height: 8),
                              Text("Destination",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(appState.parcelRequestModel?.destination ??
                                  'Loading...'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(),

                    ///Ride Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: "Ride price",
                            size: 16,
                            weight: FontWeight.bold),
                        Text(
                          "\ ksh ${totalPrice}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ).animate().fadeIn(duration: 800.ms),
                      ],
                    ),
                    SizedBox(height: 16),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.red,
                    //     padding: EdgeInsets.symmetric(vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8)),
                    //   ),
                    //   onPressed: () {
                    //     locationProvider.cancelRequest();
                    //     appState.cancelRequest();
                    //     appState.cancelRequestListener();
                    //   },
                    //   child:
                    //       CustomText(text: "END MY TRIP", color: Colors.white),
                    // )
                    //     .animate()
                    //     .fadeIn(duration: 900.ms)
                    //     .scale(begin: 0.9, end: 1.0),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
