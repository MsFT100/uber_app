import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../helpers/constants.dart';
import '../helpers/style.dart';
import '../models/driver.dart';
import '../models/ride_Request.dart';
import '../models/user.dart';
import '../services/ride_requests.dart';
import '../widgets/custom_btn.dart';
import '../widgets/custom_text.dart';
import '../widgets/stars.dart';

// * THIS ENUM WILL CONTAIN THE DRAGGABLE WIDGET TO BE DISPLAYED ON THE MAIN SCREEN

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';

  static const DRIVER_AT_LOCATION_NOTIFICATION = 'DRIVER_AT_LOCATION';
  static const REQUEST_ACCEPTED_NOTIFICATION = 'REQUEST_ACCEPTED';
  static const TRIP_STARTED_NOTIFICATION = 'TRIP_STARTED';

  final Set<Marker> _markers = {};
  //  this polys will be displayed on the map
  Set<Polyline> _poly = {};
  // this polys temporarily store the polys to destination

  late Position current_position;
  late bool noDriversFound = true;

  //   location pin
  BitmapDescriptor locationPin = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  //  Driver request related variables
  bool lookingForDriver = false;
  bool alertsOnUi = false;
  bool driverFound = false;
  bool driverArrived = false;
  RideRequestServices _requestServices = RideRequestServices();
  int timeCounter = 0;
  double percentage = 0;
  late Timer periodicTimer;

  String requestStatus = "";

  late RideRequestModel? rideRequestModel;
  late BuildContext mainContext;

//  this variable will listen to the status of the ride request
  late StreamSubscription<QuerySnapshot> requestStream;
  // this variable will keep track of the drivers position before and during the ride
  late StreamSubscription<QuerySnapshot> driverStream;
  late StreamSubscription<DocumentSnapshot>? _subscription;
  late DriverModel driverModel;

  double ridePrice = 0;
  String notificationType = "";

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  AppStateProvider() {
    _saveDeviceToken();

    // Foreground message handling
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   handleOnMessage(message as Map<String, dynamic>);
    // });

    // App launched by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleOnLaunch(message as Map<String, dynamic>);
    });

    // App is in the background, and notification taps open the app
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleOnResume(message as Map<String, dynamic>);
      }
    });

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

  showRequestCancelledSnackBar(BuildContext context) {}

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
                        visible: driverModel.photo == null,
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
                        visible: driverModel.photo != null,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(40)),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(driverModel.photo),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: driverModel.name),
                    ],
                  ),
                  SizedBox(height: 10),
                  _stars(rating: driverModel.rating, votes: driverModel.votes),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.directions_car),
                          label: Text(driverModel.car)),
                      CustomText(
                        text: driverModel.plate,
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

  // ANCHOR RIDE REQUEST METHODS
  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      String? deviceToken = await fcm.getToken();
      await prefs.setString('token', deviceToken!);
    }
  }

/*  listenToRequest({required String id, required BuildContext context}) async {
    requestStream = _requestServices.requestStream().listen((querySnapshot) {
      final documentChanges = querySnapshot.documentChanges;

      if (documentChanges != null) {
        documentChanges.forEach((doc) async {
          final data = doc.document.data;

          if (data != null && data['id'] == id) {
            rideRequestModel = RideRequestModel.fromSnapshot(doc.document);
            notifyListeners();

            switch (data['status']) {
              case CANCELLED:
                break;
              case ACCEPTED:
                if (lookingForDriver) Navigator.pop(context);
                lookingForDriver = false;
                driverModel =
                    await _driverService.getDriverById(data['driverId']);
                periodicTimer.cancel();
                clearPoly();
                _stopListeningToDriversStream();
                _listenToDriver();
                show = Show.DRIVER_FOUND;
                notifyListeners();
                break;
              case EXPIRED:
                showRequestExpiredAlert(context);
                break;
              default:
                break;
            }
          }
        });
      }
    });
  }*/
  void listenToRequest({required String id, required BuildContext context}) {
    _subscription = _requestServices.requestStream(id).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;

        if (data == null) return; // Prevent null errors

        final status = data['status'];

        if (context.mounted) {
          // Ensure context is still valid
          if (status == 'accepted') {
            final driverId = data['driverId'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Driver $driverId accepted your request! 🚗")),
            );
            canceRequestlListener();
            showDriverBottomSheet(context);
            // TODO: Navigate to ride tracking screen
          } else if (status == 'cancelled') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Your ride request was cancelled. ❌")),
            );
          }
        }
      }
    });
  }

  // Call this method when the listener is no longer needed
  void canceRequestlListener() {
    _subscription?.cancel();
  }

  void requestDriver({
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
      distance: distanceMap,
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
      "status": "pending",
    });

    // Start listening for driver responses
    listenToRequest(id: requestId, context: context);
    percentageCounter(requestId: requestId, context: context);
  }

  cancelRequest() {
    lookingForDriver = false;
    if (rideRequestModel == null) {
      print("No ride request to cancel.");
      return;
    }
    _requestServices
        .updateRequest({"id": rideRequestModel!.id, "status": "cancelled"});
    periodicTimer.cancel();
    notifyListeners();
  }

//  Timer counter for driver request
  void percentageCounter(
      {required String requestId, required BuildContext context}) {
    lookingForDriver = true;
    noDriversFound = false; // Reset flag
    notifyListeners();

    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter++;
      percentage = timeCounter / 100;
      print("====== Searching: $timeCounter");

      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        noDriversFound = true; // Set flag when search expires

        // Update Firestore request status to expired
        _requestServices.updateRequest({"id": requestId, "status": "expired"});

        time.cancel();
        if (alertsOnUi) {
          alertsOnUi = false;
          notifyListeners();
        }
        requestStream.cancel();
        canceRequestlListener();
      }
      notifyListeners();
    });
  }

  // ANCHOR PUSH NOTIFICATION METHODS
  // Future handleOnMessage(Map<String, dynamic> data) async {
  //   print("=== data = ${data.toString()}");
  //   notificationType = data['data']['type'];

  //   if (notificationType == DRIVER_AT_LOCATION_NOTIFICATION) {
  //   } else if (notificationType == TRIP_STARTED_NOTIFICATION) {
  //     show = Show.TRIP;
  //     sendRequest(
  //         origin: pickupCoordinates, destination: destinationCoordinates);
  //     notifyListeners();
  //   } else if (notificationType == REQUEST_ACCEPTED_NOTIFICATION) {}
  //   notifyListeners();
  // }

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
}

extension on QuerySnapshot<Object?> {
  get documentChanges => null;
}
