import 'package:flutter/material.dart';

import '../../models/driver.dart';
import '../../models/trip.dart';

class TripDetailsCard extends StatelessWidget {
  final Trip trip;
  final Driver? driver;

  const TripDetailsCard({Key? key, required this.trip, this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Status: ${trip.status.name.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(height: 24),
            if (driver != null) _buildDriverInfo(),
            const SizedBox(height: 12),
            _buildTripInfo(),
            if (trip.type == TripType.parcel) ...[
              const Divider(height: 24),
              _buildParcelInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: driver!.profilePhotoUrl != null ? NetworkImage(driver!.profilePhotoUrl!) : null,
          child: driver!.profilePhotoUrl == null ? const Icon(Icons.person, size: 30) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (driver!.rating != null) Text('Rating: ${driver!.rating?.toStringAsFixed(1)} ⭐'),
              if (driver!.vehicle?.model != null) Text('${driver!.vehicle?.model} - ${driver!.vehicle?.numberPlate}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pickup:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(trip.pickupAddress, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        const Text('Destination:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(trip.destinationAddress, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildParcelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parcel Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildDetailRow('Recipient:', trip.recipientName),
        _buildDetailRow('Recipient Contact:', trip.recipientContact),
        _buildDetailRow('Weight:', '${trip.weight?.toString() ?? 'N/A'} kg'),
        _buildDetailRow('Parcel Type:', trip.parcelType),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
