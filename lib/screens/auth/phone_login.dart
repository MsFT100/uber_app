import 'package:BucoRide/screens/auth/registration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/loading_widgets/loading.dart';
import 'login.dart';
import 'otp.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
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
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: IntlPhoneField(
                                  controller: authProvider
                                      .phone, // This holds only the local number
                                  decoration: InputDecoration(
                                    labelText: "Phone",
                                    filled: true,
                                    fillColor: Colors.white, // White background
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          25.0), // Rounded corners
                                      borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1), // Black border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.5), // Thicker on focus
                                    ),
                                    prefixIcon: Icon(Icons.phone_android,
                                        color: Colors.grey[700]),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                  ),
                                  initialCountryCode:
                                      'KE', // Set Kenya as default country
                                  onChanged: (phone) {
                                    authProvider.setFormattedPhone(phone
                                        .completeNumber); // Store full E.164 number
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () => authProvider
                                          .toggleRememberMe(), // Makes entire row clickable
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                authProvider.toggleRememberMe(),
                                            child: Container(
                                              width: Dimensions.iconSizeMedium,
                                              height: Dimensions.iconSizeMedium,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: authProvider
                                                        .isActiveRememberMe
                                                    ? Colors.blueAccent
                                                    : Colors.transparent,
                                              ),
                                              child: authProvider
                                                      .isActiveRememberMe
                                                  ? Icon(Icons.check,
                                                      color: Colors.white,
                                                      size:
                                                          18) // Blue tick when checked
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          GestureDetector(
                                            onTap: () =>
                                                authProvider.toggleRememberMe(),
                                            child: Text(
                                              'remember me'.tr,
                                              style: TextStyle(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //Get.to(ForgotPasswordScreen());
                                    },
                                    child: Text(
                                      'forgot password'.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              _buildLoginButton(authProvider),
                              const SizedBox(height: 16.0),
                              _buildDivider(),
                              const SizedBox(height: 16.0),
                              _buildEmailLoginButton(),
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

  Widget _buildLoginButton(UserProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          String phoneNumber = authProvider.formattedPhone.trim();

          if (phoneNumber.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please enter your phone number")),
            );
            return;
          }

          // ✅ Ensure number is in E.164 format
          if (!RegExp(r'^\+\d{10,15}$').hasMatch(phoneNumber)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Invalid phone number format. Try again.")),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sending OTP... Please wait")),
          );

          bool isSent = await authProvider.PhoneSignIn(phoneNumber, context);

          if (isSent) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    OTPScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          'Log in'.tr,
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
