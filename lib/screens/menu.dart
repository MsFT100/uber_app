import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/widgets/home_widgets/home_widget.dart';
import 'package:user_app/widgets/profile_page.dart';

import '../helpers/constants.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import '../widgets/floating_nav_bar.dart';

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
    const ProfileScreen(), // Profile Screen
  ];

  // Method to handle bottom nav item taps
  _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      selectedNavIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            AppConstants.lightPrimary, // Customize the AppBar color
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Dimensions.paddingSize),
              child: Column(
                children: [
                  Text(
                    '${greetingMessage()}, ${userProvider.user?.email}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (index) {
        print("Bottom nav selected: $index");
        _onNavItemTapped(index);
      }),
    );
  }
}
