import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/trip_widgets/trip_details_card.dart';
import '../map.dart';

class TrackTripScreen extends StatelessWidget {
  const TrackTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final trip = appState.currentTrip;

    return Scaffold(
      appBar: CustomAppBar(title: 'Track Your Trip', showNavBack: true, centerTitle: true),
      body: Stack(
        children: [
          const MapScreen(), // Your map widget
          if (trip != null)
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0, -3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // This custom widget will display the core trip info
                      TripDetailsCard(trip: trip, driver: appState.driver),
                    ],
                  ),
                );
              },
            ),
          if (trip == null)
            Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No Active Trip',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'You do not currently have an active trip. If you believe this is an error, please restart the app.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
