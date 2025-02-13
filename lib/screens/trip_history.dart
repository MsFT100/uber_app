import 'package:BucoRide/utils/dimensions.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../utils/images.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  String _selectedFilter = 'All Time'; // Default filter option
  final List<String> _filters = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All Time'
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<UserProvider>(context, listen: false).reloadUserModel();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final userId = userProvider.user?.uid; // Assuming user model has `id`

    return Scaffold(
        appBar: CustomAppBar(
            title: "Trip History", showNavBack: false, centerTitle: false),
        body: RefreshIndicator(
          child: Column(
            children: [
              SizedBox(
                height: Dimensions.paddingSize,
              ),
              // Filter Dropdown

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text
                  // Add left padding to "My Rides"
                  Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSize),
                    child: Text(
                      "My Trips",
                      style: TextStyle(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  //Dropdown
                  Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSize),
                    child: Container(
                      width: 150,
                      height: 30,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        border: Border.all(
                            color: Colors.grey, width: 1), // Optional border
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        items: _filters.map((filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                        isExpanded: true,
                        underline: SizedBox(), // Removes the default underline
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),

              // **StreamBuilder for Firestore Data**
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .where('userId',
                          isEqualTo: userId) // Fetch only user’s trips
                      .orderBy('createdAt',
                          descending: true) // Latest trips first
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SpinKitFoldingCube(
                        color: Colors.black,
                        size: 40,
                      )); // Show loading spinner
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No trips available"));
                    }

                    // Convert Firestore data to list
                    final trips = snapshot.data!.docs.map((doc) {
                      return doc.data() as Map<String, dynamic>;
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];

                        return Card(
                          elevation: 3, // Adds shadow for better UI
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded image
                              child: Image.asset(
                                Images.parcelDeliveryman,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain, // Ensures it fits well
                              ),
                            ),
                            title: Text(
                              "Trip to ${trip['destination']['address'] ?? 'Unknown'}", // Only show name
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status: ${trip['status'] ?? 'Unknown'}", // Show trip status
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (trip['status'] == "completed")
                                        ? Colors.green
                                        : (trip['status'] == "cancelled")
                                            ? Colors.red
                                            : Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 4), // Add spacing
                                Text(
                                  "Date: ${trip['createdAt'] != null ? trip['createdAt'].toDate().toString().split(" ")[0] : 'N/A'}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  "Fare: \ ksh ${trip['distance']['value'] ?? '0'}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          onRefresh: () async {
            await userProvider.refreshUser();
            // Optional: Add this in UserProvider
            setState(() {}); // Force UI to rebuild with new data
          },
        ));
  }
}
