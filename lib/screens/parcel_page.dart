import 'package:BucoRide/widgets/app_bar/app_bar.dart';
import 'package:BucoRide/widgets/parcel_widgets/parcel_type_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/dimensions.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderContactController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientContactController =
      TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? selectedParcelType;

  void submitData() async {
    if (selectedParcelType == null ||
        senderNameController.text.isEmpty ||
        senderContactController.text.isEmpty ||
        recipientNameController.text.isEmpty ||
        recipientContactController.text.isEmpty ||
        destinationController.text.isEmpty ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill all fields and select a parcel type.")));
      return;
    }

    double? weight = double.tryParse(weightController.text);
    if (weight == null || weight > 100) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Weight must be a number and not exceed 100kg.")));
      return;
    }

    // Consolidating data
    Map<String, dynamic> parcelData = {
      "senderName": senderNameController.text.trim(),
      "senderContact": senderContactController.text.trim(),
      "recipientName": recipientNameController.text.trim(),
      "recipientContact": recipientContactController.text.trim(),
      "destination": destinationController.text.trim(),
      "weight": weight,
      "parcelType": selectedParcelType,
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Storing in Firestore
    await FirebaseFirestore.instance.collection("parcels").add(parcelData);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Parcel details submitted!")));

    // Clear fields after submission
    senderNameController.clear();
    senderContactController.clear();
    recipientNameController.clear();
    recipientContactController.clear();
    destinationController.clear();
    weightController.clear();
    setState(() {
      selectedParcelType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Parcel",
        showNavBack: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // Sender Name
            TextField(
              controller: senderNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "Sender Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Sender Contact
            TextField(
              controller: senderContactController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "Sender Contact",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Recipient Name
            TextField(
              controller: recipientNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.receipt_rounded),
                labelText: "Recipient Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Recipient Contact
            TextField(
              controller: recipientContactController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.call),
                labelText: "Recipient Contact",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Destination
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.map,
                  color: Colors.red,
                ),
                labelText: "Destination Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Weight
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))
              ],
              controller: weightController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.import_contacts_sharp,
                  color: Colors.red,
                ),
                labelText: "Weight (max 100kg)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Parcel Type Selection
            ParcelTypeSelection(
              onSelected: (type) {
                setState(() {
                  selectedParcelType = type;
                });
              },
            ),

            SizedBox(height: 30),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Submit Parcel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
