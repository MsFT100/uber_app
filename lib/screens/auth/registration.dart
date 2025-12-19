import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user_provider.dart';
import '../../services/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'
    as ph; // Import permission_handler with an alias
import '../../services/permmsions_service.dart'; // Import the PermissionsService
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
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the Form
  File? _selectedImage;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final PermissionsService _permissionsService =
      PermissionsService(); // Instantiate PermissionsService

  Future<void> _getImage() async {
    // Show a dialog or bottom sheet to let the user choose source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return; // User cancelled the selection

    PermissionStatus permissionStatus;
    File? pickedImage;

    if (source == ImageSource.gallery) {
      permissionStatus =
          await _permissionsService.requestMediaImagesPermission();
      if (permissionStatus == PermissionStatus.granted) {
        pickedImage = await _imagePickerService.pickImageFromGallery(context);
      } else {
        _handlePermissionDenied(context, "photos", permissionStatus);
      }
    } else if (source == ImageSource.camera) {
      permissionStatus = await _permissionsService.requestCameraPermission();
      if (permissionStatus == PermissionStatus.granted) {
        pickedImage = await _imagePickerService.pickImageFromCamera(context);
      } else {
        _handlePermissionDenied(context, "camera", permissionStatus);
      }
    }

    if (pickedImage != null) {
      setState(() => _selectedImage = pickedImage);
    }
  }

  void _handlePermissionDenied(
      BuildContext context, String type, PermissionStatus status) {
    if (status == PermissionStatus.denied) {
      showAppSnackBar(context,
          "Permission denied to access $type. Please grant permission to select a profile picture.",
          isError: true);
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Use ScaffoldMessenger directly to show a SnackBar with an action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Permission permanently denied for $type. Please go to app settings to enable access."),
          backgroundColor: Colors.red,
          duration:
              const Duration(seconds: 5), // Give user time to see the action
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: Colors.white,
            onPressed: () {
              ph.openAppSettings(); // Open app settings
            },
          ),
        ),
      );
    } else {
      showAppSnackBar(context, "Unknown permission status for $type.",
          isError: true);
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
                child: Form(
                  // Wrap fields in a Form widget
                  key: _formKey,
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
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.0),
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
                                : const AssetImage(Images.personPlaceholder)
                                    as ImageProvider,
                            child: _selectedImage == null
                                ? const Icon(Icons.camera_alt,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSize),
                      buildTextField(
                          authProvider.name, "Full Name", Icons.person,
                          validator: _validateName),
                      buildTextField(authProvider.email, "Email", Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: IntlPhoneField(
                          validator: (phone) => _validatePhone(phone?.number),
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
                      buildTextField(
                          authProvider.password, "Password", Icons.lock,
                          obscureText: true, validator: _validatePassword),
                      const SizedBox(height: Dimensions.paddingSize),
                      _buildRegisterButton(authProvider),
                      const SizedBox(height: 16.0),
                      _buildLoginLink(context),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // --- Validation Methods ---

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required.';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters long.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    // Regular expression for a valid email format
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    // You can add more specific phone number validation if needed
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    // You could add more complex rules here (e.g., require numbers, symbols, etc.)
    return null;
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
          // First, validate the form
          if (!_formKey.currentState!.validate()) {
            showAppSnackBar(context, "Please correct the errors in the form.",
                isError: true);
            return;
          }
          if (_selectedImage == null) {
            showAppSnackBar(context, "Profile picture is required!",
                isError: true);
            return;
          }

          // If validation passes, proceed with sign up
          String resultMessage =
              await authProvider.signUp(profileImage: _selectedImage!);
          if (resultMessage == "Success") {
            authProvider.clearController();
            changeScreenReplacement(context, LoginScreen());
            showAppSnackBar(
                context, "Account Creation Successful. Please Login");
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
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
