import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/menu.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import '../../widgets/app_bar/app_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Terms & Conditions',
        showNavBack: true,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Welcome to Buco Driver!"),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              _buildParagraph(
                  "These Terms and Conditions govern your use of the Buco Driver app. By using our app, you agree to comply with these terms."),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildTermsSection("1. Acceptance of Terms",
                  "By accessing and using this app, you accept and agree to be bound by these Terms and Conditions."),
              _buildTermsSection("2. User Responsibilities",
                  "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account."),
              _buildTermsSection("3. Prohibited Activities",
                  "You agree not to engage in any unlawful activities, including but not limited to fraud, harassment, or misuse of the app."),
              _buildTermsSection("4. Limitation of Liability",
                  "Buco Driver is not liable for any damages resulting from the use of this app, including direct, indirect, or consequential losses."),
              _buildTermsSection("5. Changes to Terms",
                  "We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the revised terms."),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.lightPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () => changeScreen(context, Menu()),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.fontSizeSmall,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
