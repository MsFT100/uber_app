import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver.dart';

class DriverService {
  final String collection = 'drivers';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for getting all drivers as a list of DriverModel
  Stream<List<DriverModel>> getDrivers() {
    return _firestore.collection(collection).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => DriverModel.fromSnapshot(doc))
            .toList();
      },
    );
  }
  Stream<List<DriverPosition>> getDriverPositions() {
  return _firestore.collection(collection).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Extract position safely
      if (data[DriverModel.POSITION] != null) {
        return DriverPosition(
          lat: (data[DriverModel.POSITION][DriverModel.LATITUDE] ?? 0.0).toDouble(),
          lng: (data[DriverModel.POSITION][DriverModel.LONGITUDE] ?? 0.0).toDouble(),
          heading: (data[DriverModel.POSITION][DriverModel.HEADING] ?? 0.0).toDouble(),
        );
      }

      return DriverPosition(lat: 0.0, lng: 0.0, heading: 0.0); // Default if missing
    }).toList();
  });
}


  void _listenToDrivers() {
    FirebaseFirestore.instance
        .collection('drivers')
        .where('isOnline', isEqualTo: true) // Fetch only online drivers
        .snapshots()
        .listen((querySnapshot) {
      //_updateDriverMarkers(querySnapshot.docs);
    });
  }

  // Get a single driver by ID
  Future<DriverModel> getDriverById(String id) {
    return _firestore.collection(collection).doc(id).get().then(
      (doc) {
        return DriverModel.fromSnapshot(doc);
      },
    );
  }

  // Generic driver stream as QuerySnapshot
  Stream<QuerySnapshot> driverStream() {
    return _firestore.collection(collection).snapshots();
  }
}
