import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../widgets/app_bar/app_bar.dart';
import '../widgets/trip_widgets/trip_details_card.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Trip Details', showNavBack: true, centerTitle: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: TripDetailsCard(trip: trip), // Using the refactored details card
      ),
    );
  }
}
