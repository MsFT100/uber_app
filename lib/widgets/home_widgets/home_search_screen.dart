import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_app/screens/home.dart';

import '../../screens/map.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../utils/styles.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.searchBarSize,
      child: GestureDetector(
        onTap: () {
          print('Search bar clicked!');
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => MapScreen())); // Navigate to the Map screen
        },
        child: TextField(
          style: textRegular.copyWith(
            color:
                Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
          ),
          cursorColor: Theme.of(context).hintColor,
          autofocus: false,
          readOnly: true, // Prevents direct text input
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 0.5,
                color: Colors.black12,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 0.5,
                color: Colors.black12,
              ),
            ),
            isDense: true,
            hintText: 'where to go'.tr,
            hintStyle: textRegular.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .color!
                  .withOpacity(0.3),
            ),
            suffixIcon: IconButton(
              color: Theme.of(context).hintColor,
              onPressed: () {
                print('Voice search clicked!');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => MyHomePage(title: 'title')));
              },
              icon: Image.asset(
                Images.microPhoneIcon,
                color: Get.isDarkMode ? Theme.of(context).hintColor : null,
                height: 20,
                width: 20,
              ),
            ),
            prefixIcon: IconButton(
              color: Theme.of(context).hintColor,
              onPressed: () {
                print('Prefix icon clicked!');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => MyHomePage(title: 'title')));
              },
              icon: Image.asset(
                Images.homeSearchIcon,
                color: Get.isDarkMode ? Theme.of(context).hintColor : null,
                height: 20,
                width: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
