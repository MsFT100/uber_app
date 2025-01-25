import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/style.dart';
import '../providers/app_state.dart';

class DestinationSelectionWidget extends StatelessWidget {
  const DestinationSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.28,
      builder: (BuildContext context, ScrollController myScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
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
              const Icon(
                Icons.remove,
                size: 40,
                color: grey,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                      final Prediction? prediction =
                          await PlacesAutocomplete.show(
                        context: context,
                        apiKey: GOOGLE_MAPS_API_KEY,
                        mode: Mode.overlay,
                        components: country != null
                            ? [Component(Component.country, country)]
                            : [],
                      );

                      if (prediction != null) {
                        PlacesDetailsResponse detail = (await places
                                .getDetailsByPlaceId(prediction.placeId ?? ''))
                            as PlacesDetailsResponse;
                        final double lat =
                            detail.result.geometry?.location.lat ?? 0.0;
                        final double lng =
                            detail.result.geometry?.location.lng ?? 0.0;

                        appState.changeRequestedDestination(
                          reqDestination: prediction.description ?? '',
                          lat: lat,
                          lng: lng,
                        );
                        appState.updateDestination(
                            destination: prediction.description ?? '');
                        LatLng coordinates = LatLng(lat, lng);
                        appState.setDestination(coordinates: coordinates);
                        appState.addPickupMarker(appState.center);
                        appState.changeWidgetShowed(
                            showWidget: Show.PICKUP_SELECTION);
                      }
                    },
                    textInputAction: TextInputAction.go,
                    controller: appState.destinationController,
                    cursorColor: Colors.blue.shade900,
                    decoration: const InputDecoration(
                      icon: Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 15),
                        child: Icon(Icons.location_on, color: primary),
                      ),
                      hintText: "Where to go?",
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
              ..._buildLocationList(),
            ],
          ),
        );
      },
    );
  }

  // Helper method to create location list tiles
  List<Widget> _buildLocationList() {
    final List<Map<String, dynamic>> locations = [
      {
        'icon': Icons.home,
        'title': "Home",
        'subtitle': "25th Avenue, 23 Street"
      },
      {
        'icon': Icons.work,
        'title': "Work",
        'subtitle': "25th Avenue, 23 Street"
      },
      {
        'icon': Icons.history,
        'title': "Recent location",
        'subtitle': "25th Avenue, 23 Street"
      },
    ];

    return locations.map((location) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: location['icon'] == Icons.history
              ? Colors.grey.withOpacity(0.18)
              : Colors.deepOrange[300],
          child: Icon(location['icon'],
              color: location['icon'] == Icons.history ? primary : white),
        ),
        title: Text(location['title']),
        subtitle: Text(location['subtitle']),
      );
    }).toList();
  }
}
