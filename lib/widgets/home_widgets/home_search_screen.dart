import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/home.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          changeScreen(context, MapScreen()); // Navigate to the Map screen
        },
        child: TextField(
          style: textRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
          onTap: () {
            changeScreen(context, HomePage());
          },
          cursorColor: Theme.of(context).hintColor,
          autofocus: true,
          readOnly: true, // Prevents direct text input
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: AppConstants.lightPrimary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: AppConstants.lightPrimary,
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
              color: Theme.of(context).textTheme.bodyMedium!.color!,
            ),
            suffixIcon: IconButton(
              color: Theme.of(context).hintColor,
              onPressed: () {
                print('Voice search clicked!');
                changeScreen(context, HomePage());
              },
              icon: Image.asset(
                Images.microPhoneIcon,
                color: Get.isDarkMode ? Theme.of(context).hintColor : null,
                height: Dimensions.iconSizeSmall,
                width: Dimensions.iconSizeSmall,
              ),
            ),
            prefixIcon: IconButton(
              color: Theme.of(context).hintColor,
              onPressed: () {
                print('Prefix icon clicked!');
                changeScreen(context, HomePage());
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
