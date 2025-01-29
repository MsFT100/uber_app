import 'package:flutter/material.dart';
import 'package:user_app/utils/dimensions.dart';

class HomeMyAddress extends StatelessWidget {
  final String? title;
  final List<String>? addressList;

  const HomeMyAddress({Key? key, this.title, this.addressList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSize),
      decoration: BoxDecoration(
        color: addressList != null && addressList!.isNotEmpty
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? 'My Address',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            if (addressList != null && addressList!.isNotEmpty)
              Text(
                'Saved addresses for your trip',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16.0),
            if (addressList != null)
              addressList!.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: addressList!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: AddressItemCard(
                              address: addressList![index],
                            ),
                          );
                        },
                      ),
                    )
                  : _buildAddAddressCard(context)
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // Add Address Card
  Widget _buildAddAddressCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Add Address Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddNewAddressPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.add, size: 32, color: Theme.of(context).primaryColor),
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
                          color: Colors.grey,
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
}

// Individual Address Item Card
class AddressItemCard extends StatelessWidget {
  final String address;

  const AddressItemCard({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12.0),
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on,
                  size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8.0),
              Text(
                address,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ));
  }
}

// Add New Address Page (Mock)
class AddNewAddressPage extends StatelessWidget {
  const AddNewAddressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Address')),
      body: Center(
        child: Text('Add Address Page Content Here'),
      ),
    );
  }
}
