import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../helpers/style.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import 'custom_text.dart';

class PaymentMethodSelectionWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const PaymentMethodSelectionWidget({super.key, required this.scaffoldState});

  @override
  Widget build(BuildContext context) {
    final AppStateProvider appState = Provider.of<AppStateProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      builder: (BuildContext context, ScrollController myScrollController) {
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
            controller: myScrollController,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomText(
                  text: "How do you want to pay,\n\$${appState.ridePrice}",
                  size: 24,
                  weight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Payment Option
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Method not available!")),
                        );
                      },
                      icon: const Icon(Icons.credit_card),
                      label: const CustomText(text: "With Card"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.blue.withOpacity(0.3), width: 1.5),
                      ),
                    ),
                    // Cash Payment Option
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.monetization_on),
                      label: const CustomText(text: "With Cash"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              appState.lookingForDriver
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        color: white,
                        child: const ListTile(
                          title: SpinKitWave(
                            color: black,
                            size: 30,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (userProvider.userModel == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("User information is missing!")),
                              );
                              return;
                            }
                            appState.requestDriver(
                              distance: appState.routeModel.distance.toJson(),
                              user: userProvider.userModel!,
                              lat: appState.pickupCoordinates.latitude,
                              lng: appState.pickupCoordinates.longitude,
                              context: context,
                            );
                            appState.changeMainContext(context);

                            // Show Driver Search Dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: SizedBox(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SpinKitWave(
                                            color: black,
                                            size: 30,
                                          ),
                                          const SizedBox(height: 10),
                                          const Center(
                                            child: CustomText(
                                              text: "Looking for a driver",
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          LinearPercentIndicator(
                                            lineHeight: 4,
                                            animation: true,
                                            animationDuration: 100000,
                                            percent: 1,
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.2),
                                            progressColor: Colors.deepOrange,
                                          ),
                                          const SizedBox(height: 20),
                                          Center(
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                appState.cancelRequest();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Request cancelled!")),
                                                );
                                              },
                                              child: const CustomText(
                                                text: "Cancel Request",
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Request",
                            style: TextStyle(color: white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
