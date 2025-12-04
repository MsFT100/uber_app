import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
        body: Center(
        child: SpinKitFoldingCube(
          color: Colors.black,
          size: 30,
        ),
        ),
    );
  }
}
