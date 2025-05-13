import 'package:BucoRide/models/user.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user.dart';
import '../services/user.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userModel;

    if (user == null) {
      return ListView(children: [
        Center(child: Text("No user loaded.")),
      ]);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your ride balance',
        showNavBack: false,
        centerTitle: false,
      ),
      body: WalletScreenBody(user, userProvider),
      floatingActionButton: DeductRideBalanceFAB(user, userProvider),
    );
  }

  Widget WalletScreenBody(UserModel user, UserProvider userProvider) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final refreshedUser = await UserServices().getUserById(user.id);
        userProvider.setUser(refreshedUser);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Free rides remaining',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Text(
                user.freeRidesRemaining.toString(),
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 20.0),
            ListTile(
              title: Text(
                'Free rides balance',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Text(
                'Kshs. ${user.freeRideAmountRemaining.toStringAsFixed(2)}/=',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  FloatingActionButton DeductRideBalanceFAB(
      UserModel user, UserProvider userProvider) {
    return FloatingActionButton(
      backgroundColor: AppConstants.lightPrimary,
      foregroundColor: Colors.white,
      tooltip: 'Deduct ride by Ksh.100/=',
      onPressed: () async {
        const double rideCost = 100;

        int newRides =
            user.freeRidesRemaining > 0 ? user.freeRidesRemaining - 1 : 0;
        double newAmount = user.freeRideAmountRemaining - rideCost;

        if (newAmount < 0) newAmount = 0;

        // Simulate backend update (you can also call a real method)
        await UserServices().updateUserData(user
          ..freeRidesRemaining = newRides
          ..freeRideAmountRemaining = newAmount);

        // Update in provider
        userProvider.updateFreeRides(newRides, newAmount);
      },
      child: Icon(Icons.credit_card_rounded),
    );
  }

  FloatingActionButton RefreshFAB(UserModel user, UserProvider userProvider) {
    return FloatingActionButton(
      backgroundColor: AppConstants.lightPrimary,
      foregroundColor: Colors.white,
      tooltip: 'Refresh balance',
      onPressed: () async {
        final refreshedUser = await UserServices().getUserById(user.id);
        userProvider.setUser(refreshedUser);
      },
      child: Icon(Icons.refresh_rounded),
    );
  }
}
