import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';

class PaymentRatingDialog extends StatefulWidget {
  const PaymentRatingDialog({Key? key}) : super(key: key);

  @override
  State<PaymentRatingDialog> createState() => _PaymentRatingDialogState();
}

class _PaymentRatingDialogState extends State<PaymentRatingDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final trip = appState.currentTrip;

    if (trip == null) {
      return const SizedBox.shrink(); // Should not happen if dialog is shown correctly
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(child: Text('Trip Completed')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please rate your driver to proceed to payment.'),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : TextButton(
                child: const Text('Submit Rating & Pay'),
                onPressed: () async {
                  setState(() => _isSubmitting = true);
                  try {
                    // You would get the accessToken from your UserProvider
                    const accessToken = 'YOUR_ACCESS_TOKEN'; // Placeholder
                    await appState.rateTrip(trip.id!, _rating.toInt(), _commentController.text, accessToken);
                    
                    Navigator.of(context).pop(); // Close the dialog

                    // Now you can trigger the payment flow
                    // For example, navigate to a payment screen or show another dialog.
                    // e.g., showMpesaPaymentDialog(context);

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error submitting rating: $e')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                },
              ),
      ],
    );
  }
}
