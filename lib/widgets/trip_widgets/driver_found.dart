import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';

class DriverFoundWidget extends StatelessWidget {
  final AppStateProvider provider;

  const DriverFoundWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final driver = provider.driver;
    final trip = provider.currentTrip;
    final locationProvider = context.watch<LocationProvider>();

    if (driver == null || trip == null) {
      // Show a loading state while driver data is being populated
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            trip.status == TripStatus.en_route_to_pickup
                ? "Driver is on the way"
                : "Driver Found!",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (locationProvider.driverEta != null) ...[
            const SizedBox(height: 8),
            Text(
              "Arriving in ${locationProvider.driverEta}",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              // Driver profile picture
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: driver.profilePhotoUrl != null
                    ? NetworkImage(driver.profilePhotoUrl!)
                    : null,
                child: driver.profilePhotoUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              // Driver name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star,
                            color: Colors.amber.shade600, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          (driver.rating ?? 0.0).toStringAsFixed(2),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call button
              IconButton(
                icon: const Icon(Icons.call, size: 28),
                color: theme.primaryColor,
                style: IconButton.styleFrom(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () async {
                  if (driver.phone != null) {
                    final Uri launchUri =
                        Uri(scheme: 'tel', path: driver.phone!);
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Vehicle details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "VEHICLE",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${driver.vehicle?.color ?? ''} ${driver.vehicle?.model ?? ''}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "LICENSE PLATE",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.vehicle?.numberPlate ?? 'N/A',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
