import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';

class DestinationConfirmationControls extends StatelessWidget {
  const DestinationConfirmationControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();

    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                // CANCEL BUTTON - Just an X icon
                _buildCancelButton(context, locationProvider),
                const SizedBox(width: 12),

                // CONFIRM BUTTON - Yellow with "Confirm" text
                _buildConfirmButton(context, locationProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, LocationProvider provider) {
    return Expanded(
      flex: 1,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _playHapticFeedback();
            provider.cancelRideRequest();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.shade100, width: 1.5),
            ),
            child: Icon(
              Icons.close_rounded,
              color: Colors.red.shade700,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, LocationProvider provider) {
    return Expanded(
      flex: 2,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _playHapticFeedback();
            provider.getRouteAndEstimate();
            provider.show = Show.VEHICLE_SELECTION;
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.amber.shade600, // Yellow color
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade600.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playHapticFeedback() {
    HapticFeedback.lightImpact();
  }
}