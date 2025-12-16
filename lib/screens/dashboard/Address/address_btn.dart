import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/saved_address.dart';
import '../../../helpers/screen_navigation.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/images.dart';
import '../../../widgets/loading_widgets/loading.dart';
import '../../home.dart';
import 'adress_page.dart';
import 'manage_addresses_screen.dart';

class HomeMyAddress extends StatefulWidget {
  final String? title;

  const HomeMyAddress({Key? key, this.title}) : super(key: key);

  @override
  _HomeMyAddressState createState() => _HomeMyAddressState();
}

class _HomeMyAddressState extends State<HomeMyAddress> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<SavedAddress>> _getSavedAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList('addresses') ?? [];
    return addressesJson.map((json) => SavedAddress.fromJson(json)).toList();
  }

  Future<void> _deleteAddress(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current list of saved addresses
    List<String> savedAddressesJson = prefs.getStringList('addresses') ?? [];

    // Remove the address at the specified index
    if (index < savedAddressesJson.length) {
      savedAddressesJson.removeAt(index);
    }

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('addresses', savedAddressesJson);

    // Update the state to reflect changes
    setState(() {
      print("preview Screen");
    });
  }

  Future<void> _editAddress(
      BuildContext context, SavedAddress currentAddress, int index) async {
    // Navigate to the address page in 'edit' mode and wait for a result.
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewAddressPage(
          isEditing: true,
          savedAddress: currentAddress,
          addressIndex: index,
        ),
      ),
    );

    // If the address was saved, refresh the list.
    if (result == true) setState(() {});
  }

  Future<void> _navigateAndRefresh() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddNewAddressPage()),
    );

    // If a new address was added, refresh the list.
    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Saved Places",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageAddressesScreen()),
                  );
                  // Refresh the list if changes were made
                  if (mounted) setState(() {});
                },
                child: const Text("Manage"),
              ),
            ],
          ),
        ),
        FutureBuilder<List<SavedAddress>>(
          future: _getSavedAddresses(), // Load addresses from SharedPreferences
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            }
            List<SavedAddress> savedAddresses = snapshot.data ?? [];

            if (savedAddresses.isEmpty) {
              return _buildAddAddressCard(context, isStandalone: true);
              return _buildAddAddressCard(context,
                  isStandalone: true, onAdd: _navigateAndRefresh);
            }

            return Container(
              height: 150,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // 🔄 Scrolls left to right
                itemCount: savedAddresses.length < 5
                    ? savedAddresses.length + 1
                    : savedAddresses.length,
                itemBuilder: (context, index) {
                  // If we are at the end of the list and there's space for more, show the 'Add' card.
                  if (index == savedAddresses.length &&
                      savedAddresses.length < 5) {
                    return _buildAddAddressCard(context, isStandalone: false);
                    return _buildAddAddressCard(context,
                        isStandalone: false, onAdd: _navigateAndRefresh);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<LocationProvider>()
                            .setDestinationFromAddress(savedAddresses[index].address);
                        changeScreen(context, HomePage());
                      },
                      child: Card(
                        color: AppConstants
                            .lightPrimary, // 🏷️ Each tile inside a white card
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: 350, // 📏 Fixed width for each card
                          child: ListTile(
                            leading: Image.asset(
                              Images.addNewAddress,
                              width: 50,
                              height: 50,
                            ), // 📍 Location icon
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  savedAddresses[index].label,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  savedAddresses[index].address,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white70),
                                  onPressed: () => _editAddress(
                                      context, savedAddresses[index], index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteAddress(
                                      index), // 🗑️ Delete function
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// Add Address Card
Widget _buildAddAddressCard(BuildContext context,
    {required bool isStandalone}) {
    {required bool isStandalone, required VoidCallback onAdd}) {
  // If it's a standalone card (no other addresses exist), make it full width.
  // Otherwise, make it a smaller card to fit in the horizontal list.
  if (isStandalone) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => AddNewAddressPage()),
        );
        if (result == true && context.mounted) {
          // Trigger a rebuild on the parent stateful widget that contains this card.
          final parentState = context.findAncestorStateOfType<_HomeMyAddressState>();
          if (parentState != null && parentState.mounted) {
            parentState.setState(() {});
          }
        }
      },
      onTap:
          onAdd, // Use the callback to handle navigation and state refresh.
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.lightPrimary),
          borderRadius: BorderRadius.circular(12.0),
          color: AppConstants.lightPrimary,
        ),
        child: const Row(
          children: [
            Icon(Icons.add, size: 32, color: Colors.white),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Address',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.0),
                  Text('Save your address for quick trip planning',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact card for horizontal list
  return GestureDetector(
    onTap: () => changeScreen(context, AddNewAddressPage()),
    onTap: onAdd, // Use the callback here as well.
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const SizedBox(
          width: 100,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_circle_outline,
                color: AppConstants.lightPrimary, size: 30),
            SizedBox(height: 8),
            Text("Add New",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.lightPrimary)),
          ]),
        ),
      ),
    ),
  );
}

// Individual Address Item Card
class AddressItemCard extends StatelessWidget {
  final String address;

  const AddressItemCard({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate or select the address when tapped
        print("Address tapped: $address");
        changeScreen(context, AddNewAddressPage());
      },
      child: Flexible(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents unnecessary expansion
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                Images.addNewAddress,
                width: 80, // Reduce width if needed
                height: 80, // Reduce height if needed
                fit: BoxFit.contain, // Ensures image fits within bounds
              ),
              const SizedBox(height: 8.0),
              Flexible(
                // Prevents text from overflowing
                child: Text(
                  address,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Limits lines to prevent overflow
                  overflow:
                      TextOverflow.ellipsis, // Adds "..." if text is too long
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
                            