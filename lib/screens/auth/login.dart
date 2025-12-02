import 'package:BucoRide/helpers/constants.dart';
import 'package:BucoRide/screens/auth/forgot_password.dart';
import 'package:BucoRide/screens/auth/registration.dart';
import 'package:BucoRide/screens/profile_page.dart';
import 'package:BucoRide/widgets/loading_widgets/loading.dart';
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
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SafeArea(
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
                    _buildLoginButton(authProvider),
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

  Widget _buildLoginButton(UserProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          String resultMessage = await authProvider.signIn();
          if (resultMessage != "Success") {
            showAppSnackBar(context, resultMessage, isError: true);
          } else {
            authProvider.clearController();
            changeScreenReplacement(context, ProfileScreen());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        ),
        child: Text(
          'Log in',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(UserProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Image.asset(Images.google, width: 24),
        label: Text(
          'Sign in with Google',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          String resultMessage = await authProvider.signInWithGoogle();
          if (resultMessage != "Success") {
            showAppSnackBar(context, resultMessage, isError: true);
          } else {
            authProvider.clearController();
            changeScreenReplacement(context, ProfileScreen());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        ),
      ),
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
