import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/loading_widgets/loading.dart';
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _loginScaffoldKey = GlobalKey<ScaffoldState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _loginScaffoldKey,
      backgroundColor: AppConstants.lightPrimary,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SafeArea(
              child: _fadeAnimation == null
                  ? Center(
                      child: Loading()) // Avoid using it before initialization
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Image.asset(Images.logoWithName, height: 75),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${'Welcome to'.tr} ' +
                                            AppConstants.appName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      Image.asset(Images.hand, width: 40),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.06),
                              _buildTextField(authProvider.email, "Email",
                                  Icons.email, false),
                              const SizedBox(height: 16.0),
                              _buildLoginButton(authProvider),
                              const SizedBox(height: 16.0),
                              _buildDivider(),
                              const SizedBox(height: 16.0),
                              _buildEmailLoginButton(),
                              const SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.black, width: 2.5),
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
          String message = await authProvider.ResetPassword();

          if (message == "Success") {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("Password reset link sent. Check Your Email"),
                  );
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${message}")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          'Reset Password'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or'.tr, style: TextStyle(color: Colors.grey)),
        ),
        const Expanded(child: Divider(thickness: 0.1)),
      ],
    );
  }

  Widget _buildEmailLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          changeScreen(context, LoginScreen());
        },
        style: OutlinedButton.styleFrom(
          shape: StadiumBorder(),
          side: BorderSide(color: Colors.blueAccent),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          'back to Login'.tr,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    );
  }
}
