import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/providers/user_provider.dart';
import 'package:BucoRide/screens/auth/login.dart';
import 'package:BucoRide/screens/profile/personal-info.dart';
import 'package:BucoRide/screens/profile/privacy_policy.dart';
import 'package:BucoRide/screens/profile/terms_and_conditions.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import 'edit_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    var profileImage = userProvider.user?.photoURL ?? Images.person;
    var displayName = userProvider.rider?.name ?? "John Doe";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(profileImage, displayName),
            const SizedBox(height: 20),
            _buildAccountSettings(userProvider),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(String? profileImage) {
    if (profileImage != null && profileImage.startsWith('http')) {
      return NetworkImage(profileImage);
    } else {
      return const AssetImage(Images.person);
    }
  }

  Widget _buildHeader(String profileImage, String displayName) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppConstants.lightPrimary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                changeScreen(context, EditProfilePage());
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: _getProfileImage(profileImage),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSettings(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            _buildSettingItem(Icons.person, "Personal Info", () {
              changeScreen(context, PersonalInfo());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.book, "Terms and Conditions", () {
              changeScreenReplacement(context, TermsScreen());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.privacy_tip, "Privacy Policy", () {
              changeScreenReplacement(context, PrivacyPolicyScreen());
            }),
            _buildDivider(),
            _buildSettingItem(Icons.logout, "Log Out", () {
              userProvider.signOut();
              changeScreenReplacement(context, LoginScreen());
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(indent: 20, endIndent: 20, height: 1);
  }
}
