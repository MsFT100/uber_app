
import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/screens/auth/forgot_password.dart';
import 'package:BucoRide/screens/auth/registration.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/app_snackbar.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Changed from listen:true to listen:false. We don't want the whole page to rebuild.
    // The buttons will listen for changes themselves.
    final authProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Image.asset(Images.logoWithName, height: 75),
              const SizedBox(height: 8.0),
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
              const SizedBox(height: Dimensions.paddingSize),
              Text(
                'Please login to your account.',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                maxLines: 2,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              _buildTextField(authProvider.email, 'Email', Icons.email, false),
              _buildTextField(authProvider.password, 'Password', Icons.lock, true),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // We pass the authProvider down to the button
              _buildLoginButton(authProvider), // Pass only one instance of authProvider
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildGoogleSignInButton(authProvider),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildForgotPasswordLink(context),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildRegisterLink(context),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: Dimensions.fontSizeSmall),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border_radius),
          ),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
        ),
      ),
    );
  }

  // Corrected the method signature and added logic to disable the button while loading
  Widget _buildLoginButton(UserProvider authProvider) {
    // Using a Consumer here to only rebuild the button when the status changes.
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        bool isLoading = provider.status == Status.Authenticating;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // Disable button by setting onPressed to null when loading
            onPressed: isLoading ? null : () async {
              String resultMessage = await authProvider.signIn();
              // Check if the widget is still mounted before showing UI
              if (mounted && resultMessage != "Success") {
                showAppSnackBar(context, resultMessage, isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            ),
            // Show a loading indicator inside the button
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
              'Log in',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // Corrected the method and added logic to disable the button while loading
  Widget _buildGoogleSignInButton(UserProvider authProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        bool isLoading = provider.status == Status.Authenticating;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isLoading ? Container() : Image.asset(Images.google, width: 24), // Hide icon when loading
            label: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onPressed: isLoading ? null : () async {
              String resultMessage = await authProvider.signInWithGoogle();
              if (mounted && resultMessage != "Success") {
                showAppSnackBar(context, resultMessage, isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => changeScreen(context, ForgotPasswordScreen()),
        child: Text(
          'forgot password',
          style: TextStyle(color: Colors.black, fontSize: Dimensions.fontSizeDefault),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Create an account '),
        TextButton(
          onPressed: () => changeScreen(context, RegistrationScreen()),
          child: Text(
            'Register here',
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
