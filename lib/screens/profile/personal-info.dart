import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user.dart';
import 'edit_page.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    // Access UserProvider to get user data
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userModel;

    return Scaffold(
      appBar: CustomAppBar(
          title: "Profile Info", showNavBack: true, centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user information
            _buildInfoTile("Name", user?.name ?? "N/A", Icons.person),
            _buildInfoTile("Phone", user?.phone ?? "N/A", Icons.phone),
            _buildInfoTile("Email", user?.email ?? "N/A", Icons.email),
            _buildInfoTile(
                "Trips", user?.trips.toString() ?? "N/A", Icons.car_repair),

            const SizedBox(height: 20),

            // Edit Profile Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the Edit Profile Page
                  changeScreen(context, EditProfilePage());
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.lightPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create user info tiles
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ),
    );
  }
}
