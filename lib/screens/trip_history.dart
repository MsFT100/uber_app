import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/user_provider.dart';
import '../widgets/app_bar/app_bar.dart';
import '../utils/images.dart';
import 'trip_details.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  _TripHistoryScreenState createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final riderProvider = Provider.of<UserProvider>(context);
    final userId = riderProvider.user?.uid;

    return Scaffold(
      appBar: CustomAppBar(title: 'Trip History', showNavBack: true, centerTitle: true,),
      body: userId == null
          ? Center(child: Text('Please log in to see your trip history.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where('userId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No trip history found.'));
                }

                final trips = snapshot.data!.docs
                    .map((doc) => Trip.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          trip.type == TripType.ride
                              ? Images.car
                              : Images.parcelDeliveryman,
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          trip.type == TripType.ride
                              ? 'Ride to ${trip.destinationAddress}'
                              : 'Parcel to ${trip.recipientName}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Status: ${trip.status.name.toUpperCase()}'),
                            SizedBox(height: 4),
                            Text(
                              'On: ${trip.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailsScreen(trip: trip),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
