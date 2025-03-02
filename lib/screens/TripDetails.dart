import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';

class TripDetails extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetails({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  Set<Marker> _markers = {};
  late bool isParcel; // Detect trip type

  @override
  void initState() {
    super.initState();
    isParcel = widget.trip.containsKey('parcelType'); // Check if it's a parcel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMap();
    });
  }

  _setupMap() async {
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    double pickuplat = widget.trip['position']['latitude'];
    double pickuplng = widget.trip['position']['longitude'];
    double destinationlat = widget.trip['destination']['latitude'];
    double destinationlng = widget.trip['destination']['longitude'];

    LatLng pickupLocation = LatLng(pickuplat, pickuplng);
    LatLng destinationLocation = LatLng(destinationlat, destinationlng);

    locationProvider.addTripHistoryMarkers(pickupLocation, destinationLocation);
    locationProvider.addRiderRoutePolyline(pickupLocation, destinationLocation);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(pickupLocation.latitude, destinationlat),
        min(pickupLocation.longitude, destinationlng),
      ),
      northeast: LatLng(
        max(pickupLocation.latitude, destinationlat),
        max(pickupLocation.longitude, destinationlng),
      ),
    );

    _animateCam(bounds);
  }

  _animateCam(LatLngBounds bounds) {
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void _showTripDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    Text(
                      isParcel ? "Parcel Trip Summary" : "Ride Trip Summary",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text(
                        widget.trip['username'] ?? "Unknown User",
                        style: TextStyle(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        isParcel ? Icons.local_shipping : Icons.directions_car,
                        color: Colors.green,
                      ),
                      title: Text(
                        "Distance: ${widget.trip['distance']['text'] ?? 'N/A'}",
                        style: TextStyle(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money, color: Colors.orange),
                      title: Text(
                        "Fare: ksh ${isParcel ? widget.trip['totalPrice'] : widget.trip['distance']['value']}",
                        style: TextStyle(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                    if (isParcel) ...[
                      ListTile(
                        leading: Icon(Icons.category, color: Colors.purple),
                        title: Text(
                          "Parcel Type: ${widget.trip['parcelType']}",
                          style:
                              TextStyle(fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.local_offer, color: Colors.red),
                        title: Text(
                          "Parcel Weight: ${widget.trip['parcelWeight']} kg",
                          style:
                              TextStyle(fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                            label: Text("Close"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final _mapController = locationProvider.mapController;
    final position = locationProvider.currentPosition;
    final Set<Polyline> _polylines = locationProvider.polylines;

    return Scaffold(
      appBar: CustomAppBar(
        title: isParcel ? "Parcel Trip" : "Ride Trip",
        showNavBack: true,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(position!.latitude, position.longitude),
                zoom: 16),
            onMapCreated: (GoogleMapController controller) {
              locationProvider.onCreate(controller);
            },
            myLocationEnabled: false,
            mapType: MapType.normal,
            tiltGesturesEnabled: false,
            compassEnabled: true,
            markers: _markers,
            onCameraMove: locationProvider.onCameraMove,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _showTripDetails,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: AppConstants.lightPrimary,
              ),
              child: Text(
                "View Trip Details",
                style: TextStyle(
                    fontSize: Dimensions.fontSizeSmall, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
