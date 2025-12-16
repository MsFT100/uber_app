import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/saved_address.dart';
import '../../../utils/app_constants.dart';
import '../../../widgets/app_bar/app_bar.dart';
import '../../../widgets/loading_widgets/loading.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  late Future<List<SavedAddress>> _addressesFuture;
  List<SavedAddress> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _addressesFuture = _loadAddresses();
  }

  Future<List<SavedAddress>> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList('addresses') ?? [];
    _savedAddresses =
        addressesJson.map((json) => SavedAddress.fromJson(json)).toList();
    return _savedAddresses;
  }

  Future<void> _updateAddressOrder(List<SavedAddress> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = addresses.map((a) => a.toJson()).toList();
    await prefs.setStringList('addresses', addressesJson);
    setState(() {
      _savedAddresses = addresses;
    });
  }

  Future<void> _deleteAddress(int index, SavedAddress address) async {
    // 1. Remove from the local list to update UI immediately
    setState(() {
      _savedAddresses.removeAt(index);
    });

    // 2. Clear any previous snackbars and show a new one with an Undo action.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text('"${address.label}" deleted.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // 3. If Undo is pressed, re-insert the address and do not save.
          setState(() {
            _savedAddresses.insert(index, address);
          });
        },
      ),
    );

    // 4. Show the SnackBar and wait for it to close.
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      // 5. Only persist the changes to storage if the user did NOT press Undo.
      if (reason != SnackBarClosedReason.action) {
        _updateAddressOrder(_savedAddresses);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Manage Addresses",
        showNavBack: true,
        centerTitle: true,
      ),
      body: FutureBuilder<List<SavedAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Loading());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("You have no saved addresses."),
            );
          }

          return ReorderableListView(
            padding: const EdgeInsets.all(8.0),
            header: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Press and hold an item to drag and reorder.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final SavedAddress item = _savedAddresses.removeAt(oldIndex);
                _savedAddresses.insert(newIndex, item);
              });
              _updateAddressOrder(_savedAddresses);
            },
            children: _savedAddresses.asMap().entries.map((entry) {
              final int index = entry.key;
              final SavedAddress address = entry.value;

              return Dismissible(
                key: ValueKey(address.address + index.toString()), // Unique key
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteAddress(index, address);
                },
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete_sweep, color: Colors.white),
                ),
                child: Card(
                  key: ValueKey(
                      address.address), // Key for ReorderableListView's logic
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppConstants.lightPrimary),
                    title: Text(address.label,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      address.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(
                      Icons.drag_handle_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
