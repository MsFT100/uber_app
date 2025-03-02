import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/screen_navigation.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/images.dart';
import '../../../widgets/loading_widgets/loading.dart';
import 'adress_page.dart';

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

  Future<List<String>> _getSavedAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('addresses') ?? [];
  }

  Future<void> _deleteAddress(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current list of saved addresses
    List<String> savedAddresses = await _getSavedAddresses();

    // Remove the address at the specified index
    savedAddresses.removeAt(index);

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('addresses', savedAddresses);

    // Update the state to reflect changes
    setState(() {
      print("preview Screen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getSavedAddresses(), // Load addresses from SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loading());
        }
        List<String> savedAddresses = snapshot.data ?? [];
        print("list:========${savedAddresses}");

        return savedAddresses.isNotEmpty
            ? Container(
                height: 150,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 🔄 Scrolls left to right
                  itemCount: savedAddresses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 3.0),
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
                            title: Text(savedAddresses[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteAddress(index), // 🗑️ Delete function
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : _buildAddAddressCard(context);
      },
    );
  }
}

// Add Address Card
Widget _buildAddAddressCard(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Navigate to Add Address Page
      changeScreen(context, AddNewAddressPage());
    },
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppConstants.lightPrimary,
        ),
        borderRadius: BorderRadius.circular(12.0),
        color: AppConstants.lightPrimary,
      ),
      child: Row(
        children: [
          Icon(Icons.add, size: 32, color: Colors.white),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Save your address for quick trip planning',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ],
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
