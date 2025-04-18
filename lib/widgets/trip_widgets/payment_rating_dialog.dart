import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../providers/location_provider.dart';
import '../custom_text.dart';

class PaymentRatingDialog extends StatefulWidget {
  @override
  _PaymentRatingDialogState createState() => _PaymentRatingDialogState();
}

class _PaymentRatingDialogState extends State<PaymentRatingDialog> {
  double rating = 3.0; // Default rating
  bool isPaymentProcessing = false;

  Future<void> _confirmPayment() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    setState(() {
      isPaymentProcessing = true;
      locationProvider.show = Show.DESTINATION_SELECTION;
      appState.completeTrip();
    });

    await Future.delayed(Duration(seconds: 2)); // Simulate payment processing

    String? driverId = appState.driverModel?.id; // Get driver ID

    if (driverId != null) {
      await saveDriverRating(driverId, rating);
    }

    appState.completeTrip(); // Mark trip as complete

    Navigator.pop(context); // Close dialog
  }

  Future<void> saveDriverRating(String driverId, double rating) async {
    try {
      DocumentReference driverRef =
          FirebaseFirestore.instance.collection('drivers').doc(driverId);

      await driverRef.update({
        'ratings': FieldValue.arrayUnion([rating]), // Append rating
      });

      print("Rating saved successfully!");
    } catch (e) {
      print("Error saving rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: "Rate Your Driver",
              size: 18,
              weight: FontWeight.bold,
            ),
            SizedBox(height: 10),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            SizedBox(height: 20),
            CustomText(
              text: "Amount to Pay: \$${appState.ridePrice.toStringAsFixed(2)}",
              size: 16,
              weight: FontWeight.bold,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPaymentProcessing ? null : _confirmPayment,
              child: isPaymentProcessing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Pay & Submit Rating"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
