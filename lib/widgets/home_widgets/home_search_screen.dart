import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';


import '../../screens/map.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: Dimensions.searchBarSize,
      child: TextField(
        onTap: () {
          changeScreen(context, MapScreen());
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
          hintText: 'Where to go?',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).hintColor,
          ),
          suffixIcon: IconButton(
            color: Theme.of(context).hintColor,
            onPressed: () {
              print('Voice search clicked!');
              changeScreen(context, MapScreen());
            },
            icon: Image.asset(
              Images.microPhoneIcon,
              color: isDarkMode ? Theme.of(context).hintColor : null,
              height: Dimensions.iconSizeSmall,
              width: Dimensions.iconSizeSmall,
            ),
          ),
          prefixIcon: IconButton(
            color: Theme.of(context).hintColor,
            onPressed: () {
              print('Prefix icon clicked!');
              changeScreen(context, MapScreen());
            },
            icon: Image.asset(
              Images.homeSearchIcon,
              color: isDarkMode ? Theme.of(context).hintColor : null,
              height: 20,
              width: 20,
            ),
          ),
        ),
      ),
    );
  }
}
