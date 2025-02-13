import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/helpers/style.dart';
import 'package:BucoRide/providers/user.dart';
import 'package:BucoRide/screens/auth/registration.dart';
import 'package:BucoRide/screens/menu.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../../utils/images.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _loginScaffoldKey = GlobalKey<ScaffoldState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNode = FocusNode();
  final passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _loginScaffoldKey,
      backgroundColor: AppConstants.lightPrimary,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SafeArea(
              child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        Image.asset(Images.logoWithName, height: 75),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${'Welcome to'.tr} ' + AppConstants.appName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 24.0,
                                ),
                              ),
                              Image.asset(Images.hand,
                                  width: 40), // Ensure you have this image
                            ]),
                      ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06),
                      Text(
                        'Log in'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 32.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Please login to your account.',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 16.0,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: white),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextFormField(
                              controller: authProvider.email,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: white),
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  icon: Icon(
                                    Icons.email,
                                    color: white,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: white),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextFormField(
                              controller: authProvider.password,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: white),
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  icon: Icon(
                                    Icons.lock,
                                    color: white,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(5),
                                        color: authProvider.isActiveRememberMe
                                            ? Colors.blueAccent
                                            : Colors.transparent,
                                      ),
                                      child: authProvider.isActiveRememberMe
                                          ? Icon(Icons.check,
                                              color: Colors.white,
                                              size:
                                                  18) // Blue tick when checked
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  GestureDetector(
                                    onTap: () =>
                                        authProvider.toggleRememberMe(),
                                    child: Text(
                                      'remember me'.tr,
                                      style: TextStyle(
                                          fontSize: Dimensions.fontSizeDefault),
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
                      authProvider.status == Status.Authenticating
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 2.0,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  String resultMessage =
                                      await authProvider.signIn();
                                  if (resultMessage != "Success") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(resultMessage),
                                      ),
                                    );
                                    return;
                                  }
                                  authProvider.clearController();
                                  changeScreenReplacement(
                                      context,
                                      Menu(
                                        title: 'Home',
                                      ));
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                ),
                                child: Text(
                                  'Log in'.tr,
                                  style: TextStyle(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 0.1)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or'.tr,
                                style: TextStyle(
                                    color: Theme.of(context).hintColor)),
                          ),
                          const Expanded(child: Divider(thickness: 0.1)),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            authProvider.signInWithGoogle();
                          },
                          icon: Image.asset(
                            'assets/image/google_icon.png', // Add a Google logo image in the assets folder
                            height: 24.0,
                            width: 24.0,
                          ),
                          label: Text(
                            'Sign In with Google'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .white, // White background like Google's button
                            side: BorderSide(
                                color: Colors.grey.shade300), // Thin border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            elevation: 2, // Subtle shadow for a raised effect
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            //Get.to(OtpLoginScreen(fromSignIn: true));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .white, // White background like Google's button
                            side: BorderSide(
                                color: Colors.grey.shade300), // Thin border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            elevation: 2, // Subtle shadow for a raised effect
                          ),
                          child: Text(
                            'OTP Login'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${'Create an account'.tr} ',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                          TextButton(
                            onPressed: () {
                              changeScreen(context, RegistrationScreen());
                            },
                            child: Text(
                              'Register here',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            )),
    );
  }
}
