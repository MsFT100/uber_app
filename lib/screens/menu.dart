import 'package:BucoRide/screens/trip_history.dart';
import 'package:BucoRide/widgets/home_widgets/floating_nav_bar.dart';
import 'package:BucoRide/widgets/home_widgets/home_widget.dart';
import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import 'profile_page.dart';

class Menu extends StatefulWidget {
  Menu({super.key, required this.title});
  final String title;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

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
