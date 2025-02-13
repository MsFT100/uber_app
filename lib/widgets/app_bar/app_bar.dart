import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';

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
        style: TextStyle(fontSize: 20, fontWeight: AppConstants.defaultWeight),
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
