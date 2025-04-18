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
              _buildSectionTitle("Welcome to Bucoride!"),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              _buildParagraph("Effective Date: April 5, 2025"),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildParagraph(
                  "These Terms and Conditions (\"Agreement\") govern your use of the Bucoride client app (\"App\"), provided by Gamerich. By using the App, you agree to be bound by these Terms and Conditions. If you do not agree with any part of this Agreement, you should not use the App."),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildTermsSection(
                "1. Use of Bucoride App",
                "1.1 Bucoride allows you to request rides and deliveries within the Bureti area.\n"
                    "1.2 You must be at least 18 years old to use the App. By using the App, you confirm that you meet this age requirement.\n"
                    "1.3 You agree to use the App solely for lawful purposes and in a manner that does not infringe on the rights of others or restrict their ability to use the App.",
              ),
              _buildTermsSection(
                "2. Account Registration",
                "2.1 To access certain features of the App, you are required to create an account. You agree to provide accurate, current, and complete information during the registration process.\n"
                    "2.2 You are responsible for maintaining the confidentiality of your account credentials and are fully responsible for all activities under your account.",
              ),
              _buildTermsSection(
                "3. Service Fees",
                "3.1 The fares displayed in the App are estimates. Clients and drivers (or delivery agents) should harmonize and negotiate the final prices for rides and parcel orders before the start of the ride or delivery.\n"
                    "3.2 Gamerich reserves the right to adjust service fees from time to time. Any changes will be communicated via the App or other reasonable means.",
              ),
              _buildTermsSection(
                "4. Ride and Delivery Requests",
                "4.1 When you request a ride or delivery, you agree to provide accurate location information. We are not liable for delays or issues arising from incorrect information provided by you.\n"
                    "4.2 Availability of rides and deliveries depends on the service providers (drivers, delivery agents) in your area. We do not guarantee the availability of a provider at any specific time.",
              ),
              _buildTermsSection(
                "5. User Conduct",
                "5.1 You agree not to engage in any activity that could harm, disrupt, or interfere with the functionality of the App, including but not limited to transmitting harmful code or attempting unauthorized access to other users' accounts.\n"
                    "5.2 You are prohibited from using the App to harass, threaten, or discriminate against other users.",
              ),
              _buildTermsSection(
                "6. Payment and Billing",
                "6.1 Payments for rides and deliveries are processed through the App’s payment system. You authorize Gamerich to charge the payment method you provide for any services used.\n"
                    "6.2 All payments are non-refundable unless otherwise stated in the App’s refund policy.",
              ),
              _buildTermsSection(
                "7. Privacy Policy",
                "7.1 By using the App, you agree to our Privacy Policy, which outlines how we collect, use, and protect your personal information.",
              ),
              _buildTermsSection(
                "8. Disclaimers and Limitation of Liability",
                "8.1 Gamerich does not guarantee the availability, accuracy, or reliability of services provided through the App.\n"
                    "8.2 Gamerich is not responsible for any damages arising from the use of the App, including but not limited to direct, indirect, incidental, special, or consequential damages.",
              ),
              _buildTermsSection(
                "9. Termination",
                "9.1 Gamerich reserves the right to suspend or terminate your account if you violate these Terms and Conditions or engage in inappropriate conduct.\n"
                    "9.2 You may terminate your account at any time by following the account closure process in the App.",
              ),
              _buildTermsSection(
                "10. Changes to Terms",
                "10.1 Gamerich reserves the right to modify these Terms and Conditions at any time. We will notify you of any significant changes, and your continued use of the App after the changes are made will constitute your acceptance of the updated Terms.",
              ),
              _buildTermsSection(
                "11. Governing Law",
                "11.1 These Terms and Conditions are governed by and construed in accordance with the laws of Kenya.",
              ),
              _buildTermsSection(
                "12. Contact Information",
                "If you have any questions or concerns about these Terms and Conditions, please contact us at:\n\n"
                    "Email: gamerichladder@gmail.com\n"
                    "Phone: +254 703 330 627",
              ),
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
                      fontSize: Dimensions.fontSizeSmall,
                    ),
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
