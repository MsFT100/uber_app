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
  arriving
}

class Trip {
  final String? id;
  final String userId;
  final String? driverId;
  final TripType type;
  final TripStatus status;

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
  final String? vehicleType;

  Trip({
    this.id,
    required this.userId,
    this.driverId,
    required this.type,
    this.status = TripStatus.pending,
    required this.pickup,
    required this.pickupAddress,
    required this.destination,
    required this.destinationAddress,
    this.price,
    this.createdAt,
    // Parcel-specific
    this.senderName,
    this.senderContact,
    this.recipientName,
    this.recipientContact,
    this.weight,
    this.parcelType,
    this.vehicleType,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      userId: data['userId'],
      driverId: data['driverId'],
      type: TripType.values.byName(data['type'] ?? 'ride'),
      status: TripStatus.values.byName(data['status'] ?? 'pending'),
      pickup: LatLng(data['pickup']['lat'], data['pickup']['lng']),
      pickupAddress: data['pickupAddress'],
      destination: LatLng(data['destination']['lat'], data['destination']['lng']),
      destinationAddress: data['destinationAddress'],
      price: (data['price'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      // Parcel fields
      senderName: data['senderName'],
      senderContact: data['senderContact'],
      recipientName: data['recipientName'],
      recipientContact: data['recipientContact'],
      weight: (data['weight'] as num?)?.toDouble(),
      parcelType: data['parcelType'],
      vehicleType: data['vehicleType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
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
