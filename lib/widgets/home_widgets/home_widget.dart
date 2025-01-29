import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/helpers/constants.dart';

import '../../providers/app_state.dart';
import '../../providers/user.dart';
import '../../screens/dashboard/helpers/curved_round_corner.dart';
import '../../screens/home.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../address_btn.dart';
import '../driver_map.dart';
import '../loading_location.dart';
import 'banner_view.dart';
import 'home_search_screen.dart';

class MenuWidgetScreen extends StatelessWidget {
  MenuWidgetScreen({Key? key, this.userLocation}) : super(key: key);

  late final LatLng? userLocation;
  late String? locationAddress = 'Location not available';
// Track the selected index (for example, Home, Activity, etc.)

  void initState() {
    checkPermisions();
    _getUserLocation();
  }

  String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'Good Morning';
    } else if (timeNow > 12 && timeNow <= 16) {
      return 'Good Afternoon';
    } else if (timeNow > 16 && timeNow < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void checkPermisions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    checkLocationPermission(permission);
  }

  void checkLocationPermission(LocationPermission permission) {
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);

    return locationAddress == null
        ? Center(child: LoadingLocationScreen())
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120), // Set AppBar height
              child: ClipPath(
                clipper: RoundedCornersAppBarClipper(),
                child: AppBar(
                  backgroundColor: AppConstants.lightPrimary,
                  automaticallyImplyLeading: false, // Remove the back arrow
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: Dimensions.paddingSize),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            MyHomePage(title: "title")));
                              },
                              child: Text(
                                locationAddress!,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: locationAddress == null
                ? Center(child: LoadingLocationScreen())
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: Dimensions.paddingSizeExtraLarge,
                        left: Dimensions.paddingSize,
                        right: Dimensions.paddingSize,
                      ),
                      child: Column(
                        children: [
                          BannerView(),
                          const SizedBox(height: 16.0),
                          HomeSearchWidget(),
                          const SizedBox(height: 16.0),
                          if (userLocation != null)
                            MapWidget(
                              initialPosition: userLocation!,
                              markers: appState.markers,
                            ),
                          const SizedBox(height: 16.0),
                          HomeMyAddress(
                            addressList: [locationAddress!],
                          ),
                        ],
                      ),
                    ),
                  ),
          );
  }

  // Method to handle bottom nav item taps
  void _onNavItemTapped(int index) {
    print("Selected Index: " + '${index}');

    selectedNavIndex = index;
  }

  Future<void> _getUserLocation() async {
    try {
      userLocation = user_global_location;
      locationAddress = location_global_address;
      print(location_global_address);
    } catch (e) {
      locationAddress = "Failed to get address";

      print("Error fetching user location: $e");
    }
  }
}
