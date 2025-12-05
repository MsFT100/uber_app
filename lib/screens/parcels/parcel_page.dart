import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/user_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/app_bar/app_bar.dart';
import 'find_driver.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({Key? key}) : super(key: key);

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  final _formKey = GlobalKey<FormState>();
  final _senderNameController = TextEditingController();
  final _senderContactController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientContactController = TextEditingController();
  final _weightController = TextEditingController();
  final _destinationController = TextEditingController();

  String? _selectedParcelType = 'Standard';
  String _selectedVehicleType = 'Moto Express';
  LatLng? _destinationLatLng;

  final List<String> _parcelTypes = ['Standard', 'Medium Package', 'Large Package'];
  final List<String> _vehicleTypes = ['Moto Express', 'Car', 'Truck'];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _senderNameController.text = user.displayName ?? '';
      _senderContactController.text = user.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Send a Parcel', showNavBack: true, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Sender Details'),
              _buildTextField(_senderNameController, 'Name', Icons.person),
              _buildTextField(_senderContactController, 'Contact', Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildSectionTitle('Recipient Details'),
              _buildTextField(_recipientNameController, 'Name', Icons.person),
              _buildTextField(_recipientContactController, 'Contact', Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildSectionTitle('Parcel Details'),
              _buildDropdown(_parcelTypes, 'Parcel Type', _selectedParcelType, (val) => setState(() => _selectedParcelType = val)),
              const SizedBox(height: 12),
              _buildTextField(_weightController, 'Weight (kg)', Icons.line_weight, inputType: TextInputType.number),
              const SizedBox(height: 16),
              _buildSectionTitle('Delivery Details'),
              _buildDestinationSearch(),
              const SizedBox(height: 12),
              _buildDropdown(_vehicleTypes, 'Vehicle Type', _selectedVehicleType, (val) => setState(() => _selectedVehicleType = val!)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Request Parcel Delivery'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.accessToken;

    final pickupLatLng = locationProvider.center;
    final pickupAddress = locationProvider.locationAddress;

    if (pickupAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not get your current location.")));
      return;
    }
    if (_destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a destination.")));
      return;
    }
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to request a trip.")));
      return;
    }

    final trip = Trip(
      riderId: userProvider.user!.uid,
      type: TripType.parcel,
      pickup: pickupLatLng,
      pickupAddress: pickupAddress,
      destination: _destinationLatLng!,
      destinationAddress: _destinationController.text,
      senderName: _senderNameController.text,
      senderContact: _senderContactController.text,
      recipientName: _recipientNameController.text,
      recipientContact: _recipientContactController.text,
      weight: double.tryParse(_weightController.text),
      parcelType: _selectedParcelType,
      vehicleType: _selectedVehicleType,
    );

    try {
      await appState.requestNewTrip(trip, accessToken);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FindDriverScreen()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
    }
  }

  Widget _buildDestinationSearch() {
    return InkWell(
      onTap: () async {
        final result = await showSearch<PlaceSuggestion?>(
          context: context,
          delegate: AddressSearchDelegate(),
        );
        if (result != null) {
          setState(() {
            _destinationController.text = result.description;
            _destinationLatLng = LatLng(result.lat, result.lng);
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_on),
          labelText: 'Destination',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(_destinationController.text.isEmpty ? 'Select destination' : _destinationController.text, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? inputType}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white12,
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
    );
  }

  Widget _buildDropdown(List<String> items, String label, String? selected, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.category),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }
}

class AddressSearchDelegate extends SearchDelegate<PlaceSuggestion?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // In a real app, you would make an API call to a geocoding service
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // In a real app, you would show suggestions as the user types
    return ListView();
  }
}

class PlaceSuggestion {
  final String description;
  final double lat;
  final double lng;

  PlaceSuggestion({required this.description, required this.lat, required this.lng});
}
