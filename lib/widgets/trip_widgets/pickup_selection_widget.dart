import 'package:BucoRide/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/style.dart';
import '../../utils/dimensions.dart';

class PickupSelectionWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const PickupSelectionWidget({super.key, required this.scaffoldState});

  @override
  _PickupSelectionWidgetState createState() => _PickupSelectionWidgetState();
}

class _PickupSelectionWidgetState extends State<PickupSelectionWidget> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);
  bool _isLoading = false;
  List<Prediction> _predictions = [];

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    try {
      final response = await _places.autocomplete(
        input,
        language: 'en',
        components: [Component(Component.country, country_global_key)],
      );

      setState(() {
        _predictions = response.predictions;
      });

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
    final locationProvider = Provider.of<LocationProvider>(context);

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.35,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (BuildContext context, ScrollController myScrollController) {
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
              const SizedBox(height: 12),
              Text(
                "Move the pin to adjust pickup location",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeSmall,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(),
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
                    onTap: () => _draggableController.animateTo(0.95,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    controller: locationProvider.pickupLocationController,
                    cursorColor: Colors.blue.shade900,
                    decoration: InputDecoration(
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 15),
                        child: Icon(Icons.location_on, color: primary),
                      ),
                      hintText: "Pick up location",
                      hintStyle: TextStyle(
                        color: black,
                        fontSize: Dimensions.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),
                ),
              ),

              // Show search results
              if (_predictions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      return ListTile(
                        title: Text(prediction.description ?? ''),
                        onTap: () async {
                          final PlacesDetailsResponse detail = await _places
                              .getDetailsByPlaceId(prediction.placeId ?? '');
                          final lat =
                              detail.result.geometry?.location.lat ?? 0.0;
                          final lng =
                              detail.result.geometry?.location.lng ?? 0.0;

                          // Update app state
                          locationProvider.pickupCoordinates = LatLng(lat, lng);

                          // Clear predictions after selection
                          setState(() {
                            _predictions = [];
                          });
                        },
                      );
                    },
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true; // Show loading
                            });

                            locationProvider.show = Show.PAYMENT_METHOD_SELECTION;

                            setState(() {
                              _isLoading = false; // Hide loading
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: SpinKitFoldingCube(
                              color: Colors.black,
                              size: 20,
                            ),
                          )
                        : const Text(
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
