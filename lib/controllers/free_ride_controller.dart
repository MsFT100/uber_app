import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user.dart';
import '../services/user.dart';

class FreeRideController {
  final UserServices _userServices = UserServices();

  Future<void> deductFreeRide({required BuildContext context, required UserModel userModel, required double rideCost}) async {
    if (userModel.freeRidesRemaining > 0 && userModel.freeRideAmountRemaining > 0) {
      double remaining = userModel.freeRideAmountRemaining - rideCost;

      // If remaining is less than 0, user must top-up manually
      double finalRemaining = remaining < 0 ? 0 : remaining;
      int newFreeRides = userModel.freeRidesRemaining - 1;

      await _userServices.updateUserFields(userModel.id, {
        "freeRidesRemaining": newFreeRides,
        "freeRideAmountRemaining": finalRemaining,
      });

      userModel
        ..freeRidesRemaining = newFreeRides
        ..freeRideAmountRemaining = finalRemaining;
      
       // Update UI state
      Provider.of<UserProvider>(context, listen: false).updateFreeRides(newFreeRides, finalRemaining);
    }
  }

  bool hasFreeRideAvailable(UserModel userModel) {
    return userModel.freeRidesRemaining > 0 && userModel.freeRideAmountRemaining > 0;
  }
}
