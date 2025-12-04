import 'package:BucoRide/providers/app_state.dart';
import 'package:BucoRide/providers/location_provider.dart';
import 'package:BucoRide/providers/user_provider.dart';
import 'package:BucoRide/screens/auth/auth_wrapper.dart';
import 'package:BucoRide/services/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If you use Firebase, initialize it here:
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide a single instance of ApiService
        Provider<ApiService>(create: (_) => ApiService()),

        // UserProvider depends on nothing
        ChangeNotifierProvider(create: (_) => UserProvider.initialize()),

        // AppStateProvider depends on ApiService
        ChangeNotifierProxyProvider<ApiService, AppStateProvider>(
          create: (_) => AppStateProvider(apiService: ApiService()), // Initial dummy
          update: (context, apiService, previous) => AppStateProvider(apiService: apiService),
        ),
        
        // LocationProvider depends on ApiService and UserProvider
        ChangeNotifierProxyProvider2<UserProvider, ApiService, LocationProvider>(
          create: (context) => LocationProvider(apiService: context.read<ApiService>()),
          update: (context, userProvider, apiService, previousLocationProvider) =>
              LocationProvider(
            apiService: apiService,
            accessToken: userProvider.accessToken,
          ),
        ),
      ],
      child: MaterialApp(
        home: AuthWrapper(), // Your app's new entry point
      ),
    );
  }
}