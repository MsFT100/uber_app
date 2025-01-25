import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/providers/app_state.dart';
import 'package:user_app/providers/user.dart';
import 'package:user_app/screens/login.dart';
import 'package:user_app/widgets/custom_text.dart';
import 'package:user_app/widgets/destination_selection.dart';
import 'package:user_app/widgets/driver_found.dart';
import 'package:user_app/widgets/loading.dart';
import 'package:user_app/widgets/payment_method_selection.dart';
import 'package:user_app/widgets/pickup_selection_widget.dart';
import 'package:user_app/widgets/trip_draggable.dart';

import 'helpers/screen_navigation.dart';
import 'helpers/style.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _deviceToken();
  }

  Future<void> _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userModel?.token != preferences.getString('token')) {
      userProvider.saveDeviceToken();
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
                  text: userProvider.userModel?.name ?? "Name not found",
                  size: 18,
                  weight: FontWeight.bold,
                ),
                accountEmail: CustomText(
                  text: userProvider.userModel?.email ?? "Email not found",
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const CustomText(text: "Log out"),
                onTap: () {
                  userProvider.signOut();
                  changeScreenReplacement(context, LoginScreen());
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            MapScreen(scaffoldState),
            if (appState.show == Show.DRIVER_FOUND)
              Positioned(
                top: 60,
                left: 15,
                child: Container(
                  color: appState.driverArrived ? Colors.green : primary,
                  padding: const EdgeInsets.all(16),
                  child: CustomText(
                    text: "Meet driver at the pick-up location",
                    color: Colors.white,
                  ),
                ),
              ),
            if (appState.show == Show.TRIP)
              Positioned(
                top: 60,
                left: MediaQuery.of(context).size.width / 7,
                child: Container(
                  color: primary,
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "You'll reach your destination in \n",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: appState.routeModel?.timeNeeded?.text ?? "",
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (appState.show == Show.DESTINATION_SELECTION)
              const DestinationSelectionWidget(),
            if (appState.show == Show.PICKUP_SELECTION)
              PickupSelectionWidget(scaffoldState: scaffoldState),
            if (appState.show == Show.PAYMENT_METHOD_SELECTION)
              PaymentMethodSelectionWidget(scaffoldState: scaffoldState),
            if (appState.show == Show.DRIVER_FOUND) DriverFoundWidget(),
            if (appState.show == Show.TRIP) TripWidget(),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const MapScreen(this.scaffoldState, {Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapsPlaces googlePlaces;
  final TextEditingController destinationController = TextEditingController();
  final Color darkBlue = Colors.black;
  final Color grey = Colors.grey;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return appState.center == null
        ? Loading()
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: appState.center!,
                  zoom: 15,
                ),
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
                  icon: Icon(Icons.menu, color: primary, size: 30),
                  onPressed: () {
                    widget.scaffoldState.currentState?.openDrawer();
                  },
                ),
              ),
            ],
          );
  }
}
