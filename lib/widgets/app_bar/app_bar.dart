import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNavBack;
  final bool centerTitle;

  const CustomAppBar(
      {Key? key,
      required this.title,
      required this.showNavBack,
      required this.centerTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: Dimensions.fontSizeLarge,
          fontWeight: AppConstants.defaultWeight,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: showNavBack,
      //backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: AppConstants.lightPrimary,
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
