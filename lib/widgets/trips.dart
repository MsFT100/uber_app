import 'package:flutter/material.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: ListView.builder(
        itemCount: 10, // You can replace this with dynamic data
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Trip #$index'),
            subtitle: Text('Trip details will go here.'),
            onTap: () {
              // Add any navigation or actions you'd like to perform
            },
          );
        },
      ),
    );
  }
}
