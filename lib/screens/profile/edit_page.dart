import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/models/user.dart';
import 'package:BucoRide/providers/user.dart';
import 'package:BucoRide/screens/profile_page.dart';
import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:BucoRide/widgets/profile_widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../utils/images.dart';
import '../../widgets/profile_widgets/text_field_widget.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool networkImage = false;
  late TextEditingController _nameController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.userModel?.name);
    _numberController =
        TextEditingController(text: userProvider.userModel?.phone);

    networkImage = userProvider.user?.photoURL != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    Provider.of<UserProvider>(context, listen: false).updateProfilePic(image);

    setState(() {
      _image = image;
      networkImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Edit Profile",
        showNavBack: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Image with Edit Button
            Center(
              child: Stack(
                children: [
                  ProfileWidget(
                    imagePath: userProvider.user?.photoURL ?? Images.person,
                    isEdit: true,
                    onClicked: _pickImage,
                    isNetworkImage: networkImage,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Name Field
            TextFieldWidget(
              label: 'Full Name',
              text: _nameController.text,
              onChanged: (name) {
                _nameController.text = name;
              },
            ),

            const SizedBox(height: 20),

            // Phone Number Field
            TextFieldWidget(
              label: 'Phone Number',
              text: _numberController.text,
              onChanged: (number) {
                _numberController.text = number;
              },
            ),

            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                final userdata = UserModel(
                  name: _nameController.text.trim(),
                  phoneNumber: _numberController.text.trim(),
                );

                await userProvider.updateUserData(userdata);
                changeScreenReplacement(context, ProfileScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.lightPrimary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
