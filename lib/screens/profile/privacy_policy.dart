import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import '../menu.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: "Privacy policy", showNavBack: true, centerTitle: true),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the Buco Driver app.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                "1. Information We Collect",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "We may collect personal information such as your name, contact details, location data, and app usage statistics to improve our services.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 15),
              Text(
                "2. How We Use Your Information",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "Your information helps us provide, maintain, and improve our app, personalize user experiences, and ensure secure operations.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 15),
              Text(
                "3. Sharing of Information",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "We do not sell or rent your personal data. We may share information with third parties for legal reasons, service provision, or business transfers.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 15),
              Text(
                "4. Data Security",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "We implement security measures to protect your data from unauthorized access, alteration, disclosure, or destruction.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text(
                "5. Changes to This Policy",
                style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "We may update this Privacy Policy periodically. Continued use of the app after changes implies your acceptance of the revised policy.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: Dimensions.paddingSize),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.lightPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    changeScreen(context, Menu());
                  },
                  child: Text(
                    "Agree & Continue",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
