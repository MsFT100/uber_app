import 'package:flutter/material.dart';
import 'package:user_app/utils/app_constants.dart'; // Use your actual constants or utility classes

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor:
            AppConstants.lightPrimary, // Replace with your app's primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture, name, and email (just as an example)
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage('https://www.example.com/profile_image.jpg'),
            ),
            const SizedBox(height: 16.0),
            Text(
              'User Name',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              'user@example.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),

            // List of profile options, settings, etc.
            ListTile(
              title: const Text('Account Settings'),
              onTap: () {
                // Navigate to account settings screen if you have one
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                // Handle log out logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
