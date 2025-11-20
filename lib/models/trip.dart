import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String driverId;
  final String pickupLocation;
  final String destination;
  final double fare;
  final DateTime date;

  TripModel({
    required this.userId,
    required this.id,
    required this.driverId,
    required this.pickupLocation,
    required this.destination,
    required this.fare,
    required this.date,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      driverId: data['driverId'] ?? '',
      pickupLocation: data['pickupLocation'] ?? '',
      destination: data['destination'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(), userId: data['userId'] ?? '',
    );
  }
}
