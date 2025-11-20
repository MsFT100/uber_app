import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user.dart';
import '../services/user.dart';

class FreeRideController {
  final UserServices _userServices = UserServices();

  Future<void> deductFreeRide({required BuildContext context, required UserModel userModel}) async {
    if (userModel.freeRidesRemaining > 0) {
      // deduct 1 free ride
      int newFreeRides = userModel.freeRidesRemaining - 1;

      await _userServices.updateUserFields(userModel.id, {
        "freeRidesRemaining": newFreeRides,
      });

      userModel..freeRidesRemaining = newFreeRides;
      
      // Update UI state
      Provider.of<UserProvider>(context, listen: false).updateFreeRides(newFreeRides);
    }
  }

  bool hasFreeRideAvailable(UserModel userModel) {
    return userModel.freeRidesRemaining > 0;
  }
}
