import 'package:flutter/material.dart';

class ParcelDriver extends StatefulWidget {
  const ParcelDriver({super.key});

  @override
  State<ParcelDriver> createState() => _ParcelDriverState();
}

class _ParcelDriverState extends State<ParcelDriver> {
  Future<void> _refreshData() async {
    // Simulate data fetching
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Update your data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parcel Driver")),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: const [
            ListTile(title: Text("Parcel 1")),
            ListTile(title: Text("Parcel 2")),
            ListTile(title: Text("Parcel 3")),
          ],
        ),
      ),
    );
  }
}
