import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelRequestServices {
  final String collection = "parcels";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Create Parcel Request in Firestore
  void createParcelRequest({
    required String id,
    required String userId,
    required String senderName,
    required String senderContact,
    required String recipientName,
    required String recipientContact,
    required String positionAddress,
    required String destination,
    required Map<String, dynamic> position,
    required Map<String, dynamic>? destinationLatLng,
    required double weight,
    required double totalPrice,
    required String parcelType,
    required String vehicleType,
  }) {
    _firebaseFirestore.collection(collection).doc(id).set({
      "id": id,
      "userId": userId,
      "senderName": senderName,
      "senderContact": senderContact,
      "recipientName": recipientName,
      "recipientContact": recipientContact,
      "positionAddress": positionAddress,
      "destination": destination,
      "destinationLatLng": destinationLatLng,
      "weight": weight,
      "totalPrice": totalPrice,
      "parcelType": parcelType,
      "vehicleType": vehicleType,
      "status": 'PENDING',
      "timestamp": FieldValue.serverTimestamp(),
    });
    print("=======================Successfully Created Parcel Request");
  }

  // Update Parcel Request (e.g., when status changes)
  void updateRequest(Map<String, dynamic> values) {
    _firebaseFirestore.collection(collection).doc(values['id']).update(values);
  }

  // Listen for changes in the request (real-time updates)
  Stream<DocumentSnapshot> requestStream(String requestId) {
    return _firebaseFirestore.collection(collection).doc(requestId).snapshots();
  }
}
