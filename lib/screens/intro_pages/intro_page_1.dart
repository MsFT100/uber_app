import 'package:flutter/material.dart';

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
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage(Images.onBoardOne), // Add your image path here
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Add some spacing
                SizedBox(height: 90),
                Container(
                  alignment: Alignment(0, -0.95),
                  child: Text(
                    "Ride Requests",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: AppConstants.fontFamily),
                  ),
                ),
                // Customized Text

                SizedBox(height: 50),

                // Add an animation
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
