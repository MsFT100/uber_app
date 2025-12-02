import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/app_state.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/images.dart';
import '../../widgets/app_bar/app_bar.dart';

class FindDriverScreen extends StatefulWidget {
  const FindDriverScreen({Key? key}) : super(key: key);

  @override
  _FindDriverScreenState createState() => _FindDriverScreenState();
}

class _FindDriverScreenState extends State<FindDriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Finding Your Driver', showNavBack: true, centerTitle: true),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final trip = appState.currentTrip;

          if (trip == null) {
            return _buildErrorState();
          }

          switch (trip.status) {
            case TripStatus.pending:
            case TripStatus.requested:
              return _buildSearchingForDriver(appState);
            case TripStatus.accepted:
            case TripStatus.arriving:
              return _buildDriverFound(appState);
            default:
              // Handle other statuses or navigate away
              return _buildSearchingForDriver(appState);
          }
        },
      ),
    );
  }

  Widget _buildSearchingForDriver(AppStateProvider appState) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLoader(Images.parcelDeliveryman),
          const SizedBox(height: 32),
          const Text('Looking For Drivers near you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final accessToken = userProvider.accessToken;
              if (accessToken != null) {
                appState.cancelTrip(accessToken);
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.lightPrimary),
            child: const Text('Cancel Search', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverFound(AppStateProvider appState) {
    final driver = appState.driver;
    if (driver == null) {
      return _buildErrorState(message: 'Driver details not available.');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 100,
            backgroundImage: driver.profilePhotoUrl != null && driver.profilePhotoUrl!.isNotEmpty
                ? NetworkImage(driver.profilePhotoUrl!)
                : null,
            child: (driver.profilePhotoUrl == null || driver.profilePhotoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          const SizedBox(height: 24),
          const Text('Driver Found!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 12),
          Text(driver.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('${driver.carModel ?? ''} ${driver.carColor ?? ''} - ${driver.licensePlate ?? ''}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          const Text('Your driver is on the way.'),
        ],
      ),
    );
  }

  Widget _buildErrorState({String message = 'Something went wrong.'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLoader(String imagePath) {
    return RotationTransition(
      turns: _controller,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.lightPrimary),
            ),
          ),
          Image.asset(imagePath, width: 150),
        ],
      ),
    );
  }
}
