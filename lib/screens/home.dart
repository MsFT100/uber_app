import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/screen_navigation.dart';
import '../helpers/style.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import '../widgets/custom_text.dart';
import '../widgets/destination_selection.dart';
import '../widgets/driver_found.dart';
import '../widgets/loading.dart';
import '../widgets/payment_method_selection.dart';
import '../widgets/pickup_selection_widget.dart';
import '../widgets/trip_draggable.dart';
import 'login.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _deviceToken();
  }

  _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    if (_user.userModel?.token != preferences.getString('token')) {
      Provider.of<UserProvider>(context, listen: false).saveDeviceToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        drawer: Drawer(
            child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: CustomText(
                  text: userProvider.userModel?.name ?? "This is null",
                  size: 18,
                  weight: FontWeight.bold,
                ),
                accountEmail: CustomText(
                  text: userProvider.userModel?.email ?? "This is null",
                )),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: CustomText(text: "Log out"),
              onTap: () {
                userProvider.signOut();
                changeScreenReplacement(context, LoginScreen());
              },
            )
          ],
        )),
        body: Stack(
          children: [
            MapScreen(scaffoldState),
            Visibility(
              visible: appState.show == Show.DRIVER_FOUND,
              child: Positioned(
                  top: 60,
                  left: 15,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: appState.driverArrived
                              ? Container(
                                  color: green,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: CustomText(
                                      text:
                                          "Meet driver at the pick up location",
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: primary,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: CustomText(
                                      text:
                                          "Meet driver at the pick up location",
                                      weight: FontWeight.w300,
                                      color: white,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )),
            ),
            Visibility(
              visible: appState.show == Show.TRIP,
              child: Positioned(
                  top: 60,
                  left: MediaQuery.of(context).size.width / 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Container(
                            color: primary,
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                          "You\'ll reach your desiation in \n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300)),
                                  TextSpan(
                                      text: appState
                                              .routeModel?.timeNeeded?.text ??
                                          "",
                                      style: TextStyle(fontSize: 22)),
                                ]))),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            // ANCHOR Draggable
            Visibility(
                visible: appState.show == Show.DESTINATION_SELECTION,
                child: DestinationSelectionWidget()),
            // ANCHOR PICK UP WIDGET
            Visibility(
              visible: appState.show == Show.PICKUP_SELECTION,
              child: PickupSelectionWidget(
                scaffoldState: scaffoldState,
              ),
            ),
            //  ANCHOR Draggable PAYMENT METHOD
            Visibility(
                visible: appState.show == Show.PAYMENT_METHOD_SELECTION,
                child: PaymentMethodSelectionWidget(
                  scaffoldState: scaffoldState,
                )),
            //  ANCHOR Draggable DRIVER
            Visibility(
                visible: appState.show == Show.DRIVER_FOUND,
                child: DriverFoundWidget()),

            //  ANCHOR Draggable DRIVER
            Visibility(
                visible: appState.show == Show.TRIP, child: TripWidget()),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  MapScreen(this.scaffoldState);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapsPlaces googlePlaces;
  TextEditingController destinationController = TextEditingController();
  Color darkBlue = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    scaffoldSate = widget.scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return appState.center == null
        ? Loading()
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: appState.center, zoom: 15),
                onMapCreated: appState.onCreate,
                myLocationEnabled: true,
                mapType: MapType.normal,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.poly,
              ),
              Positioned(
                top: 10,
                left: 15,
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: primary,
                      size: 30,
                    ),
                    onPressed: () {
                      scaffoldSate.currentState?.openDrawer();
                    }),
              ),
            ],
          );
  }

  Future<void> displayPrediction(Prediction? p) async {
    if (p != null) {
      try {
        // Fetch place details using the place ID
        String placeId = p.placeId ?? '';
        PlacesDetailsResponse detail = (await places
            .getDetailsByPlaceId(placeId)) as PlacesDetailsResponse;

        // Extract latitude and longitude
        double? lat = detail.result.geometry?.location.lat;
        double? lng = detail.result.geometry?.location.lng;

        if (lat != null && lng != null) {
          // Use geocoding to fetch address from latitude and longitude
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

          if (placemarks.isNotEmpty) {
            Placemark placemark = placemarks.first;

            print("Latitude: $lat, Longitude: $lng");
            print(
                "Address: ${placemark.street ?? 'No street info'}, ${placemark.locality ?? 'No locality info'}, ${placemark.country ?? 'No country info'}");
          } else {
            print("No address found for coordinates.");
          }
        } else {
          print("Could not fetch geometry details.");
        }
      } catch (e) {
        print("Error fetching place details: $e");
      }
    } else {
      print("No prediction selected.");
    }
  }
}
