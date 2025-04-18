import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/widgets/trip_widgets/Searching_for_drivers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/style.dart';
import '../providers/user.dart';
import '../widgets/trip_draggable.dart';
import '../widgets/trip_widgets/destination_selection.dart';
import '../widgets/trip_widgets/driver_found.dart';
import '../widgets/trip_widgets/payment_method_selection.dart';
import '../widgets/trip_widgets/pickup_selection_widget.dart';
import 'map.dart';

class HomePage extends StatefulWidget {
  HomePage({
    super.key,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _homeScaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _deviceToken();
    _restoreSystemUI();
  }

  _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    if (_user.userModel?.token != preferences.getString('token')) {
      Provider.of<UserProvider>(context, listen: false).saveDeviceToken();
    }
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);

    return Scaffold(
      key: _homeScaffoldKey,
      body: Stack(
        children: [
          MapScreen(),
          Visibility(
            visible: locationProvider.show == Show.TRIP,
            child: Positioned(
                top: 60,
                left: MediaQuery.of(context).size.width / 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(border_radius),
                            topRight: Radius.circular(border_radius),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          color: primary,
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text:
                                        "You\'ll reach your destination in \n",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w300)),
                                TextSpan(
                                    text: locationProvider
                                            .routeModel?.timeNeeded.text ??
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
              visible: locationProvider.show == Show.DESTINATION_SELECTION,
              child: DestinationSelectionWidget()),
          // ANCHOR PICK UP WIDGET
          Visibility(
            visible: locationProvider.show == Show.PICKUP_SELECTION,
            child: PickupSelectionWidget(
              scaffoldState: _homeScaffoldKey,
            ),
          ),
          //  ANCHOR Draggable PAYMENT METHOD
          Visibility(
              visible: locationProvider.show == Show.PAYMENT_METHOD_SELECTION,
              child: PaymentMethodSelectionWidget(
                scaffoldState: _homeScaffoldKey,
              )),
          //  ANCHOR Draggable DRIVER
          Visibility(
              visible: locationProvider.show == Show.DRIVER_FOUND,
              child: DriverFoundWidget()),
          //  ANCHOR Draggable DRIVER
          Visibility(
              visible: locationProvider.show == Show.TRIP, child: TripWidget()),
          Visibility(
              visible: locationProvider.show == Show.SEARCHING_DRIVER,
              child: SearchingForDrivers()),
        ],
      ),
    );
  }
}
