import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;

  CustomBottomNavBar({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BottomAppBar(
          elevation: 3.0,
          color: AppConstants.lightPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => onItemSelected(0), // Home
              ),
              IconButton(
                icon: const Icon(Icons.local_activity),
                onPressed: () => onItemSelected(0), // Activity
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () => onItemSelected(0), // Favorites
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => onItemSelected(1), // Profile
              ),
            ],
          ),
        ),
      ),
    );
  }
}
