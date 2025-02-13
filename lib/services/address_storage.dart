import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddressStorage {
  static const String _key = 'saved_addresses';

  // Save addresses to SharedPreferences
  static Future<void> saveAddresses(List<String> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(addresses));
  }

  // Retrieve addresses from SharedPreferences
  static Future<List<String>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesJson = prefs.getString(_key);
    if (addressesJson != null) {
      return List<String>.from(jsonDecode(addressesJson));
    }
    return [];
  }

  Future<List<String>> getSavedAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('addresses') ?? [];
  }
}
