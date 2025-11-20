import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/app_constants.dart';
import '../../utils/images.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: Stack(
        children: [
          // Background image with gradient overlay

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.onBoardOne),
                fit: BoxFit.contain,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(100), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.only(
              top: 50,
              right: 100,
              bottom: 600,
            ),
            child: SizedBox(
              height: 200, // Ensure it fits within available space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/phone_search_ride_animation.json',
                    height: 200,
                    fit: BoxFit.contain,
                    animate: true,
                    repeat: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
