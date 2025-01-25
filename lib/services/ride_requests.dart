import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestServices {
  final String collection = "requests";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void createRideRequest({
    required String id,
    required String userId,
    required String username,
    required Map<String, dynamic> destination,
    required Map<String, dynamic> position,
    required Map<String, dynamic> distance,
  }) {
    _firebaseFirestore.collection(collection).doc(id).set({
      "username": username,
      "id": id,
      "userId": userId,
      "driverId": "",
      "position": position,
      "status": 'pending',
      "destination": destination,
      "distance": distance,
    });
  }

  void updateRequest(Map<String, dynamic> values) {
    _firebaseFirestore.collection(collection).doc(values['id']).update(values);
  }

  Stream<QuerySnapshot> requestStream() {
    return _firebaseFirestore.collection(collection).snapshots();
  }
}
