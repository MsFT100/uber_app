import 'package:BucoRide/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/screen_navigation.dart';
import '../../helpers/style.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';
import '../../widgets/loading.dart';
import '../menu.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    UserProvider authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        key: _scaffoldKey,
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
                          Image.asset(Images.logo, height: 75),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${'welcome to'.tr} ' + AppConstants.appName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
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
                          'JOIN US TODAY'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 32.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Register an account.',
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
                                controller: authProvider.name,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: white),
                                    border: InputBorder.none,
                                    label: Text("Full Name"),
                                    hintText: "Full Name",
                                    icon: Icon(
                                      Icons.person,
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
                                controller: authProvider.email,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: white),
                                    border: InputBorder.none,
                                    label: Text("Email"),
                                    hintText: "example@example.com",
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
                                border: Border.all(
                                    color: Colors
                                        .white), // Adjust the border color
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: IntlPhoneField(
                                controller: authProvider.phone,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  hintText: "+254", // Placeholder hint
                                  border: InputBorder.none,
                                ),
                                initialCountryCode:
                                    'KE', // You can set a default country code here
                                onChanged: (phone) {
                                  print(phone
                                      .completeNumber); // You can get the complete phone number here
                                },
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
                                    label: Text("Password"),
                                    hintText: "At least 6 characters",
                                    icon: Icon(
                                      Icons.lock,
                                      color: white,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        // Register Button
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
                                        await authProvider.signUp();
                                    if (resultMessage != "Success") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(resultMessage),
                                        ),
                                      );
                                      return;
                                    }
                                    authProvider.clearController();
                                    // Clear text fields manually
                                    authProvider.name.clear();
                                    authProvider.email.clear();
                                    authProvider.phone.clear();
                                    authProvider.password.clear();
                                    changeScreenReplacement(
                                        context,
                                        Menu(
                                          key: _scaffoldKey,
                                          title: '',
                                        ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.0),
                                  ),
                                  child: Text(
                                    'Register'.tr,
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
                        // Login Redirect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${'Already have an account'.tr} ',
                                style: TextStyle(
                                    color: Theme.of(context).hintColor)),
                            TextButton(
                              onPressed: () {
                                changeScreen(context, LoginScreen());
                              },
                              child: Text(
                                'Login here',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
