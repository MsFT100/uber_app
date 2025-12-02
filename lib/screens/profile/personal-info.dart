import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_bar/app_bar.dart';

class PersonalInfo extends StatelessWidget {
  const PersonalInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final rider = userProvider.rider;

    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      appBar: CustomAppBar(title: "Personal Information", showNavBack: true, centerTitle: true),
      body: rider == null
          ? const Center(child: Text("No user data available."))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInfoTile(Icons.person, "Full Name", rider.name),
                _buildInfoTile(Icons.email, "Email", rider.email),
                _buildInfoTile(Icons.phone, "Phone", rider.phone),
              ],
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
