import 'package:BucoRide/screens/trip_history.dart';
import 'package:BucoRide/widgets/home_widgets/floating_nav_bar.dart';
import 'package:BucoRide/widgets/home_widgets/home_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import 'profile_page.dart';

class Menu extends StatefulWidget {
  Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _restoreSystemUI();
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      appState.saveDeviceToken();
      _deviceToken();
    }).onError((err) {
      // Error getting token.
    });
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    if (_user.userModel?.token != preferences.getString('token')) {
      Provider.of<UserProvider>(context, listen: false).saveDeviceToken();
    }
  }

  // List of pages/screens for navigation
  final List<Widget> _pages = [
    MenuWidgetScreen(),
    TripHistory(),
    ProfileScreen(), // Profile Screen
  ];

  // Method to handle bottom nav item taps
  _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (index) {
        print("Bottom nav selected: $index");
        _onNavItemTapped(index);
      }),
    );
  }
}
