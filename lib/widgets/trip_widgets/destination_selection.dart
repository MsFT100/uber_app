import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../loading.dart';

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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        predictions = [];
        _isSearching = false;
      });
      return;
    }

    print("Searching for places: $input");

    setState(() => _isSearching = true); // Start loading

    try {
      final response =
          await th.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY).autocomplete(
        input,
        language: 'en',
        components: [th.Component(th.Component.country, country_global_key)],
      );

      setState(() {
        predictions = response.predictions;
        _isSearching = false; // Stop loading after getting results
      });

      // Expand sheet only if results are found
      if (predictions.isNotEmpty && _draggableController.isAttached) {
        _draggableController.animateTo(0.8,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    } catch (e) {
      print("Error fetching predictions: $e");
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 1,
      snap: false,
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
                color: Colors.grey,
                offset: const Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 25),
              ScrollSheetBar(),
              const SizedBox(height: Dimensions.paddingSize),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: searchPlaces,
                    onTap: () {
                      if (_draggableController.isAttached) {
                        _draggableController.animateTo(0.95,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                      setState(() => _isSearching = true);
                    },
                    textInputAction: TextInputAction.search,
                    controller: locationProvider.destinationController,
                    cursorColor: Colors.blue.shade900,
                    decoration: InputDecoration(
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.search, color: Colors.blue),
                      ),
                      hintText: "Where to go?",
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: Dimensions.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isSearching
                    ? Center(
                        child: Loading(),
                      ) // Show loading indicator
                    : predictions.isEmpty
                        ? const Center(
                            child: Text(
                              "No locations found.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView(
                            physics: const ClampingScrollPhysics(),
                            controller: dragScrollController,
                            children: _buildLocationList(locationProvider),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLocationList(LocationProvider provider) {
    return predictions.map((prediction) {
      return ListTile(
        leading: const Icon(Icons.location_on, color: Colors.grey),
        title: Text(prediction.description ?? ''),
        onTap: () async {
          final details = await th.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY)
              .getDetailsByPlaceId(prediction.placeId ?? '');

          final double lat = details.result.geometry?.location.lat ?? 0.0;
          final double lng = details.result.geometry?.location.lng ?? 0.0;

          provider.changeRequestedDestination(
            reqDestination: prediction.description ?? '',
            lat: lat,
            lng: lng,
          );

          provider.updateDestination(destination: prediction.description ?? '');
          provider.setDestination(coordinates: LatLng(lat, lng));
          provider.changeWidgetShowed(showWidget: Show.PICKUP_SELECTION);

          // Clear predictions after selection
          setState(() {
            predictions = [];
            _isSearching = false;
          });
        },
      );
    }).toList();
  }
}
