import 'dart:async';

import 'package:BucoRide/models/parcelRequestModel.dart';
import 'package:BucoRide/services/drivers.dart';
import 'package:BucoRide/services/parcel_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../helpers/screen_navigation.dart';
import '../helpers/style.dart';
import '../models/driver.dart';
import '../models/ride_Request.dart';
import '../models/user.dart';
import '../screens/menu.dart';
import '../screens/parcels/track_package.dart';
import '../services/ride_requests.dart';
import '../utils/dimensions.dart';
import '../widgets/custom_btn.dart';
import '../widgets/custom_text.dart';
import '../widgets/stars.dart';
// driverId: 6HIUZjI2UxgGOCPAnQsvDGW8YPp1

// * THIS ENUM WILL CONTAIN THE DRAGGABLE WIDGET TO BE DISPLAYED ON THE MAIN SCREEN

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'ACCEPTED';
  static const CANCELLED = 'CANCELLED';
  static const PENDING = 'PENDING';
  static const EXPIRED = 'EXPIRED';

  static const DRIVER_AT_LOCATION_NOTIFICATION = 'DRIVER_AT_LOCATION';
  static const REQUEST_ACCEPTED_NOTIFICATION = 'REQUEST_ACCEPTED';
  static const TRIP_STARTED_NOTIFICATION = 'TRIP_STARTED';

  final Set<Marker> _markers = {};
  //  this polys will be displayed on the map
  Set<Polyline> _poly = {};
  // this polys temporarily store the polys to destination

  late Position current_position;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  //  Driver request related variables
  bool lookingForDriver = false;
  bool alertsOnUi = false;
  bool driverFound = false;
  bool driverArrived = false;
  bool driverCancelled = false;
  bool tripComplete = false;
  RideRequestServices _requestServices = RideRequestServices();
  ParcelRequestServices _parcelServices = ParcelRequestServices();

  DriverService _driverServices = DriverService();
  int timeCounter = 0;
  double percentage = 0;
  late Timer periodicTimer;

  String requestStatus = "";

  late RideRequestModel? rideRequestModel;
  late ParcelRequestModel? parcelRequestModel;
  late BuildContext mainContext;

  // this variable will keep track of the drivers position before and during the ride
  late StreamSubscription<QuerySnapshot> driverStream;
  late StreamSubscription<DocumentSnapshot>? _subscription;
  late StreamSubscription<DocumentSnapshot>? _parcelSubscription;

  DriverModel? driverModel;

  double ridePrice = 0;
  double parcelPrice = 0;
  String notificationType = "";
  String vehicleType = "";

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  AppStateProvider() {
    saveDeviceToken();
    // _listenToDrivers();
  }

  Future<bool> checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);
    }
    return isFirstLaunch;
  }

  get destinationAddress => null;

  get pickupAddress => null;

  // Method to add a marker
  void addMarker(Marker marker) {
    _markers.add(marker); // Add the marker to the set
    markers.forEach((marker) {
      print("Marker ID: ${marker.markerId.value}");
      print(
          "Position: ${marker.position.latitude}, ${marker.position.longitude}");
    });
    notifyListeners(); // Notify listeners to update the UI
  }

  // _updateDriverMarker(Marker marker) {
  //   _markers.remove(marker);
  //   sendRequest(
  //       origin: pickupCoordinates, destination: driverModel.getPosition());
  //   notifyListeners();
  //   // _addDriverMarker(
  //   //     position: driverModel.getPosition(),
  //   //     rotation: driverModel.position.heading,
  //   //     driverId: driverModel.id);
  // }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

// ANCHOR UI METHODS
  changeMainContext(BuildContext context) {
    mainContext = context;
    notifyListeners();
  }

  void showRequestCancelledSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 28), // Cancel icon
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "The delivery request has been canceled by the driver.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent, // Alert color
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4), // Snackbar lasts for 4 seconds
      ),
    );

    // Delay screen navigation until Snackbar disappears
    Future.delayed(Duration(seconds: 4), () {
      changeScreenReplacement(context, Menu());
    });
  }

  void showCustomSnackBar(
      BuildContext context, String content, Color snackBarColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 28), // Cancel icon
            SizedBox(width: 10),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: snackBarColor, // Alert color
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4), // Snackbar lasts for 4 seconds
      ),
    );

    // // Delay screen navigation until Snackbar disappears
    // Future.delayed(Duration(seconds: 4), () {
    //   changeScreenReplacement(context, Menu());
    // });
  }

  showRequestExpiredAlert(BuildContext context) {
    if (alertsOnUi) Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                          text: "DRIVERS NOT FOUND! \n TRY REQUESTING AGAIN")
                    ],
                  )),
            ),
          );
        });
  }

  showDriverBottomSheet(BuildContext context) {
    if (alertsOnUi) Navigator.pop(context);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: 400,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "7 MIN AWAY",
                        color: green,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: driverModel?.photo == null,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(40)),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 45,
                            child: Icon(
                              Icons.person,
                              size: 65,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: driverModel?.photo != null,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(40)),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(driverModel!.photo),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: driverModel!.name),
                    ],
                  ),
                  SizedBox(height: 10),
                  _stars(
                      rating: driverModel!.rating, votes: driverModel!.votes),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.directions_car),
                          label: Text(driverModel!.model)),
                      CustomText(
                        text: driverModel!.licensePlate,
                        color: Colors.deepOrange,
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomBtn(
                        text: "Call",
                        onTap: () {},
                        bgColor: green,
                        shadowColor: Colors.green,
                      ),
                      CustomBtn(
                        text: "Cancel",
                        onTap: () {},
                        bgColor: red,
                        shadowColor: Colors.redAccent,
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  _stars({required int votes, required double rating}) {
    if (votes == 0) {
      return StarsWidget(
        numberOfStars: 0,
        key: null,
      );
    } else {
      double finalRate = rating / votes;
      return StarsWidget(numberOfStars: finalRate.floor());
    }
  }

  saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    String? deviceToken = await fcm.getToken();

    if (deviceToken != null) {
      String? userId =
          prefs.getString('id'); // Ensure this returns the correct user ID

      if (userId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'token': deviceToken,
          });

          print("🚀 FCM Token updated in Firestore: $deviceToken");
        } catch (error) {
          print("Error updating token in Firestore: $error");
        }
      } else {
        print("User ID is null.");
      }
    } else {
      print("Device Token is null.");
    }
  }

  void listenToRequest({required String id, required BuildContext context}) {
    print("The id of document is: ========");
    print(id);
    lookingForDriver = true;

    _subscription = _requestServices.requestStream(id).listen((snapshot) {
      if (snapshot.exists) {
        print("Listening to Drivers");
        final data = snapshot.data() as Map<String, dynamic>?;

        if (data == null) return; // Prevent null errors

        final status = data['status'];

        if (status == 'ACCEPTED') {
          final driverId = data['driverId'];
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text("Driver $driverId accepted your request! 🚗")),
          // );
          driverFound = true;

          ///FETCH THE DRIVER DETAILS
          fetchDriver(driverId);
          print("Your ride request was accepted. ❌");
          //showDriverBottomSheet(context);
        } else if (status == 'CANCELLED') {
          driverCancelled = true;
          driverFound = false;
          showRequestCancelledSnackBar(context);
          print("Your ride request was cancelled. ❌");
          notifyListeners();
          cancelRequestListener();
        } else if (status == 'ARRIVED') {
          driverArrived = true;

          print("Your ride request has arrived. ❌");
          notifyListeners();
        } else if (status == 'ONTRIP') {
          driverArrived = true;
          tripComplete = false;
          print("Your on the trip. 🚗");
          notifyListeners();
        } else if (status == 'COMPLETED') {
          tripComplete = true;

          print("Your ride request was completed. Pls Pay Up. 🚗");

          notifyListeners();
        } else {
          print("XOJO");
        }
        //}
      }
    });
  }

  void listenToParcelRequest(
      {required String id, required BuildContext context}) {
    print("The id of document is: ========");
    print(id);
    lookingForDriver = true;
    notifyListeners();

    _parcelSubscription = _parcelServices.requestStream(id).listen((snapshot) {
      if (snapshot.exists) {
        print("Listening to Parcel Drivers");
        final data = snapshot.data() as Map<String, dynamic>?;

        if (data == null) return; // Prevent null errors

        final status = data['status'];

        if (status == 'ACCEPTED') {
          final driverId = data['driverId'];

          driverFound = true;

          ///FETCH THE DRIVER DETAILS
          fetchDriver(driverId);
          print("Your parcel request was accepted. ❌");
        } else if (status == 'CANCELLED') {
          driverCancelled = true;
          driverFound = false;
          showRequestCancelledSnackBar(context);
          print("Your parcel request was cancelled. ❌");
          notifyListeners();
          cancelParcelRequestListener();
        } else if (status == EXPIRED) {
          driverCancelled = false;
          driverFound = false;
          showRequestCancelledSnackBar(context);
          print("Your parcel request was expired ❌");
          notifyListeners();
          expiredRequestListener();
        } else if (status == 'ARRIVED') {
          driverArrived = true;
          print("Your ride request has arrived. ❌");
          changeScreenReplacement(context, TrackPackage());
          notifyListeners();
        } else if (status == 'ONTRIP') {
          driverArrived = true;
          tripComplete = false;
          print("Your on the trip. 🚗");
          changeScreenReplacement(context, TrackPackage());
          notifyListeners();
        } else if (status == 'COMPLETED') {
          tripComplete = true;
          print("Your ride request was completed. Pls Pay Up. 🚗");

          _showParcelDeliveryComplete(context);

          notifyListeners();
        } else {
          print("XOJO");
        }
        //}
      }
    });
  }

  void _showParcelDeliveryComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text("Delivery Completed",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your package has been delivered successfully! 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Total Amount: KES $parcelPrice",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                changeScreenReplacement(context, Menu()); // Navigate to Menu
              },
              child: Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
    // // Delay screen navigation until Snackbar disappears
  }

  resetPackageVariables() {
    ///Reset variables
    tripComplete = false;
    driverFound = false;
    driverArrived = false;
    lookingForDriver = false;
  }

  Future<void> fetchDriver(String driverId) async {
    print("🚀 Driver ID: ${driverId}");
    driverModel = await _driverServices.getDriverById(driverId);
    print("Driver Model Initialised");
    notifyListeners();
  }

  // Call this method when the listener is no longer needed
  void expiredRequestListener() {
    lookingForDriver = false;
    driverCancelled = false;
    _parcelSubscription?.cancel();
    print("Listening Parcel stream Cancelled");
  }

  // Call this method when the listener is no longer needed
  void cancelRequestListener() {
    lookingForDriver = false;
    tripComplete = false;
    driverCancelled = true;
    _subscription?.cancel();
    print("Listening Driver stream Cancelled");
  }

  // Call this method when the listener is no longer needed
  void cancelParcelRequestListener() {
    lookingForDriver = false;
    tripComplete = false;
    driverCancelled = true;
    _parcelSubscription?.cancel();
    print("Listening Parcel Driver stream Cancelled");
  }

  void requestDriver({
    required String vehicleType,
    required UserModel user,
    required double lat,
    required double lng,
    required BuildContext context,
    required Map distance,
    required String address,
    required LatLng destinationCoordinates,
  }) {
    alertsOnUi = true;
    notifyListeners();

    var uuid = Uuid();
    String requestId = uuid.v1(); // Unique request ID
    Map<String, dynamic> distanceMap = Map<String, dynamic>.from(distance);

    // Create Ride Request
    _requestServices.createRideRequest(
      id: requestId,
      userId: user.id,
      username: user.name,
      vehicleType: vehicleType,
      distance: {'text': distanceMap['text'], 'value': ridePrice},
      destination: {
        "address": address, // Replace with actual address
        "latitude": destinationCoordinates
            .latitude, // Replace with destination latitude
        "longitude": destinationCoordinates
            .longitude, // Replace with destination longitude
      },
      position: {
        "latitude": lat,
        "longitude": lng,
      },
    );
    print("=======================Creating Ride Request");

    // ✅ Assign the rideRequestModel after creating a request
    rideRequestModel = RideRequestModel.fromMap({
      "id": requestId,
      "userId": user.id,
      "username": user.name,
      "driverId": "",
      "position": {"latitude": lat, "longitude": lng},
      "destination": {
        "address": address,
        "latitude": destinationCoordinates
            .latitude, // Replace with destination latitude
        "longitude": destinationCoordinates.longitude,
      },
      "distance": distance,
      "status": "PENDING",
    });

    // Start listening for driver responses
    listenToRequest(id: requestId, context: context);
    percentageCounter(requestId: requestId, context: context);
  }

  void requestParcelDriver({
    required String userId,
    required String senderName,
    required String senderContact,
    required String recipientName,
    required String recipientContact,
    required String positionAddress,
    required String destination,
    required Map<String, dynamic>? destinationLatLng,
    required double lat,
    required double lng,
    required double weight,
    required double totalPrice,
    required String parcelType,
    required String vehicleType,
    required BuildContext context,
  }) {
    alertsOnUi = true;
    notifyListeners();

    var uuid = Uuid();
    String requestId = uuid.v1(); // Unique request ID
    // Map<String, dynamic> distanceMap = Map<String, dynamic>.from(distance);

    // Create Ride Request
    _parcelServices.createParcelRequest(
        id: requestId,
        userId: userId,
        senderName: senderName,
        senderContact: senderContact,
        recipientName: recipientName,
        recipientContact: recipientContact,
        positionAddress: positionAddress,
        destination: destination,
        destinationLatLng: destinationLatLng,
        position: {
          "latitude": lat,
          "longitude": lng,
        },
        weight: weight,
        totalPrice: totalPrice,
        parcelType: parcelType,
        vehicleType: vehicleType);
    print("=======================Creating Parcel Request");
    print("pARCEL pRICE: ${totalPrice}");
    parcelPrice = totalPrice;
    // ✅ Assign the parcelRequestModel after creating a request
    parcelRequestModel = ParcelRequestModel.fromMap({
      "id": requestId,
      "senderName": senderName,
      "senderContact": senderContact,
      "recipientName": recipientName,
      "recipientContact": recipientContact,
      "destination": destination,
      "destinationLatLng": destinationLatLng,
      "totalPrice": totalPrice,
      "weight": weight,
      "parcelType": parcelType,
      "vehicleType": vehicleType,
      "status": 'PENDING',
    });

    // Start listening for parcel driver responses
    listenToParcelRequest(id: requestId, context: context);
    parcelPercentageCounter(requestId: requestId, context: context);
  }

  completeTrip() {
    if (rideRequestModel == null) {
      print("No ride request to cancel.");
      return;
    } else {
      lookingForDriver = false;

      _requestServices
          .updateRequest({"id": rideRequestModel!.id, "status": "COMPLETED"});
      periodicTimer.cancel();
      rideRequestModel = null;
      driverModel = null;
      driverArrived = false;
      driverFound = false;
      driverCancelled = false;
      tripComplete = false;
      cancelRequestListener();
      notifyListeners();
    }
  }

  cancelRequest() {
    if (rideRequestModel == null) {
      print("No ride request to cancel.");
      return;
    } else {
      lookingForDriver = false;

      _requestServices
          .updateRequest({"id": rideRequestModel!.id, "status": "CANCELLED"});
      periodicTimer.cancel();
      rideRequestModel = null;
      driverModel = null;
      driverArrived = false;
      driverFound = false;

      notifyListeners();
    }
  }

  void parcelPercentageCounter(
      {required String requestId, required BuildContext context}) {
    lookingForDriver = true;
    notifyListeners();

    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter++;
      percentage = timeCounter / 100;
      print("====== Searching: $timeCounter");

      // Stop the timer when a driver is found
      if (driverFound) {
        print("Driver found, stopping search.");
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        time.cancel();
        notifyListeners();
        return; // Exit the function to prevent further execution
      }

      // If the search reaches 100 seconds, expire the request
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;

        // Update Firestore request status to expired

        _parcelServices.updateRequest({"id": requestId, "status": EXPIRED});
        time.cancel();
        if (alertsOnUi) {
          alertsOnUi = false;
          notifyListeners();
        }

        //cancelRequestListener();
      }

      notifyListeners();
    });
  }

//  Timer counter for driver request
  void percentageCounter(
      {required String requestId, required BuildContext context}) {
    lookingForDriver = true;
    notifyListeners();

    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter++;
      percentage = timeCounter / 100;
      print("====== Searching For Drivers: $timeCounter");

      // Stop the timer when a driver is found
      if (driverFound) {
        print("Driver found, stopping search.");
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        time.cancel();
        notifyListeners();
        return; // Exit the function to prevent further execution
      }

      // If the search reaches 100 seconds, expire the request
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;

        // Update Firestore request status to expired
        _requestServices.updateRequest({"id": requestId, "status": EXPIRED});

        time.cancel();
        if (alertsOnUi) {
          alertsOnUi = false;
          notifyListeners();
        }
        _subscription?.cancel();
        //cancelRequestListener();
      }

      notifyListeners();
    });
  }

  // Bike (Moto Express)
  // Base fare: 30 KSh
  // Per km: 17 KSh
  // Car
  // Base fare: 200 KSh
  // Per km: 35 KSh
  // Weight surcharge: Extra 0.2 KSh per kg if weight exceeds 5 kg

  double calculatePrice(double distance, double weight, String vehicleType) {
    double distanceKm = distance / 1000;
    print("distance $distanceKm" +
        "weight: $weight" +
        "vehicleType: $vehicleType");
    double baseFare;
    double perKmRate;
    double minFare;

    // Correct pricing based on vehicle type
    if (vehicleType == "Moto Express") {
      baseFare = 30; // Bike base fare
      perKmRate = 17; // Bike per km rate
      minFare = 30; // Minimum charge for bikes
    } else {
      baseFare = 200; // Car base fare
      perKmRate = 35; // Car per km rate
      minFare = 200; // Minimum charge for cars
    }

    // Weight surcharge (only applied if weight > 5kg)
    double weightSurcharge = (weight > 5) ? (weight - 5) * 0.2 : 0.0;

    // Calculate total price
    double totalPrice = baseFare + (distanceKm * perKmRate) + weightSurcharge;

    // Ensure minimum fare is met
    return totalPrice < minFare ? minFare : totalPrice;
  }

  Future handleOnLaunch(Map<String, dynamic> data) async {
    notificationType = data['data']['type'];
    if (notificationType == DRIVER_AT_LOCATION_NOTIFICATION) {
    } else if (notificationType == TRIP_STARTED_NOTIFICATION) {
    } else if (notificationType == REQUEST_ACCEPTED_NOTIFICATION) {}
    //driverModel = await _driverService.getDriverById(data['data']['driverId']);
    //_stopListeningToDriversStream();

    //_listenToDriver();
    notifyListeners();
  }

  Future handleOnResume(Map<String, dynamic> data) async {
    notificationType = data['data']['type'];

    //_stopListeningToDriversStream();
    if (notificationType == DRIVER_AT_LOCATION_NOTIFICATION) {
    } else if (notificationType == TRIP_STARTED_NOTIFICATION) {
    } else if (notificationType == REQUEST_ACCEPTED_NOTIFICATION) {}

    if (lookingForDriver) Navigator.pop(mainContext);
    lookingForDriver = false;
    //driverModel = await _driverService.getDriverById(data['data']['driverId']);
    periodicTimer.cancel();
    notifyListeners();
  }

  Future<void> saveTripState(
      String tripId, String status, double totalPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("tripId", tripId);
    await prefs.setString("status", status);
    await prefs.setDouble("totalPrice", totalPrice);
  }

  Future<void> saveParcelTripState(
      String tripId, String status, double totalPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("tripId", tripId);
    await prefs.setString("status", status);
    await prefs.setDouble("totalPrice", totalPrice);
  }
}
