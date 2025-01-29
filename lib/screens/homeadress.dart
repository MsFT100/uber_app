import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dimensions.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _addressController = TextEditingController();

  // Save the address to SharedPreferences
  Future<void> _saveAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('home_address', _addressController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Address saved: ${_addressController.text}')),
    );
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.paddingSizeExtraLarge,
          left: Dimensions.paddingSize,
          bottom: Dimensions.paddingSize,
          right: Dimensions.paddingSize,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your home address:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your home address',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAddress,
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }
}
