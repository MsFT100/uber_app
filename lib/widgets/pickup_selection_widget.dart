import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/style.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import 'custom_text.dart';

class PickupSelectionWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const PickupSelectionWidget({super.key, required this.scaffoldState});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.28,
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CustomText(
                    text: "Move the pin to adjust pickup location",
                    size: 12,
                    weight: FontWeight.w300,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onTap: () async {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      final String? country = preferences.getString(COUNTRY);

                      final prediction = await showSearchDialog(
                        context,
                        country,
                      );

                      if (prediction != null) {
                        // Fetch place details
                        final GoogleMapsPlaces _places = GoogleMapsPlaces(
                          apiKey: GOOGLE_MAPS_API_KEY,
                        );

                        final PlacesDetailsResponse detail = await _places
                            .getDetailsByPlaceId(prediction.placeId ?? '');

                        final lat = detail.result.geometry?.location.lat ?? 0.0;
                        final lng = detail.result.geometry?.location.lng ?? 0.0;

                        // Update state
                        appState.changeRequestedDestination(
                          reqDestination: prediction.description ?? '',
                          lat: lat,
                          lng: lng,
                        );
                        appState.updateDestination(
                            destination: prediction.description ?? '');
                        appState.setPickCoordinates(
                            coordinates: LatLng(lat, lng));
                        appState.changePickupLocationAddress(
                            address: prediction.description ?? '');
                      }
                    },
                    textInputAction: TextInputAction.go,
                    controller: appState.pickupLocationControlelr,
                    cursorColor: Colors.blue.shade900,
                    decoration: const InputDecoration(
                      icon: Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 15),
                        child: Icon(Icons.location_on, color: primary),
                      ),
                      hintText: "Pick up location",
                      hintStyle: TextStyle(
                        color: black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await appState.sendRequest(
                          origin: appState.pickupCoordinates,
                          destination: appState.destinationCoordinates);
                      appState.changeWidgetShowed(
                          showWidget: Show.PAYMENT_METHOD_SELECTION);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Confirm Pickup",
                      style: TextStyle(color: white, fontSize: 16),
                    ),
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

Future<Prediction?> showSearchDialog(
    BuildContext context, String? country) async {
  final response =
      await GoogleMapsPlaces(apiKey: AppConstants.GOOGLE_MAPS_API_KEY)
          .autocomplete(
    '',
    language: 'en',
    components: country != null ? [Component(Component.country, country)] : [],
  );

  // Show search results and allow the user to select a prediction
  final prediction = await showDialog<Prediction>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select a location"),
        content: ListView.builder(
          itemCount: response.predictions.length,
          itemBuilder: (context, index) {
            final prediction = response.predictions[index];
            return ListTile(
              title: Text(prediction.description ?? ''),
              onTap: () => Navigator.pop(context, prediction),
            );
          },
        ),
      );
    },
  );
  return prediction;
}
