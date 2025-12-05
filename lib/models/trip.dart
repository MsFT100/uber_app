import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TripType { ride, parcel }

enum TripStatus {
  requested,
  accepted,
  en_route_to_pickup,
  arrived_at_pickup,
  in_progress,
  completed,
  cancelled_by_driver,
  cancelled_by_rider,
  no_drivers_found,
  pending,
  arriving,
}

class Trip {
  final String? id;
  final String riderId;
  final String? driverId;
  final TripType type;
  late final TripStatus status;

  final LatLng pickup;
  final String pickupAddress;
  final LatLng destination;
  final String destinationAddress;

  final double? price;
  final DateTime? createdAt;

  // Parcel-specific fields
  final String? senderName;
  final String? senderContact;
  final String? recipientName;
  final String? recipientContact;
  final double? weight;
  final String? parcelType;
  final String vehicleType;

  Trip({
    this.id,
    required this.riderId,
    this.driverId,
    required this.type,
    this.status = TripStatus.pending,
    required this.pickup,
    required this.pickupAddress,
    required this.destination,
    required this.destinationAddress,
    required this.vehicleType,
    this.price,
    this.createdAt,
    // Parcel-specific
    this.senderName,
    this.senderContact,
    this.recipientName,
    this.recipientContact,
    this.weight,
    this.parcelType,

  });



  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- SAFER PARSING LOGIC ---

    // Helper to safely parse LatLng, checking for both direct lat/lng and GeoPoint
    LatLng _parseLatLng(Map<String, dynamic>? pointData) {
      if (pointData == null) return const LatLng(0, 0);

      if (pointData['lat'] is num && pointData['lng'] is num) {
        return LatLng((pointData['lat'] as num).toDouble(), (pointData['lng'] as num).toDouble());
      }
      if (pointData['geopoint'] is GeoPoint) {
        final geoPoint = pointData['geopoint'] as GeoPoint;
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }
      return const LatLng(0, 0); // Default fallback
    }

    return Trip(
      id: doc.id,
      // FIX: Use null-aware operators (??) to provide default values and prevent crashes
      riderId: data['riderId'] as String? ?? '',
      driverId: data['driverId'] as String?,
      type: TripType.values.byName(data['type'] as String? ?? 'ride'),
      status: TripStatus.values.byName(data['status'] as String? ?? 'pending'),

      // FIX: Use the safe parsing helper
      pickup: _parseLatLng(data['pickup'] as Map<String, dynamic>?),
      pickupAddress: data['pickupAddress'] as String? ?? 'Unknown Pickup',

      // FIX: Use the safe parsing helper
      destination: _parseLatLng(data['destination'] as Map<String, dynamic>?),
      destinationAddress: data['destinationAddress'] as String? ?? 'Unknown Destination',

      price: (data['estimated_fare'] as num?)?.toDouble() ?? (data['price'] as num?)?.toDouble(), // Check both possible keys
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),

      // Parcel fields (already nullable, which is good)
      senderName: data['senderName'] as String?,
      senderContact: data['senderContact'] as String?,
      recipientName: data['recipientName'] as String?,
      recipientContact: data['recipientContact'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      parcelType: data['parcelType'] as String?,

      // FIX: Provide a default value
      vehicleType: data['vehicleType'] as String? ?? 'sedan',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'riderId': riderId,
      'driverId': driverId,
      'type': type.name,
      'status': status.name,
      'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
      'pickupAddress': pickupAddress,
      'destination': {'lat': destination.latitude, 'lng': destination.longitude},
      'destinationAddress': destinationAddress,
      'price': price,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      // Parcel fields
      'senderName': senderName,
      'senderContact': senderContact,
      'recipientName': recipientName,
      'recipientContact': recipientContact,
      'weight': weight,
      'parcelType': parcelType,
      'vehicleType': vehicleType,
    };
  }
}
