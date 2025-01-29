import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';
import 'package:user_app/helpers/constants.dart';

import '../providers/app_state.dart';

class DestinationSelectionWidget extends StatefulWidget {
  const DestinationSelectionWidget({Key? key}) : super(key: key);

  @override
  State<DestinationSelectionWidget> createState() =>
      _DestinationSelectionWidgetState();
}

class _DestinationSelectionWidgetState
    extends State<DestinationSelectionWidget> {
  List<th.Prediction> predictions = [];
  final DraggableScrollableController _draggableController =
      DraggableScrollableController(); // Controller for sheet

  @override
  void initState() {
    super.initState();
  }

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => predictions = []);
      return;
    }
    print("NQNEIOQIQPIPQPJQOEVHQPIEJVPIQEJVPQJPOQJPVOQJ:" + input);
    try {
      final response =
          await th.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY).autocomplete(
        input,
        language: 'en',
        components: [
          th.Component(th.Component.country, country_global_key),
        ],
      );

      setState(() => predictions = response.predictions);

      // Expand sheet when user starts typing
      _draggableController.animateTo(
        0.95,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      print("Error fetching predictions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.95, // Full screen when expanded
      snapSizes: [0.4, 0.95],
      snap: true,
      builder: (context, dragScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                offset: const Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.remove, size: 40, color: Colors.grey),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: searchPlaces,
                  onTap: () => _draggableController.animateTo(0.95,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut), // Expand on tap
                  textInputAction: TextInputAction.search,
                  controller: appState.destinationController,
                  cursorColor: Colors.blue.shade900,
                  decoration: const InputDecoration(
                    icon: Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 15),
                      child: Icon(Icons.location_on, color: Colors.blue),
                    ),
                    hintText: "Where to go?",
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  controller: dragScrollController,
                  children: _buildLocationList(appState),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLocationList(AppStateProvider appState) {
    List<Widget> locationList = [
      const ListTile(
        leading: Icon(Icons.home, color: Colors.deepOrange),
        title: Text("Home"),
        subtitle: Text("25th Avenue, 23 Street"),
      ),
      const ListTile(
        leading: Icon(Icons.work, color: Colors.blue),
        title: Text("Work"),
        subtitle: Text("Business Avenue, Downtown"),
      ),
    ];

    // Append Predictions Below Default Locations
    locationList.addAll(predictions.map((prediction) {
      return ListTile(
        leading: const Icon(Icons.location_on, color: Colors.grey),
        title: Text(prediction.description ?? ''),
        onTap: () async {
          final details = await th.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY)
              .getDetailsByPlaceId(prediction.placeId ?? '');

          final double lat = details.result.geometry?.location.lat ?? 0.0;
          final double lng = details.result.geometry?.location.lng ?? 0.0;

          appState.changeRequestedDestination(
            reqDestination: prediction.description ?? '',
            lat: lat,
            lng: lng,
          );

          appState.updateDestination(destination: prediction.description ?? '');
          appState.setDestination(coordinates: LatLng(lat, lng));
          appState.changeWidgetShowed(showWidget: Show.PICKUP_SELECTION);

          // Clear predictions after selection
          setState(() {
            predictions = [];
          });
        },
      );
    }));

    return locationList;
  }
}
