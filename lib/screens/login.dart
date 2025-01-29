import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:user_app/helpers/screen_navigation.dart';
import 'package:user_app/helpers/style.dart';
import 'package:user_app/providers/user.dart';
import 'package:user_app/screens/menu.dart';
import 'package:user_app/screens/registration.dart';
import 'package:user_app/utils/app_constants.dart';
import 'package:user_app/widgets/loading.dart';

import '../utils/images.dart';

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
      //backgroundColor: A,
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
                        Image.asset(Images.logo, height: 75),
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
                                  color: Theme.of(context).primaryColorLight,
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
                          color: Theme.of(context).primaryColorLight,
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
                                  Checkbox(
                                    checkColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    activeColor: Theme.of(context).primaryColor,
                                    value: authProvider.isRememberMe,
                                    onChanged: (bool? isChecked) =>
                                        authProvider.toggleRememberMe(),
                                  ),
                                  const SizedBox(width: 8.0),
                                  GestureDetector(
                                    onTap: () => authProvider
                                        .toggleRememberMe(), // Text is also clickable
                                    child: Text(
                                      'remember me'.tr,
                                      style: TextStyle(fontSize: 14.0),
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
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14.0),
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
                              //constraints: BoxConstraints(maxWidth: 300),
                              width: 400,
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
                                  style: TextStyle(fontSize: 18.0),
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
                        width: 400,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement OTP-Screen
                            //Get.to(OtpLoginScreen(fromSignIn: true));
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: Text(
                            'OTP Login'.tr,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
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
