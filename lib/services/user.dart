import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/user.dart';

class UserServices {
  final String collection = "users";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    int votes = 0,
    int trips = 0,
    double rating = 0,
    required Map position,
  }) async {
    try {
      await _firebaseFirestore.collection(collection).doc(id).set({
        "name": name,
        "id": id,
        "phone": phone,
        "email": email,
        "votes": votes,
        "trips": trips,
        "rating": rating,
        "position": position,
      });
    } catch (e) {
      // Handle any errors that occur during the Firestore operation
      debugPrint("Error creating user: $e");
      rethrow;
    }
  }

  // Update user data
  void updateUserData(Map<String, dynamic> values) {
    _firebaseFirestore.collection(collection).doc(values['id']).update(values);
  }

  // Get a user by ID
  Future<UserModel> getUserById(String id) {
    return _firebaseFirestore.collection(collection).doc(id).get().then((doc) {
      return UserModel.fromSnapshot(doc);
    });
  }

  // Add a device token to the user
  void addDeviceToken({required String token, required String userId}) {
    _firebaseFirestore
        .collection(collection)
        .doc(userId)
        .update({"token": token});
  }
}
