import 'package:flutter/material.dart';

import '../../providers/user.dart';

class FreeRideOfferBanner extends StatelessWidget {
  const FreeRideOfferBanner({
    super.key,
    required this.userProvider,
  });

  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue.shade400,
        shape: BoxShape.rectangle,
      ),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: const Color.fromARGB(255, 73, 73, 73), size: 32.0),
        title: Text("Ride offer for fare less than Kshs. 600/="),
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
        subtitle: Text(
            'Free Ride(s): ${userProvider.userModel?.freeRidesRemaining}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 13.0,
            ),
          ),
      ),
    );
  }
}
