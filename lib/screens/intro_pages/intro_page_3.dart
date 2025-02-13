import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';
import '../../utils/images.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: Stack(
        children: [
          // Background image

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage(Images.onBoardOne), // Add your image path here
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 90),
                Container(
                    alignment: Alignment(0, 0),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "Make Trips and Earn Money with Your Vehicle",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: AppConstants.fontFamily),
                      ),
                    )),
                SizedBox(height: 50),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
