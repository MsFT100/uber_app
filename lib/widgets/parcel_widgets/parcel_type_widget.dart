import 'package:flutter/material.dart';

class ParcelTypeSelection extends StatefulWidget {
  final Function(String) onSelected; // Callback to send selected type

  const ParcelTypeSelection({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _ParcelTypeSelectionState createState() => _ParcelTypeSelectionState();
}

class _ParcelTypeSelectionState extends State<ParcelTypeSelection> {
  String? selectedParcelType;

  final List<Map<String, dynamic>> parcelTypes = [
    {"icon": Icons.local_shipping, "label": "Standard"},
    {"icon": Icons.electric_bike, "label": "Express"},
    {"icon": Icons.local_mall, "label": "Small Package"},
    {"icon": Icons.shopping_cart, "label": "Large Package"},
    {"icon": Icons.food_bank, "label": "Food Stuffs"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Your Delivery Type",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: parcelTypes.map((parcel) {
            bool isSelected = parcel["label"] == selectedParcelType;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedParcelType = parcel["label"];
                });
                widget.onSelected(
                    parcel["label"]); // Send selected type to parent
              },
              child: Column(
                children: [
                  Icon(parcel["icon"],
                      size: 40, color: isSelected ? Colors.blue : Colors.grey),
                  SizedBox(height: 5),
                  Text(
                    parcel["label"],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
