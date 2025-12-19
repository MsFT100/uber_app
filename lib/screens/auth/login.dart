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
import '../menu.dart';
import '../../widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the Form

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
          child: Form( // Wrap in a Form widget
            key: _formKey,
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
              _buildTextField(
                  authProvider.password, 'Password', Icons.lock, true),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // We pass the authProvider down to the button
              _buildLoginButton(
                  authProvider), // Pass only one instance of authProvider
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
    ),);
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool obscureText,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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

  // --- Validation Methods ---

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    return null; // Simple check for login, length check is more for registration
  }

  Widget _buildLoginButton(UserProvider authProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.status == Status.Authenticating;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    // First, validate the form
                    if (!_formKey.currentState!.validate()) {
                      showAppSnackBar(
                          context, "Please correct the errors in the form.",
                          isError: true);
                      return;
                    }

                    final resultMessage = await provider.signIn();

                    if (!context.mounted) return;

                    if (resultMessage == "Success") {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => Menu()),
                      );
                    } else {
                      showAppSnackBar(context, resultMessage, isError: true);
                    }
                  },
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text("Log in"),
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
            icon: isLoading
                ? Container()
                : Image.asset(Images.google,
                    width: 24), // Hide icon when loading
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(
                    'Sign in with Google',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
            onPressed: isLoading
                ? null
                : () async {
                    String resultMessage =
                        await authProvider.signInWithGoogle();
                    if (!mounted) return; // Always check if the widget is still in the tree

                    if (resultMessage == "Success") {
                      // Navigate to the Menu screen on successful login
                      changeScreenReplacement(context, Menu());
                    } else {
                      showAppSnackBar(context, resultMessage, isError: true); // Show error if it failed
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall),
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
          style: TextStyle(
              color: Colors.black, fontSize: Dimensions.fontSizeDefault),
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
