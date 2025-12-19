import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/utils/dimensions.dart';
import 'package:BucoRide/utils/images.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  // UPDATED: The constructor to accept selectedIndex
  CustomBottomNavBar({
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      backgroundColor: Colors.transparent,
      color: AppConstants.lightPrimary,
      animationDuration: Duration(milliseconds: 300),
      items: [
        CurvedNavigationBarItem(
          child: Image.asset(
            Images.homeActive,
            width: Dimensions.iconSizeMedium,
            height: Dimensions.iconSizeMedium,
          ),
          label: 'Home',
        ),
        CurvedNavigationBarItem(
          child: Image.asset(
            Images.calenderIcon,
            width: Dimensions.iconSizeMedium,
            height: Dimensions.iconSizeMedium,
          ),
          label: 'Rides',
        ),
        CurvedNavigationBarItem(
          child: Icon(
            Icons.person_2_rounded,
            color: Colors.white,
          ),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        onItemSelected(index);
      },
    );
  }
}
