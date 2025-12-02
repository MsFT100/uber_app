import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user_provider.dart';
import '../../services/image_picker.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_widgets/loading.dart';
import 'login.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  File? _selectedImage;
  final ImagePickerService _imagePickerService = ImagePickerService();

  void _getImage() async {
    final pickedImage = await _imagePickerService.pickImageFromGallery(context);
    if (pickedImage != null) {
      setState(() => _selectedImage = pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(Images.logoWithName, height: 75),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to ${AppConstants.appName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 20.0,
                          ),
                        ),
                        Image.asset(Images.hand, width: 40),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Center(
                      child: Text(
                        'Register an account.',
                        style: const TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Center(
                      child: GestureDetector(
                        onTap: _getImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : const AssetImage(Images.personPlaceholder) as ImageProvider,
                          child: _selectedImage == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSize),
                    buildTextField(authProvider.name, "Full Name", Icons.person),
                    buildTextField(authProvider.email, "Email", Icons.email,
                        keyboardType: TextInputType.emailAddress),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: IntlPhoneField(
                        controller: authProvider.phone,
                        decoration: InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        initialCountryCode: 'KE',
                      ),
                    ),
                    buildTextField(authProvider.password, "Password", Icons.lock,
                        obscureText: true),
                    const SizedBox(height: Dimensions.paddingSize),
                    _buildRegisterButton(authProvider),
                    const SizedBox(height: 16.0),
                    _buildLoginLink(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(UserProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedImage == null) {
            showAppSnackBar(context, "Profile picture is required!", isError: true);
            return;
          }
          String resultMessage = await authProvider.signUp(profileImage: _selectedImage!);
          if (resultMessage == "Success") {
            authProvider.clearController();
            changeScreenReplacement(context, LoginScreen());
            showAppSnackBar(context, "Account Creation Successful. Please Login");
          } else {
            showAppSnackBar(context, resultMessage, isError: true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          "Register",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already an account '),
        TextButton(
          onPressed: () => changeScreen(context, LoginScreen()),
          child: Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
