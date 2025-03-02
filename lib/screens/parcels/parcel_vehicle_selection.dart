import 'package:BucoRide/utils/app_constants.dart';
import 'package:BucoRide/utils/dimensions.dart';
import 'package:flutter/material.dart';

class ParcelVehicleSelection extends StatefulWidget {
  final Function(String) onSelected;
  final String? selectedType;

  const ParcelVehicleSelection({
    Key? key,
    required this.onSelected,
    this.selectedType,
  }) : super(key: key);

  @override
  _ParcelVehicleSelectionState createState() => _ParcelVehicleSelectionState();
}

class _ParcelVehicleSelectionState extends State<ParcelVehicleSelection> {
  late String selectedVehicleType;

  final List<Map<String, dynamic>> vehicleTypes = [
    {"icon": Icons.motorcycle_rounded, "label": "Moto Express"},
    {"icon": Icons.car_repair, "label": "Car"},
  ];

  @override
  void initState() {
    super.initState();
    selectedVehicleType = widget.selectedType ?? vehicleTypes.first["label"];
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
              "Select Your Preferred Transport",
              style: TextStyle(
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: vehicleTypes.map((vehicle) {
                bool isSelected = vehicle["label"] == selectedVehicleType;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = vehicle["label"];
                    });
                    widget.onSelected(vehicle["label"]);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 120, // Fixed width for uniform size
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[200] : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          vehicle["icon"],
                          size: 40,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        SizedBox(height: Dimensions.paddingSize),
                        Text(
                          vehicle["label"],
                          textAlign: TextAlign.center, // Ensures centered text
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
          ],
        ),
      ),
    );
  }
}
