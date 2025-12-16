import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/chat/chat_screen.dart';
import 'driver_found.dart';

class SearchingForDrivers extends StatefulWidget {
  const SearchingForDrivers({super.key});

  @override
  State<SearchingForDrivers> createState() => _SearchingForDriversState();
}

class _SearchingForDriversState extends State<SearchingForDrivers>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _noDriversFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for pulsing/breathing effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Controller for continuous rotation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_rotateController);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _noDriversFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(const AlwaysStoppedAnimation(1.0)); // Will be rebuilt
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 1,
      snap: true,
      snapSizes: const [0.3, 0.45, 1],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Consumer<AppStateProvider>(
            builder: (context, provider, child) {
              final status = provider.currentTrip?.status;

              return Column(
                children: [
                  // Draggable handle
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main content - FIXED: Use Expanded properly
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _buildContentByStatus(
                            status, primaryColor, provider),
                      ),
                    ),
                  ),

                  // Action button section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // Status chip
                        if (status != TripStatus.no_drivers_found &&
                            status != TripStatus.accepted &&
                            status != TripStatus.en_route_to_pickup)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withAlpha(51),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withAlpha(128),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Searching nearby drivers",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Cancel/Close button
                        _buildActionButton(context, provider, status),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContentByStatus(
      TripStatus? status, Color primaryColor, AppStateProvider provider) {
    switch (status) {
      case TripStatus.no_drivers_found:
        return FadeTransition(
          key: const ValueKey('no-drivers'),
          opacity: _noDriversFadeAnimation =
              Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeIn),
          ),
          child: _buildNoDriversFoundUI(primaryColor),
        );
      case TripStatus.accepted:
      case TripStatus.en_route_to_pickup:
        return DriverFoundWidget(
            key: const ValueKey('driver-found'), provider: provider);
      case TripStatus.requested:
      default:
        return _buildSearchingUI(
          key: const ValueKey('searching'),
          primaryColor: primaryColor,
        );
    }
  }

  Widget _buildSearchingUI({required Key key, required Color primaryColor}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated radar/search icon
        Stack(
          alignment: Alignment.center,
          children: [
            // New "Scanner" sweep effect
            AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.0),
                          primaryColor.withValues(alpha: 0.4),
                        ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Middle ring
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 80 * _pulseAnimation.value,
                  height: 80 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withAlpha(102),
                      width: 2,
                    ),
                  ),
                );
              },
            ),

            // Inner icon with pulse
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 15 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoDriversFoundUI(Color primaryColor) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with shadow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha(26),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 50,
            ),
          ),
          const SizedBox(height: 30),

          // Title
          Text(
            "No Drivers Available",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "We couldn't find any available drivers in your area at the moment. This could be due to high demand or connectivity issues.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Suggestions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Suggestions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSuggestionItem(
                  icon: Icons.refresh_rounded,
                  text: "Try searching again in a few minutes",
                ),
                const SizedBox(height: 8),
                _buildSuggestionItem(
                  icon: Icons.location_on_rounded,
                  text: "Move to a more populated area",
                ),
                const SizedBox(height: 8),
                _buildSuggestionItem(
                  icon: Icons.timer_rounded,
                  text: "Try during off-peak hours",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, AppStateProvider appState, TripStatus? status) {
    final userProvider = context.read<UserProvider>();
    final locationProvider = context.read<LocationProvider>();

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Primary action button
          ElevatedButton(
            onPressed: () async {
              // Prevent action if no driver is assigned yet
              if (status == TripStatus.accepted && appState.driver == null) {
                return;
              }

              final accessToken = userProvider.accessToken;
              if (accessToken != null) {
                if (status == TripStatus.no_drivers_found) {
                  // Close and reset
                  locationProvider.cancelRideRequest();
                } else if (status == TripStatus.requested) {
                  // Show confirmation dialog before cancelling
                  final bool? confirmCancel =
                      await _showCancelConfirmationDialog(context);
                  if (confirmCancel == true) {
                    appState.cancelTrip(accessToken);
                    locationProvider.cancelRideRequest();
                  }
                } else if (appState.currentTrip?.id != null &&
                    (status == TripStatus.accepted ||
                        status == TripStatus.en_route_to_pickup)) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(tripId: appState.currentTrip!.id!),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == TripStatus.no_drivers_found
                  ? Colors.grey.shade300 // Close button
                  : (status == TripStatus.accepted ||
                          status == TripStatus.en_route_to_pickup)
                      ? Theme.of(context).primaryColor // Message button
                      : Colors.red.shade500, // Cancel button
              foregroundColor: status == TripStatus.no_drivers_found
                  ? Colors.grey.shade800
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 2,
              shadowColor: Colors.black.withAlpha(26),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == TripStatus.no_drivers_found
                      ? Icons.close_rounded
                      : (status == TripStatus.accepted ||
                              status == TripStatus.en_route_to_pickup)
                          ? Icons.message_rounded
                          : Icons.cancel_rounded,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  status == TripStatus.no_drivers_found
                      ? "Close"
                      : (status == TripStatus.accepted ||
                              status == TripStatus.en_route_to_pickup)
                          ? "Message Driver"
                          : "Cancel Search",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Retry button (only for no drivers found state)
          if (status == TripStatus.no_drivers_found) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                debugPrint("Retrying trip request...");
                locationProvider.getRouteAndEstimate();
                locationProvider.show = Show.VEHICLE_SELECTION;
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 22),
                  SizedBox(width: 12),
                  Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool?> _showCancelConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Search?'),
          content: const Text(
              'Are you sure you want to stop searching for a driver?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Searching'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // User does not want to cancel
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms cancellation
              },
            ),
          ],
        );
      },
    );
  }
}
