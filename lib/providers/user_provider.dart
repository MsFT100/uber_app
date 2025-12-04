import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/rider.dart';
import '../services/api_service.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final  _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  User? _user;
  Rider? _rider;
  Status _status = Status.Uninitialized;
  String? _accessToken;
  bool _isSigningUp = false;
  StreamSubscription<User?>? _authStateSubscription;

  // Text editing controllers
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();

  User? get user => _user;
  Rider? get rider => _rider;
  Status get status => _status;
  String? get accessToken => _accessToken;

  UserProvider.initialize()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn() {
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_isSigningUp) return; // Don't do anything if a sign-up is in progress.

    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      await login();
    }
    notifyListeners();
  }

// 3. REPLACED THE ENTIRE signIn METHOD WITH THE LOGIC FROM YOUR DRIVER APP
  Future<String> signIn() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      // Step 1: Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      _user = userCredential.user;
      if (_user == null) {
        throw Exception("Firebase user not found after sign-in.");
      }

      // Step 2: Get the Firebase ID Token (force refresh for a new token)
      final firebaseToken = await _user!.getIdToken(true);

      // Step 3: Login to your backend with the Firebase token
      final backendResponse = await _apiService.loginRider(
        firebaseToken!,
        fcmToken: await _firebaseMessaging.getToken(), // Also get the FCM token for notifications
      );

      // Step 4: Store the data from your backend
      _rider = backendResponse.rider;
      _accessToken = backendResponse.accessToken;

      // Step 5: Set the final status and notify the UI
      _status = Status.Authenticated;
      notifyListeners();

      return "Success";
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message ?? "An unknown authentication error occurred.";
    } catch (e) {
      // Catch errors from your API service or other issues
      _status = Status.Unauthenticated;
      notifyListeners();
      debugPrint("Sign In Error: $e");
      // Provide a user-friendly error message
      if (e.toString().contains('Exception:')) {
        return e.toString().split('Exception: ')[1];
      }
      return "An error occurred during login. Please try again.";
    }
  }

  Future<String> signUp({required File profileImage}) async {
    _isSigningUp = true;
    try {
      _status = Status.Authenticating;
      notifyListeners();

      // 1. Create the user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());

      // 2. Register the user on your backend
      await _apiService.registerRider(
        uid: credential.user!.uid,
        name: name.text,
        email: email.text,
        phone: phone.text,
      );

      // 3. Now, manually log in to your backend
      _user = credential.user;
      await login();

      // 4. Check if the login was successful and update the status
      if (_rider != null) {
        _status = Status.Authenticated;
        notifyListeners();
        return "Success";
      } else {
        throw Exception('Backend login failed after registration.');
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      _status = Status.Unauthenticated;
      // Clean up the created Firebase user if backend registration or login fails
      if (await _auth.currentUser != null) {
        await _auth.currentUser?.delete();
      }
      notifyListeners();
      debugPrint('Sign up failed: $e');
      return 'Registration failed. Please try again.';
    } finally {
      _isSigningUp = false; // Reset the flag
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      // Step 1: Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = Status.Unauthenticated;
        notifyListeners();
        return "Google sign in was cancelled.";
      }

      // Step 2: Get the authentication tokens from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 3: Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      if (_user == null) {
        throw Exception("Firebase user not found after Google sign-in.");
      }

      // Step 4: (THIS WAS THE MISSING PART)
      // Now that we are logged into Firebase, log into our own backend
      await login();

      // Step 5: Check if the backend login was successful
      if (_status != Status.Authenticated) {
        // This can happen if the user exists in Firebase but not on your backend.
        // We should register them on our backend and try logging in again.
        debugPrint("User not found on backend. Registering now...");
        await _apiService.registerRider(
          uid: _user!.uid,
          name: _user!.displayName ?? 'Unknown Name',
          phone: _user!.phoneNumber ?? '', // Phone might be null
          email: _user!.email ?? 'no-email@google.com',
        );
        // Try to log in to the backend again after successful registration
        await login();
      }

      // Final check
      if (_status == Status.Authenticated) {
        return "Success";
      } else {
        throw Exception("Backend login failed after Google Sign-In and registration attempt.");
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      debugPrint("Google Sign-In Error: $e");
      if (e.toString().contains('Exception:')) {
        return e.toString().split('Exception: ')[1];
      }
      return "An error occurred with Google Sign-In.";
    }
  }

  Future<void> login({int retries = 0}) async {
    try {
      final idToken = await _user?.getIdToken(true);
      if (idToken == null) throw Exception('Could not get ID token.');

      final response = await _apiService.loginRider(idToken, fcmToken: await _firebaseMessaging.getToken());
      _rider = response.rider;
      _accessToken = response.accessToken;
      _status = Status.Authenticated;
    } catch (e) {
      // Retry logic for the specific race condition where the backend hasn't created the user yet.
      if (e.toString().contains('Rider not found') && retries < 3) {
        await Future.delayed(const Duration(seconds: 2));
        await login(retries: retries + 1);
      } else {
        debugPrint('Login Error: $e');
        _status = Status.Unauthenticated;
        // DO NOT sign out here. This was the cause of the login loop.
      }
    }
    notifyListeners();
  }

  void clearController() {
    email.clear();
    password.clear();
    name.clear();
    phone.clear();
  }

  Future<void> signOut() async {
    clearController();
    await _auth.signOut();
    await _googleSignIn.signOut();
    _status = Status.Unauthenticated;
    _rider = null;
    _accessToken = null;
    notifyListeners();
  }

  Future<void> updateUserData(Rider rider) async {
    try {
      _rider = rider;
      notifyListeners();
    } catch (e) {
      print('Update User Data Error: $e');
      rethrow;
    }
  }
}
