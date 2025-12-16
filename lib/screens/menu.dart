import 'package:BucoRide/widgets/home_widgets/floating_nav_bar.dart';
import 'package:BucoRide/widgets/home_widgets/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/permmsions_service.dart';
import '../helpers/constants.dart';
import 'profile/profile_page.dart';

class Menu extends StatefulWidget {
  Menu({super.key});

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
