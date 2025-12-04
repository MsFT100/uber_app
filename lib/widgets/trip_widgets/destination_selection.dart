import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/scroll_sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../loading_widgets/loading.dart';

class DestinationSelectionWidget extends StatefulWidget {
  const DestinationSelectionWidget({Key? key}) : super(key: key);

  @override
  State<DestinationSelectionWidget> createState() =>
      _DestinationSelectionWidgetState();
}

class _DestinationSelectionWidgetState extends State<DestinationSelectionWidget> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    // Add a listener to expand the sheet when search results appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      locationProvider.addListener(() {
        if (locationProvider.predictions.isNotEmpty &&
            _draggableController.isAttached) {
          _draggableController.animateTo(0.8,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
      });
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBox(locationProvider),
              ),
              Expanded(
                child: locationProvider.isSearching
                    ? Center(child: Loading())
                    : locationProvider.predictions.isEmpty &&
                            locationProvider.destinationController.text.isNotEmpty
                        ? const Center(
                            child: Text(
                              "No locations found.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            controller: dragScrollController,
                            itemCount: locationProvider.predictions.length,
                            itemBuilder: (context, index) {
                              final prediction = locationProvider.predictions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Colors.grey),
                                title: Text(prediction['description'] ?? ''),
                                onTap: () {
                                  locationProvider.getPlaceDetails(prediction['place_id'] ?? '');
                                  // Animate the sheet down after a selection is made
                                  _draggableController.animateTo(0.4, // Back to initial size
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                },
                              );
                            },
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
        onChanged: (value) => provider.searchPlaces(value),
        onTap: () {
          if (_draggableController.isAttached) {
            _draggableController.animateTo(0.95,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          }
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
          suffixIcon: provider.destinationController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    provider.clearPredictions();
                    _draggableController.animateTo(0.4, // Back to initial size
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
