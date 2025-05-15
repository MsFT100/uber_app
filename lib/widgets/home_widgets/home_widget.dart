import 'package:BucoRide/controllers/free_ride_controller.dart';
import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/providers/app_state.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../screens/dashboard/Address/address_btn.dart';
import '../../screens/home.dart';
import '../../screens/parcels/parcel_page.dart';
import '../../utils/dimensions.dart';
import '../driver_map.dart';
import '../loading_widgets/loading_location.dart';
import 'banner_view.dart';
import 'free_ride_offer_banner.dart';
import 'home_search_screen.dart';

class MenuWidgetScreen extends StatefulWidget {
  const MenuWidgetScreen({Key? key}) : super(key: key);

  @override
  _MenuWidgetScreenState createState() => _MenuWidgetScreenState();
}

class _MenuWidgetScreenState extends State<MenuWidgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocation();
      Provider.of<LocationProvider>(context, listen: false).listenToDrivers();
      Provider.of<AppStateProvider>(context, listen: false).saveDeviceToken();
    });
  }

  Future<void> _refreshHome() async {
    await Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    final position = locationProvider.currentPosition;
    final address = locationProvider.locationAddress;
    final FreeRideController _freeRideController = FreeRideController();

    if (position == null) {
      locationProvider.fetchLocation();
      return LoadingLocationScreen();
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: Column(
          children: [
            _buildHeader(userProvider, address),
            SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Dimensions.paddingSize),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  BannerView(),
                  const SizedBox(height: Dimensions.paddingSize),

                  // banner that shows a user has free rides
                  // show banner only if the user has free rides
                  if (_freeRideController.hasFreeRideAvailable(userProvider.userModel!))
                    FreeRideOfferBanner(userProvider: userProvider),
                  const SizedBox(height: Dimensions.paddingSize),
                  _buildButtons(locationProvider),
                  const SizedBox(height: Dimensions.paddingSize),
                  HomeSearchWidget(),
                  const SizedBox(height: Dimensions.paddingSize),
                  MapWidget(),
                  const SizedBox(height: Dimensions.paddingSize),
                  HomeMyAddress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserProvider userProvider, String? address) {
    return Container(
      height: 116.0,
      decoration: BoxDecoration(
        color: AppConstants.lightPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${greetingMessage()}, ${userProvider.userModel?.name ?? "Guest"}',
            style: TextStyle(
                fontSize: Dimensions.fontSizeLarge,
                color: Colors.black45,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address ?? "Fetching location...",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildMenuButton("Go Moto", Images.bike, () {
            locationProvider.show = Show.DESTINATION_SELECTION;
            changeScreen(context, HomePage());
          }),
          SizedBox(
            width: Dimensions.paddingSize,
          ),
          _buildMenuButton("Car", Images.car, () {
            locationProvider.show = Show.DESTINATION_SELECTION;
            changeScreen(context, HomePage());
          }),
          SizedBox(
            width: Dimensions.paddingSize,
          ),
          _buildMenuButton("Delivery", Images.parcelDeliveryman, () {
            changeScreen(context, ParcelPage());
          }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
          ],
          border: Border.all(
              color: AppConstants.lightPrimary,
              width: 1,
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 50, height: 30),
            const SizedBox(height: 5),
            Text(title,
                style: TextStyle(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

String greetingMessage() {
  var timeNow = DateTime.now().hour;
  if (timeNow < 12) {
    return 'Good Morning';
  } else if (timeNow < 17) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}
