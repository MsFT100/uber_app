import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/utils/images.dart';
import 'package:BucoRide/widgets/address_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../screens/home.dart';
import '../../screens/parcel_page.dart';
import '../../utils/dimensions.dart';
import '../driver_map.dart';
import '../loading_location.dart';
import 'banner_view.dart';
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
    });
  }

  Future<void> _refreshHome() async {
    await Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final position = locationProvider.currentPosition;
    final address = locationProvider.locationAddress;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(userProvider, address),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(Dimensions.paddingSize),
                child: SizedBox(
                  // ADD THIS
                  width: double.infinity, // Ensures full width
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevents infinite height
                    children: [
                      BannerView(),
                      const SizedBox(height: Dimensions.paddingSize),
                      _buildButtons(locationProvider),
                      const SizedBox(height: Dimensions.paddingSize),
                      HomeSearchWidget(),
                      const SizedBox(height: Dimensions.paddingSize),
                      position != null ? MapWidget() : LoadingLocationScreen(),
                      const SizedBox(height: Dimensions.paddingSize),
                      HomeMyAddress(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProvider userProvider, String? address) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppConstants.lightPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
          const SizedBox(height: 10),
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
            changeScreen(context, MyHomePage(title: "title"));
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
