import 'dart:async';

import 'package:BucoRide/screens/auth/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/loading_widgets/loading.dart';
import '../menu.dart';
import 'login.dart';

class OTPScreen extends StatefulWidget {
  // OTP verification ID passed from phone screen

  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _loginScaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

  ///Timer
  int _resendTimeout = 60; // Timer duration in seconds
  late Timer _timer;
  bool _canResend = false;

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
    // Start Countdown Timer for Resend OTP
    startResendTimer();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      _resendTimeout = 60; // Reset to 60 seconds
      _canResend = false; // Disable Resend Button
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _canResend = true; // Enable Resend Button
        });
      }
    });
  }

  Future<void> verifyOTP() async {
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => isLoading = true);
    try {
      // ✅ Ensure we are using the latest verification ID
      String? verificationId = authProvider.verificationId;
      if (verificationId == null) {
        throw Exception("Verification ID is missing. Request OTP again.");
      }

      // Create credential using entered OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: authProvider.otpController.text.trim(),
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again. Error: $e')),
      );
    }
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
                              _buildTextField(authProvider.otpController, "OTP",
                                  Icons.password, false),
                              const SizedBox(height: 16.0),
                              _buildLoginButton(authProvider),
                              const SizedBox(height: 16.0),
                              _buildResendButton(authProvider),
                              const SizedBox(height: 16.0),
                              _buildDivider(),
                              const SizedBox(height: 16.0),
                              _buildOtpLoginButton(),
                              const SizedBox(height: 16.0),
                              _buildRegisterLink(context),
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
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
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
          verifyOTP();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          'Verify'.tr,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    );
  }

  Widget _buildResendButton(UserProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canResend
            ? () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Sending OTP... Please wait")),
                );

                bool isSent = await authProvider.PhoneSignIn(
                    authProvider.formattedPhone, context);

                if (isSent) {
                  startResendTimer(); // Restart timer after resending OTP
                  authProvider.otpController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP resent successfully!")),
                  );
                }
              }
            : null, // Disable button while countdown is running
        style: ElevatedButton.styleFrom(
          backgroundColor: _canResend ? Colors.blueAccent : Colors.grey,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          _canResend ? "Resend OTP" : "Resend in $_resendTimeout sec",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.fontSizeLarge),
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

  Widget _buildOtpLoginButton() {
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
          'Email Login'.tr,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${'Create an account'.tr} '),
        TextButton(
          onPressed: () => changeScreen(context, RegistrationScreen()),
          child: Text(
            'Register here',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
