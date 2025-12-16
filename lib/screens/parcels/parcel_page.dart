import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/saved_address.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_bar/app_bar.dart';
import 'parcel_location_selection_screen.dart';
import 'parcel_vehicle_selection_screen.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _parcelDescriptionController = TextEditingController();

  LatLng? _pickupCoordinates;
  LatLng? _dropoffCoordinates;
  // Add state for parcel size
  String _selectedParcelSize = 'Small'; // Default to 'Small'
  final List<String> _parcelSizes = ['Small', 'Medium', 'Large'];

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _recipientAddressController.dispose();
    _parcelDescriptionController.dispose();
    super.dispose();
  }

  Future<List<SavedAddress>> _getSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList('addresses') ?? [];
    return addressesJson.map((json) => SavedAddress.fromJson(json)).toList();
  }

  Future<void> _onLocationFieldTapped(
      TextEditingController controller, String label) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Choose from map'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet first
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ParcelLocationSelectionScreen(title: label),
                    ),
                  );
                  if (result != null && result.containsKey('address')) {
                    controller.text = result['address'];
                    if (label.contains("Pickup")) {
                      _pickupCoordinates = result['coordinates'];
                    } else {
                      _dropoffCoordinates = result['coordinates'];
                    }
                  }
                },
              ),
              const Divider(),
              FutureBuilder<List<SavedAddress>>(
                future: _getSavedAddresses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final addresses = snapshot.data!;
                  return Column(
                    children: addresses.map((savedAddress) {
                      return ListTile(
                        leading: Icon(savedAddress.label == 'Home'
                            ? Icons.home_outlined
                            : savedAddress.label == 'Work'
                                ? Icons.work_outline
                                : Icons.location_on_outlined),
                        title: Text(savedAddress.label),
                        subtitle: Text(savedAddress.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => _handleSavedAddressSelection(savedAddress, controller, label),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSavedAddressSelection(SavedAddress savedAddress,
      TextEditingController controller, String label) async {
    Navigator.pop(context); // Close bottom sheet
    controller.text = savedAddress.address;

    try {
      List<Location> locations =
          await locationFromAddress(savedAddress.address);
      if (locations.isNotEmpty) {
        final coords =
            LatLng(locations.first.latitude, locations.first.longitude);
        if (label.contains("Pickup")) {
          _pickupCoordinates = coords;
        } else {
          _dropoffCoordinates = coords;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${savedAddress.label} location set.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not find location for the address: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _validateAndContinue() {
    // Basic validation
    if (_senderNameController.text.isEmpty ||
        _senderPhoneController.text.isEmpty ||
        _senderAddressController.text.isEmpty ||
        _recipientNameController.text.isEmpty ||
        _recipientPhoneController.text.isEmpty ||
        _recipientAddressController.text.isEmpty ||
        _parcelDescriptionController.text.isEmpty ||
        _pickupCoordinates == null ||
        _dropoffCoordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // All good, package the data and navigate
    final parcelData = {
      'pickupCoordinates': _pickupCoordinates,
      'dropoffCoordinates': _dropoffCoordinates,
      'pickupAddress': _senderAddressController.text,
      'dropoffAddress': _recipientAddressController.text,
      'senderName': _senderNameController.text,
      'senderPhone': _senderPhoneController.text,
      'recipientName': _recipientNameController.text,
      'recipientPhone': _recipientPhoneController.text,
      'description': _parcelDescriptionController.text,
      'size': _selectedParcelSize.toLowerCase(),
    };

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ParcelVehicleSelectionScreen(parcelData: parcelData),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Create a Delivery",
        showNavBack: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Sender Details", Icons.person_outline),
            const SizedBox(height: Dimensions.paddingSize),
            _buildTextField(
                _senderNameController, "Sender's Name", Icons.badge_outlined),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildTextField(
                _senderPhoneController, "Sender's Phone", Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildLocationField(
                _senderAddressController, "Pickup Address", Icons.my_location),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            _buildSectionHeader(
                "Recipient Details", Icons.person_pin_circle_outlined),
            const SizedBox(height: Dimensions.paddingSize),
            _buildTextField(_recipientNameController, "Recipient's Name",
                Icons.badge_outlined),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildTextField(_recipientPhoneController, "Recipient's Phone",
                Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildLocationField(_recipientAddressController, "Drop-off Address",
                Icons.location_on_outlined),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            _buildSectionHeader("Parcel Details", Icons.archive_outlined),
            const SizedBox(height: Dimensions.paddingSize),
            _buildTextField(
              _parcelDescriptionController,
              "Parcel Description (e.g., 'A box of documents')",
              Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildParcelSizeSelector(),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeLarge),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
                child: const Text(
                  "Continue to Vehicle Selection",
                  style: TextStyle(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.lightPrimary, size: 24),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: Dimensions.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide:
              const BorderSide(color: AppConstants.lightPrimary, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildParcelSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Parcel Size",
          style: TextStyle(
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(
          spacing: Dimensions.paddingSizeSmall,
          children: _parcelSizes.map((size) {
            return ChoiceChip(
              label: Text(size),
              labelStyle: TextStyle(
                  color: _selectedParcelSize == size
                      ? Colors.white
                      : Colors.black87),
              selected: _selectedParcelSize == size,
              onSelected: (isSelected) {
                if (isSelected) {
                  setState(() => _selectedParcelSize = size);
                }
              },
              selectedColor: AppConstants.lightPrimary,
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _onLocationFieldTapped(controller, label),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: AppConstants.lightPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide:
              const BorderSide(color: AppConstants.lightPrimary, width: 2),
        ),
      ),
    );
  }
}
