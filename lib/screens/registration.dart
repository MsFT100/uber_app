import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/screen_navigation.dart';
import '../helpers/style.dart';
import '../providers/app_state.dart';
import '../providers/user.dart';
import '../widgets/custom_text.dart';
import '../widgets/loading.dart';
import 'home.dart';
import 'login.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    UserProvider authProvider = Provider.of<UserProvider>(context);
    AppStateProvider app = Provider.of<AppStateProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.deepOrange,
      body: authProvider.status == Status.Authenticating
          ? Loading()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    color: white,
                    height: 100,
                  ),
                  Container(
                    color: white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/lg.png",
                          width: 230,
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    color: white,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Name Input
                  buildInputField(
                    controller: authProvider.name,
                    label: "Name",
                    hintText: "e.g., John Doe",
                    icon: Icons.person,
                  ),
                  // Email Input
                  buildInputField(
                    controller: authProvider.email,
                    label: "Email",
                    hintText: "e.g., john.doe@example.com",
                    icon: Icons.email,
                  ),
                  // Phone Input
                  buildInputField(
                    controller: authProvider.phone,
                    label: "Phone",
                    hintText: "+91 1234567890",
                    icon: Icons.phone,
                  ),
                  // Password Input
                  buildInputField(
                    controller: authProvider.password,
                    label: "Password",
                    hintText: "At least 6 characters",
                    icon: Icons.lock,
                  ),
                  // Register Button
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () async {
                        if (!await authProvider.signUp()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Registration failed!")),
                          );
                          return;
                        }
                        // Clear text fields manually
                        authProvider.name.clear();
                        authProvider.email.clear();
                        authProvider.phone.clear();
                        authProvider.password.clear();

                        changeScreenReplacement(
                          context,
                          MyHomePage(
                            title: '',
                          ),
                        );
                      },
                      child: buildButton("Register"),
                    ),
                  ),
                  // Login Redirect
                  GestureDetector(
                    onTap: () {
                      changeScreen(context, LoginScreen());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomText(
                          text: "Login here",
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: white),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: white),
              border: InputBorder.none,
              labelStyle: TextStyle(color: white),
              labelText: label,
              hintText: hintText,
              icon: Icon(
                icon,
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Container(
      decoration: BoxDecoration(
        color: black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomText(
              text: text,
              color: white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
