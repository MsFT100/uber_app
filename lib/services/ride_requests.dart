import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestServices {
  final String collection = "requests";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Create Ride Request in Firestore
  void createRideRequest({
    required String id,
    required String userId,
    required String username,
    required String vehicleType,
    required Map<String, dynamic> destination,
    required Map<String, dynamic> position,
    required Map<String, dynamic> distance,
    bool isFreeRide = false,
  }) {
    _firebaseFirestore.collection(collection).doc(id).set({
      "id": id,
      "userId": userId,
      "username": username,
      "driverId": "",
      "position": position,
      "status": 'PENDING', // Request status: pending, accepted, cancelled
      "destination": destination,
      "distance": distance,
      "type": vehicleType,
      "isFree": isFreeRide,
      "createdAt": FieldValue.serverTimestamp(),
    });
    print("=======================Successfully Created Ride Request");
  }

  // Update Ride Request (e.g., when driver accepts)
  Future<void> updateRequest(Map<String, dynamic> values) async {
    _firebaseFirestore.collection(collection).doc(values['id']).update(values);
  }

  // Listen for changes in the request (real-time updates)
  Stream<DocumentSnapshot> requestStream(String requestId) {
    return _firebaseFirestore.collection(collection).doc(requestId).snapshots();
  }
}
