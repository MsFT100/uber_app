import 'package:BucoRide/utils/dimensions.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';

import '../utils/images.dart';

class HelpAndSupport extends StatelessWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "Help & Support", showNavBack: true, centerTitle: true),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(Images.helpAndSupport),
            Container(
              child: Column(
                children: [
                  Text(
                    "Contact us through email",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "You can send us an email through \n",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  Text(
                    "bucoridedatabase@gmail.com \n",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "Typicaly the support team will send a feedback within 2 hours \n",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "Contact us through Phone at \n",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "0700000000 \n",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Email",
                    style: TextStyle(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Phone",
                    style: TextStyle(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
