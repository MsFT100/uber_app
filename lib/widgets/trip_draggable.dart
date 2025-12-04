import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/app_state.dart';
import '../providers/user_provider.dart';
import '../widgets/trip_widgets/payment_rating_dialog.dart';
import '../widgets/trip_widgets/trip_details_card.dart';

class TripDraggable extends StatefulWidget {
  const TripDraggable({Key? key}) : super(key: key);

  @override
  State<TripDraggable> createState() => _TripDraggableState();
}

class _TripDraggableState extends State<TripDraggable> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    if (appState.currentTrip?.status == TripStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPaymentAndRatingDialog();
        }
      });
    }
  }

  void _showPaymentAndRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PaymentRatingDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final trip = appState.currentTrip;

    if (trip == null || trip.status == TripStatus.completed || trip.status == TripStatus.cancelled_by_rider) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8, 
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Draggable handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TripDetailsCard(trip: trip, driver: appState.driver),
              
              const Divider(height: 32),

              _buildCancelTripButton(context, trip, appState),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelTripButton(BuildContext context, Trip trip, AppStateProvider appState) {
    // Only show cancel button for statuses where cancellation is logical
    if (trip.status == TripStatus.pending || trip.status == TripStatus.accepted || trip.status == TripStatus.arriving) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.cancel, color: Colors.white),
        label: const Text('Cancel Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to cancel this trip?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ?? false;

          if (confirm) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            final accessToken = userProvider.accessToken;
            if (accessToken != null) {
              try {
                await appState.cancelTrip(accessToken);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip cancelled successfully.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling trip: $e')));
              }
            }
          }
        },
      );
    }
    return const SizedBox.shrink(); // Return empty space if cancellation is not applicable
  }
}
