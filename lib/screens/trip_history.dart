import 'package:BucoRide/utils/dimensions.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../helpers/screen_navigation.dart';
import '../models/parcelRequestModel.dart';
import '../models/ride_Request.dart';
import '../utils/images.dart';
import 'TripDetails.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  bool showParcels = false; // Toggle between Trips & Parcels
  late RideRequestModel? rideRequestModel;
  late ParcelRequestModel? parcelRequestModel;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).reloadUserModel();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final userId = userProvider.user?.uid;

    print(userId);
    return Scaffold(
      appBar: CustomAppBar(
          title: "Trip History", showNavBack: false, centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.refreshUser();
          setState(() {}); // Force UI update
        },
        child: Column(
          children: [
            SizedBox(height: Dimensions.paddingSize),

            // **Toggle Button for Trips & Parcels**
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => showParcels = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        showParcels ? Colors.grey[300] : Colors.blueAccent,
                  ),
                  child: Text("My Trips",
                      style: TextStyle(
                          color: showParcels ? Colors.black : Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => showParcels = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        showParcels ? Colors.blueAccent : Colors.grey[300],
                  ),
                  child: Text("My Parcels",
                      style: TextStyle(
                          color: showParcels ? Colors.white : Colors.black)),
                ),
              ],
            ),

            SizedBox(height: Dimensions.paddingSize),

            // **Show Trips or Parcels**
            Expanded(
              child: showParcels
                  ? _buildParcelList(userId)
                  : _buildTripList(userId),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 **Trip List**
  Widget _buildTripList(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          // .where('parcelType',
          //     isNull: true) // Ensure only ride requests are fetched
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(snapshot, "Trip to");
      },
    );
  }

  // 🔹 **Parcel List**
  Widget _buildParcelList(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parcels')
          .where('userId', isEqualTo: userId)
          .where('parcelType', isGreaterThan: '') // Fetch only parcels
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(snapshot, "Parcel to");
      },
    );
  }

  Widget _buildList(AsyncSnapshot<QuerySnapshot> snapshot, String titlePrefix) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: SpinKitFoldingCube(color: Colors.black, size: 40));
    }
    if (snapshot.hasError) {
      return Center(child: Text("Error: ${snapshot.error}"));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text("No history available"));
    }

    final requests = snapshot.data!.docs;

    return ListView.builder(
      padding: EdgeInsets.all(15),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final data = requests[index].data() as Map<String, dynamic>;

        // 🔹 Check if the request is a Parcel or Ride
        bool isParcel = data.containsKey('parcelType');

        if (isParcel) {
          parcelRequestModel = ParcelRequestModel.fromMap(data);
        } else {
          rideRequestModel = RideRequestModel.fromMap(data);
        }
        return GestureDetector(
          onTap: () {
            if (isParcel) return;
            changeScreen(context, TripDetails(trip: data));
          },
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  isParcel ? Images.parcelDeliveryman : Images.car,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                "$titlePrefix ${isParcel ? parcelRequestModel?.destination : rideRequestModel?.destination['address']}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status: ${isParcel ? parcelRequestModel?.status : rideRequestModel?.status}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (isParcel
                                  ? parcelRequestModel?.status
                                  : rideRequestModel?.status) ==
                              "COMPLETED"
                          ? Colors.green
                          : (isParcel
                                      ? parcelRequestModel?.status
                                      : rideRequestModel?.status) ==
                                  "CANCELLED"
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Date: ${isParcel ? parcelRequestModel?.timestamp?.toDate().toString().split(" ")[0] ?? "N/A" : rideRequestModel?.createdAt?.toDate().toString().split(" ")[0]}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    "Fare: ksh ${isParcel ? parcelRequestModel?.totalPrice : rideRequestModel?.distance['value']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
