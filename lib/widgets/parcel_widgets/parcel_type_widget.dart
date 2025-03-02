import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class ParcelTypeSelection extends StatefulWidget {
  final Function(String) onSelected;
  final String? selectedType;

  const ParcelTypeSelection(
      {Key? key, required this.onSelected, this.selectedType})
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
  void initState() {
    super.initState();
    selectedParcelType = widget.selectedType ??
        parcelTypes.first["label"]; // Default to first option
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.lightPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Your Delivery Type",
              style: TextStyle(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Dimensions.paddingSizeDefault),
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: parcelTypes.map((parcel) {
                  bool isSelected = parcel["label"] == selectedParcelType;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedParcelType = parcel["label"];
                      });
                      widget.onSelected(parcel["label"]);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 120, // Fixed width for uniform size
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.blue[200] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            parcel["icon"],
                            size: 40,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          SizedBox(height: 5),
                          Text(
                            parcel["label"],
                            textAlign:
                                TextAlign.center, // Ensure text is centered
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
