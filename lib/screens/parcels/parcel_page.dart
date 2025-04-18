import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/parcels/find_driver.dart';
import 'package:BucoRide/screens/parcels/parcel_vehicle_selection.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/utils/dimensions.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:BucoRide/widgets/parcel_widgets/parcel_type_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../providers/user.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderContactController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientContactController =
      TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? _myAddress;
  String? selectedParcelType;
  String? selectedVehicleType;
  LatLng? selectedDestination;

  // Define available options
  final List<String> parcelTypes = [
    "Standard",
    "Medium Package",
    "Large Package"
  ];
  final List<String> vehicleTypes = ["Moto Express", "Car", "Truck"];

  // Add this method
  @override
  void initState() {
    super.initState();

    // Set default values for parcel and vehicle type
    selectedParcelType = parcelTypes.first; // Set to first parcel type
    selectedVehicleType = vehicleTypes.first; // Set to first vehicle type

    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.fetchLocation();
  }

  void submitData() async {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    if (selectedParcelType == null ||
        senderNameController.text.isEmpty ||
        senderContactController.text.isEmpty ||
        recipientNameController.text.isEmpty ||
        recipientContactController.text.isEmpty ||
        destinationController.text.isEmpty ||
        weightController.text.isEmpty) {
      appState.showCustomSnackBar(
          context,
          "Please fill all fields and select a parcel type.",
          AppConstants.darkPrimary);
      return;
    }
    if (selectedDestination == null) {
      appState.showCustomSnackBar(
          context, "Select a proper Destination.", AppConstants.darkPrimary);
      return;
    }

    double? weight = double.tryParse(weightController.text);
    if (weight == null || weight > 100) {
      appState.showCustomSnackBar(
          context,
          "Weight must be a number and not exceed 100kg.",
          AppConstants.darkPrimary);
      return;
    }

    appState.resetPackageVariables();

    locationProvider.fetchRoute(
        LatLng(locationProvider.currentPosition!.latitude,
            locationProvider.currentPosition!.longitude),
        LatLng(selectedDestination!.latitude, selectedDestination!.longitude));

    double distance =
        (locationProvider.routeModel?.distance.value ?? 0).toDouble();

    // You should calculate this using Google Maps API

    // Calculate price
    double totalPrice =
        appState.calculatePrice(distance, weight, selectedVehicleType!);

    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Parcel Order"),
          content: Text(
              "Total cost: \ksh ${totalPrice.toStringAsFixed(2)}. Proceed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    Map<String, dynamic> parcelData = {
      "userId": userProvider.userModel?.id,
      "senderName": senderNameController.text.trim(),
      "senderContact": senderContactController.text.trim(),
      "recipientName": recipientNameController.text.trim(),
      "recipientContact": recipientContactController.text.trim(),
      "destination": destinationController.text.trim(),
      "positionAddress": locationProvider.locationAddress,
      "destinationLatLng": selectedDestination != null
          ? {
              "lat": selectedDestination!.latitude,
              "lng": selectedDestination!.longitude
            }
          : null,
      "weight": weight,
      "totalPrice": totalPrice,
      "parcelType": selectedParcelType,
      "vehicleType": selectedVehicleType,
      "status": "PENDING",
      "timestamp": FieldValue.serverTimestamp(),
    };

    print(" THe final price is ${totalPrice}");
    appState.requestParcelDriver(
      userId: parcelData["userId"],
      senderName: parcelData["senderName"],
      senderContact: parcelData["senderContact"],
      recipientName: parcelData["recipientName"],
      recipientContact: parcelData["recipientContact"],
      positionAddress: parcelData["positionAddress"],
      destination: parcelData["destination"],
      destinationLatLng: parcelData["destinationLatLng"],
      totalPrice: parcelData["totalPrice"],
      weight: parcelData["weight"],
      lat: locationProvider.center.latitude,
      lng: locationProvider.center.longitude,
      parcelType: parcelData["parcelType"],
      vehicleType: parcelData["vehicleType"],
      context: context,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Parcel details submitted!")));

    senderNameController.clear();
    senderContactController.clear();
    recipientNameController.clear();
    recipientContactController.clear();
    destinationController.clear();
    weightController.clear();
    setState(() {
      selectedParcelType = null;
      selectedDestination = null;
    });
    changeScreen(context, FindParcelDriverScreen());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style:
            TextStyle(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade700),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white12,
        ),
      ),
    );
  }

  void _openMapBottomSheet() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final position = locationProvider.currentPosition;
    List<Prediction> predictions = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // This allows rebuilding the modal
            void searchPlaces(String input) async {
              if (input.isEmpty) {
                setModalState(() => predictions = []);
                return;
              }

              try {
                print(
                    'Requesting autocomplete with input: $input and components: ${Component(Component.country, country_global_key)}');
                final response = await GoogleMapsPlaces(
                        apiKey: AppConstants.GOOGLE_MAPS_API_KEY)
                    .autocomplete(
                  input,
                  language: 'en',
                  components: [
                    Component(Component.country, country_global_key)
                  ],
                );
                print('Autocomplete response status: ${response.status}');
                print('Predictions: ${response.predictions}');
                setModalState(() {
                  predictions = response.predictions.take(3).toList();
                });
              } catch (e) {
                print('Error: $e');
              }
            }

            return Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    autofocus: true,
                    onTapAlwaysCalled: true,
                    onChanged: searchPlaces,
                    controller: destinationController,
                    decoration: InputDecoration(
                      fillColor: Colors.white12,
                      hintText: "Search Destination",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.black),
                  ),
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  if (predictions.isNotEmpty)
                    Column(
                      children: predictions.map((prediction) {
                        return ListTile(
                          leading:
                              Icon(Icons.location_on, color: Colors.redAccent),
                          title: Text(prediction.description ?? ''),
                          onTap: () async {
                            final details = await GoogleMapsPlaces(
                                    apiKey: GOOGLE_MAPS_API_KEY)
                                .getDetailsByPlaceId(prediction.placeId ?? '');

                            final double lat =
                                details.result.geometry?.location.lat ?? 0.0;
                            final double lng =
                                details.result.geometry?.location.lng ?? 0.0;

                            setModalState(() {
                              destinationController.text =
                                  prediction.description ?? '';
                              selectedDestination = LatLng(lat, lng);
                            });

                            print("animating camera");
                            locationProvider.mapController?.animateCamera(
                                CameraUpdate.newLatLng(selectedDestination!));
                            await Future.delayed(Duration(seconds: 3));
                            //KisNavigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  SizedBox(height: Dimensions.paddingSize),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(border_radius),
                          topRight: Radius.circular(border_radius)),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target:
                                LatLng(position!.latitude, position.longitude),
                            zoom: 17.0),
                        onMapCreated: (GoogleMapController controller) {
                          locationProvider.onCreate(controller);
                        },
                        onTap: (latLng) {
                          setModalState(() {
                            selectedDestination = latLng;
                          });
                          locationProvider.mapController
                              ?.animateCamera(CameraUpdate.newLatLng(latLng));
                        },
                        compassEnabled: true,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                        markers: selectedDestination != null
                            ? {
                                Marker(
                                  markerId: MarkerId("selected"),
                                  position: selectedDestination!,
                                )
                              }
                            : {},
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.paddingSizeDefault,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue, // Background color
                        backgroundColor: AppConstants.lightPrimary,
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.locationAddress == null) {
      locationProvider.fetchLocation();
      _myAddress = locationProvider.locationAddress;
    }
    return Scaffold(
      appBar: const CustomAppBar(
          title: "Parcel", showNavBack: true, centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
                controller: senderNameController,
                label: "Sender Name",
                icon: Icons.person),
            _buildTextField(
                controller: senderContactController,
                label: "Sender Contact",
                icon: Icons.phone,
                inputType: TextInputType.phone),
            _buildTextField(
                controller: recipientNameController,
                label: "Recipient Name",
                icon: Icons.receipt_long),
            _buildTextField(
                controller: recipientContactController,
                label: "Recipient Contact",
                icon: Icons.call,
                inputType: TextInputType.phone),
            GestureDetector(
              onTap: _openMapBottomSheet,
              child: AbsorbPointer(
                child: _buildTextField(
                    controller: destinationController,
                    label: "Destination Address",
                    icon: Icons.map),
              ),
            ),
            _buildTextField(
                controller: weightController,
                label: "Weight (max 100kg)",
                icon: Icons.scale,
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*'))
                ]),
            SizedBox(height: Dimensions.paddingSize),
            ParcelTypeSelection(
              onSelected: (type) => setState(() => selectedParcelType = type),
              selectedType: selectedParcelType,
            ),
            SizedBox(height: Dimensions.paddingSize),
            ParcelVehicleSelection(
              onSelected: (type) => setState(() => selectedVehicleType = type),
              selectedType: selectedVehicleType,
            ),
            SizedBox(height: 30),
            Center(
                child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue, // Background color
                  backgroundColor: AppConstants.lightPrimary,
                ),
                child: Text(
                  "Submit Parcel",
                  style: const TextStyle(
                    fontSize: Dimensions.paddingSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
