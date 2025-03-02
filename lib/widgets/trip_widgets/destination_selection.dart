import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as th;
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../loading_widgets/loading.dart';

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
      DraggableScrollableController();
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

    setState(() => _isSearching = true);

    try {
      final response =
          await th.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY).autocomplete(
        input,
        language: 'en',
        components: [th.Component(th.Component.country, country_global_key)],
      );

      setState(() {
        predictions = response.predictions;
        _isSearching = false;
      });

      if (predictions.isNotEmpty && _draggableController.isAttached) {
        _draggableController.animateTo(0.8,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.4,
      minChildSize: 0.35,
      maxChildSize: 1,
      builder: (context, dragScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(100),
                offset: const Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ScrollSheetBar(),
              const SizedBox(height: Dimensions.paddingSize),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBox(locationProvider),
              ),
              _buildRecentLocations(locationProvider),
              Expanded(
                child: _isSearching
                    ? Center(child: Loading())
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

  Widget _buildSearchBox(LocationProvider provider) {
    return Container(
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
        controller: provider.destinationController,
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
    );
  }

  Widget _buildRecentLocations(LocationProvider provider) {
    if (provider.recentDestinations.isEmpty) return SizedBox(); // Hide if empty

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Locations",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: provider.recentDestinations.map((location) {
              return GestureDetector(
                onTap: () {
                  provider.setDestination(
                      coordinates: LatLng(location.lat, location.lng));
                },
                child: Chip(
                  avatar: const Icon(Icons.history, color: Colors.blue),
                  label: Text(location.name),
                  backgroundColor: Colors.grey.shade200,
                ),
              );
            }).toList(),
          ),
        ],
      ),
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

          if (mounted) {
            // Ensure widget is still mounted before calling setState()
            setState(() {
              predictions = [];
              _isSearching = false;
            });
          }
        },
      );
    }).toList();
  }
}
