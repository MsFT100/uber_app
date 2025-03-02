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
    required String photo,
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
        "photo": photo,
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
  Future<void> updateUserData(UserModel user) async {
    await _firebaseFirestore
        .collection(collection)
        .doc(user.id)
        .update(user.toJson());
    print("Values Updates===========================");
  }

  // Update user data
  Future<void> updateUserProfile(UserModel user, String pic) async {
    await _firebaseFirestore
        .collection(collection)
        .doc(user.id)
        .update(user.toJson());
    print("Values Updates===========================");
  }

  // Get a user by ID
  Future<UserModel> getUserById(String id) {
    return _firebaseFirestore.collection(collection).doc(id).get().then((doc) {
      print(doc);
      print("🚗 🚗🚗 🚗🚗 🚗🚗 🚗🚗 🚗");
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
