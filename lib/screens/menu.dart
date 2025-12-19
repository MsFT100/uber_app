import 'package:BucoRide/screens/trip_history.dart';
import 'package:BucoRide/widgets/home_widgets/custom_bottom_navbar.dart';
import 'package:BucoRide/widgets/home_widgets/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/permmsions_service.dart';
import 'profile/profile_page.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  final PermissionsService _permissionsService = PermissionsService();

  @override
  void initState() {
    super.initState();
    _restoreSystemUI();
    // Request notification permissions after the user has logged in.
    _permissionsService.requestNotificationPermission();
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  // List of pages/screens for navigation
  final List<Widget> _pages = [
    MenuWidgetScreen(),
    TripHistoryScreen(),
    ProfileScreen(), // Profile Screen
  ];

  // Method to handle bottom nav item taps
  _onNavItemTapped(int index) {
    // Check if the index is valid before setting the state
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
        // selectedNavIndex = index; // <-- REMOVED: Do not update the global variable
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _pages[_selectedIndex],
      ),
      // Pass the local _selectedIndex to the CustomBottomNavBar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex, // <-- ADDED THIS
        onItemSelected: (index) {
          print("Bottom nav selected: $index");
          _onNavItemTapped(index);
        },
      ),
    );
  }
}
