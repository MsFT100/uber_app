import 'package:BucoRide/screens/rating/rating_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver.dart';
import '../models/trip.dart';
import '../providers/app_state.dart';
import '../providers/user_provider.dart';


class PaymentScreen extends StatefulWidget {
  final Trip trip;
  final Driver driver;

  const PaymentScreen({
    super.key,
    required this.trip,
    required this.driver,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _feedbackMessage;
  bool _paymentInitiated = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number from user profile if available
    final userProvider = context.read<UserProvider>();
    if (userProvider.rider?.phone != null) {
      _phoneController.text = userProvider.rider!.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _feedbackMessage = "Please enter a valid phone number.");
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final appState = context.read<AppStateProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      final response = await appState.initiatePayment(
        tripId: int.parse(widget.trip.id!),
        phone: _phoneController.text.trim(),
        accessToken: userProvider.accessToken!,
      );

      setState(() {
        _feedbackMessage = response['message'] as String?;
        _paymentInitiated = true;
      });

      // After a delay, navigate to rating screen
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => RatingScreen(
                tripId: widget.trip.id!,
                driver: widget.driver,
              ),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _feedbackMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCashPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pay with Cash'),
          content: Text(
              'Please pay KES ${widget.trip.price?.toStringAsFixed(2) ?? '0.00'} directly to your driver.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmed
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              RatingScreen(tripId: widget.trip.id!, driver: widget.driver),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Payment'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.payment_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Final Fare',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'KES ${widget.trip.price?.toStringAsFixed(2) ?? '0.00'}',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (!_paymentInitiated) ...[
              Text(
                'Enter your M-Pesa phone number to pay.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.security_rounded),
                  label: const Text('Pay with M-Pesa',
                      style: TextStyle(fontSize: 18)),
                  onPressed: _isLoading ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.money_rounded),
                  label: const Text('Pay with Cash',
                      style: TextStyle(fontSize: 18)),
                  onPressed: _isLoading ? null : _handleCashPayment,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_feedbackMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    color: _paymentInitiated ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_paymentInitiated) ...[
              const SizedBox(height: 20),
              const Text(
                "You will be redirected to the rating screen shortly...",
                textAlign: TextAlign.center,
              )
            ]
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            // Allow user to skip to rating if they have issues
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => RatingScreen(
                  tripId: widget.trip.id!,
                  driver: widget.driver,
                ),
              ),
            );
          },
          child: const Text("Pay later / Skip"),
        ),
      ),
    );
  }
}
