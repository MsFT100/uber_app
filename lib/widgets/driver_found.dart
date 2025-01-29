import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/style.dart';
import '../locators/service_locator.dart';
import '../providers/app_state.dart';
import '../services/call_sms.dart';
import 'custom_text.dart';

class DriverFoundWidget extends StatelessWidget {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.05,
      maxChildSize: 0.8,
      builder: (BuildContext context, myscrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.8),
                offset: const Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: ListView(
            controller: myscrollController,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: appState.driverArrived
                        ? 'Your ride has arrived'
                        : 'Your ride arrives in ${appState.routeModel?.timeNeeded.text ?? '...'}',
                    size: 12,
                    weight: FontWeight.w300,
                    color: appState.driverArrived ? green : grey,
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: appState.driverModel.photo != null
                      ? NetworkImage(appState.driverModel.photo)
                      : null,
                  child: appState.driverModel.photo == null
                      ? const Icon(Icons.person_outline, size: 25)
                      : null,
                ),
                title: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${appState.driverModel?.name ?? 'Driver'}\n",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: appState.driverModel.car ?? 'Car info',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                      style: const TextStyle(color: black),
                    ),
                  ),
                ),
                subtitle: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: null,
                  child: CustomText(
                    text: appState.driverModel?.plate ?? 'Plate info',
                    color: white,
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final phone = appState.driverModel.phone;
                      if (phone != null) {
                        _service.call(phone);
                      }
                    },
                    icon: const Icon(Icons.call),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(12),
                child: CustomText(
                  text: "Ride details",
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const Icon(Icons.location_on, color: grey),
                      Container(
                        height: 45,
                        width: 2,
                        color: primary,
                      ),
                      const Icon(Icons.flag),
                    ],
                  ),
                  const SizedBox(width: 30),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "\nPick up location \n",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${appState.pickupAddress ?? 'Loading...'} \n\n\n",
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: "Destination \n",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${appState.destinationAddress ?? 'Loading...'} \n",
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      style: const TextStyle(color: black),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CustomText(
                      text: "Ride price",
                      size: 18,
                      weight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomText(
                      text: "\$${appState.ridePrice.toStringAsFixed(2)}",
                      size: 18,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: red),
                  onPressed: () {
                    // Implement ride cancellation logic here.
                  },
                  child: const CustomText(
                    text: "Cancel Ride",
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
