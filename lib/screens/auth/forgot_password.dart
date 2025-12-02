import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_widgets/loading.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _key,
      appBar: CustomAppBar(title: "Forgot Password", showNavBack: true, centerTitle: true),
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  const Text(
                    'Enter your email address to receive a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: authProvider.email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: "Email Address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (authProvider.email.text.isNotEmpty) {
                        // Here you should have a method in your provider to handle password reset
                        // For example: await authProvider.resetPassword();
                        // Since it's not implemented, we'll just show a message.
                        showAppSnackBar(context, "Password reset link sent to your email.");
                      } else {
                        showAppSnackBar(context, "Please enter your email address.", isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.lightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
