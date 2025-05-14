import 'package:BucoRide/models/user.dart';
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
          ],
        ),
      ),
    );
  }
}
