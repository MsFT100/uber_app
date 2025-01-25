import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver.dart';

class DriverService {
  final String collection = 'drivers';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Stream for getting all drivers as a list of DriverModel
  Stream<List<DriverModel>> getDrivers() {
    return _firebaseFirestore.collection(collection).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => DriverModel.fromSnapshot(doc))
            .toList();
      },
    );
  }

  // Get a single driver by ID
  Future<DriverModel> getDriverById(String id) {
    return _firebaseFirestore.collection(collection).doc(id).get().then(
      (doc) {
        return DriverModel.fromSnapshot(doc);
      },
    );
  }

  // Generic driver stream as QuerySnapshot
  Stream<QuerySnapshot> driverStream() {
    return _firebaseFirestore.collection(collection).snapshots();
  }
}
