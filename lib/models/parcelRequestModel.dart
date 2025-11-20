import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelRequestModel {
  static const String ID = "id";
  static const String USERID = "userId";
  static const String SENDER_NAME = "senderName";
  static const String SENDER_CONTACT = "senderContact";
  static const String RECIPIENT_NAME = "recipientName";
  static const String RECIPIENT_CONTACT = "recipientContact";
  static const String POSITION_ADDRESS = "address";
  static const String DESTINATION = "destination";
  static const String DESTINATION_LAT_LNG = "destinationLatLng";
  static const double TOTAL_PRICE = 0.0;
  static const double WEIGHT = 0.0;
  static const String PARCEL_TYPE = "parcelType";
  static const String VEHICLE_TYPE = "vehicleType";
  static const String STATUS = "status";
  static const String TIMESTAMP = "timestamp";

  // Fields
  final String id;
  final String userId;
  final String senderName;
  final String senderContact;
  final String recipientName;
  final String recipientContact;
  final String destination;
  final Map<String, dynamic>? destinationLatLng;
  final String positionAddress;
  final double totalPrice;
  final double weight;
  final String parcelType;
  final String vehicleType;
  final String status;
  final Timestamp? timestamp;

  // Constructor from Firestore snapshot
  ParcelRequestModel.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot[ID] ?? '',
        userId = snapshot[USERID] ?? '',
        senderName = snapshot[SENDER_NAME] ?? '',
        senderContact = snapshot[SENDER_CONTACT] ?? '',
        recipientName = snapshot[RECIPIENT_NAME] ?? '',
        recipientContact = snapshot[RECIPIENT_CONTACT] ?? '',
        positionAddress = snapshot[POSITION_ADDRESS] ?? '',
        destination = snapshot[DESTINATION] ?? '',
        destinationLatLng = snapshot[DESTINATION_LAT_LNG] != null
            ? Map<String, dynamic>.from(snapshot[DESTINATION_LAT_LNG])
            : null,
        totalPrice = (snapshot["totalPrice"] as num?)?.toDouble() ?? 0.0,
        weight = snapshot[WEIGHT] ?? '',
        parcelType = snapshot[PARCEL_TYPE] ?? '',
        vehicleType = snapshot[VEHICLE_TYPE] ?? '',
        status = snapshot[STATUS] ?? '',
        timestamp = snapshot[TIMESTAMP];

  // ✅ Custom constructor to create from a Map
  ParcelRequestModel.fromMap(Map<String, dynamic> data)
      : id = data[ID] ?? '',
        userId = data[USERID] ?? '',
        senderName = data[SENDER_NAME] ?? '',
        senderContact = data[SENDER_CONTACT] ?? '',
        recipientName = data[RECIPIENT_NAME] ?? '',
        recipientContact = data[RECIPIENT_CONTACT] ?? '',
        positionAddress = data[POSITION_ADDRESS] ?? '',
        destination = data[DESTINATION] ?? '',
        destinationLatLng = data[DESTINATION_LAT_LNG] != null
            ? Map<String, dynamic>.from(data[DESTINATION_LAT_LNG])
            : null,
        totalPrice = data[TOTAL_PRICE] ?? 0.0,
        weight = data[WEIGHT] ?? 0.0,
        parcelType = data[PARCEL_TYPE] ?? '',
        vehicleType = data[VEHICLE_TYPE] ?? '',
        status = data[STATUS] ?? '',
        timestamp =
            data.containsKey(TIMESTAMP) ? data[TIMESTAMP] as Timestamp? : null;

}
