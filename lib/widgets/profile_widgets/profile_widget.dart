import 'package:BucoRide/utils/app_constants.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final bool isEdit;
  final bool isNetworkImage;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    this.imagePath,
    this.isEdit = false,
    required this.isNetworkImage,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImageWithBorder(),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: onClicked, // Make the icon clickable
              child: buildEditIcon(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageWithBorder() {
    final ImageProvider imageProvider;

    if (imagePath == null || imagePath!.isEmpty) {
      imageProvider = AssetImage("assets/default_profile.png");
    } else if (isNetworkImage) {
      imageProvider = NetworkImage(imagePath!);
    } else {
      imageProvider = AssetImage(imagePath!);
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppConstants.lightPrimary,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: imageProvider,
            fit: BoxFit.cover,
            width: 128,
            height: 128,
            child: InkWell(onTap: onClicked),
          ),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            isEdit ? Icons.add_a_photo : Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
